/*
 * Copyright (C) 2017 Team Win Recovery Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TWRP_WEAVER_H
#define TWRP_WEAVER_H

#include <memory>
#include <string>
#include <utility>
#include <vector>

#include <aidl/android/hardware/weaver/IWeaver.h>
#include <android/hardware/weaver/1.0/IWeaver.h>

#ifdef LOG_INFO
#undef LOG_INFO
#endif
#ifdef LOG_WARNING
#undef LOG_WARNING
#endif

#include "Utils.h"

namespace android {
namespace vold {

class Weaver {
  public:
    Weaver();
    explicit operator bool() {
        return mAidlDevice != nullptr || mHidlDevice.get() != nullptr;
    }

    bool GetSlots(uint32_t* slots);
    bool GetKeySize(uint32_t* keySize);
    bool GetValueSize(uint32_t* valueSize);
    bool WeaverVerify(const uint32_t slot, const void* weaver_key,
                      std::vector<uint8_t>* payload);

  private:
    std::shared_ptr<aidl::android::hardware::weaver::IWeaver> mAidlDevice;
    sp<hardware::weaver::V1_0::IWeaver> mHidlDevice;
    uint32_t mSlots = 0;
    uint32_t mKeySize = 0;
    uint32_t mValueSize = 0;
    bool mGotConfig = false;

    bool GetConfig();

    DISALLOW_COPY_AND_ASSIGN(Weaver);
};

}  // namespace vold
}  // namespace android

#endif
