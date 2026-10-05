/*
 * Copyright (C) 2017 Team Win Recovery Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 */

#include "Weaver1.h"

#include <android/binder_manager.h>

#include <cstring>
#include <iostream>
#include <unistd.h>

#define ERROR 1
#define LOG(x) std::cout

using ::android::hardware::Return;
using ::android::hardware::weaver::V1_0::WeaverConfig;
using ::android::hardware::weaver::V1_0::WeaverReadResponse;
using ::android::hardware::weaver::V1_0::WeaverReadStatus;
using ::android::hardware::weaver::V1_0::WeaverStatus;

namespace android {
namespace vold {

Weaver::Weaver() {
    const std::string instance =
            std::string(aidl::android::hardware::weaver::IWeaver::descriptor) + "/default";
    AIBinder* binder = nullptr;
    for (int attempt = 0; attempt < 15 && binder == nullptr; ++attempt) {
        binder = AServiceManager_checkService(instance.c_str());
        if (binder == nullptr) sleep(2);
    }
    if (binder != nullptr) {
        mAidlDevice = aidl::android::hardware::weaver::IWeaver::fromBinder(
                ndk::SpAIBinder(binder));
    }
    if (mAidlDevice == nullptr) {
        mHidlDevice = hardware::weaver::V1_0::IWeaver::getService();
    }
}

bool Weaver::GetConfig() {
    if (mGotConfig) return true;

    if (mAidlDevice != nullptr) {
        aidl::android::hardware::weaver::WeaverConfig config;
        auto status = mAidlDevice->getConfig(&config);
        if (!status.isOk()) return false;
        mSlots = static_cast<uint32_t>(config.slots);
        mKeySize = static_cast<uint32_t>(config.keySize);
        mValueSize = static_cast<uint32_t>(config.valueSize);
        mGotConfig = true;
        return true;
    }

    if (mHidlDevice == nullptr) return false;
    WeaverStatus status;
    WeaverConfig config;
    bool callback_called = false;
    auto result = mHidlDevice->getConfig([&](WeaverStatus new_status, WeaverConfig new_config) {
        callback_called = true;
        status = new_status;
        config = new_config;
    });
    if (!result.isOk() || !callback_called || status != WeaverStatus::OK) return false;
    mSlots = config.slots;
    mKeySize = config.keySize;
    mValueSize = config.valueSize;
    mGotConfig = true;
    return true;
}

bool Weaver::GetSlots(uint32_t* slots) {
    if (!GetConfig()) return false;
    *slots = mSlots;
    return true;
}

bool Weaver::GetKeySize(uint32_t* key_size) {
    if (!GetConfig()) return false;
    *key_size = mKeySize;
    return true;
}

bool Weaver::GetValueSize(uint32_t* value_size) {
    if (!GetConfig()) return false;
    *value_size = mValueSize;
    return true;
}

bool Weaver::WeaverVerify(const uint32_t slot, const void* weaver_key,
                          std::vector<uint8_t>* payload) {
    uint32_t key_size;
    if (!GetKeySize(&key_size)) return false;
    const auto* key_data = static_cast<const uint8_t*>(weaver_key);
    std::vector<uint8_t> key(key_data, key_data + key_size);

    if (mAidlDevice != nullptr) {
        aidl::android::hardware::weaver::WeaverReadResponse response;
        auto status = mAidlDevice->read(static_cast<int32_t>(slot), key, &response);
        if (status.isOk() &&
            response.status == aidl::android::hardware::weaver::WeaverReadStatus::OK &&
            response.timeout == 0) {
            *payload = std::move(response.value);
            return true;
        }
        return false;
    }

    if (mHidlDevice == nullptr) return false;
    bool callback_called = false;
    WeaverReadStatus status;
    std::vector<uint8_t> read_value;
    uint32_t timeout = 0;
    auto result = mHidlDevice->read(slot, key, [&](WeaverReadStatus new_status,
                                                   WeaverReadResponse response) {
        callback_called = true;
        status = new_status;
        read_value = response.value;
        timeout = response.timeout;
    });
    if (result.isOk() && callback_called && status == WeaverReadStatus::OK && timeout == 0) {
        *payload = std::move(read_value);
        return true;
    }
    return false;
}

}  // namespace vold
}  // namespace android
