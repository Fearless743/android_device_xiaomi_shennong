#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# 极简继承 (对齐 houji 等可用的 SM8650 TWRP 树).
# 不要用 full_base_telephony: 会拖入大量 vendor HIDL 服务,
# 其 init_rc 在 minimal twrp-14 源里没有安装规则, 导致 ninja 缺依赖.
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Virtual A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Emulated storage
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from qcom device
$(call inherit-product, device/xiaomi/shennong/device.mk)

PRODUCT_DEVICE := shennong
PRODUCT_NAME := omni_shennong
PRODUCT_RELEASE_NAME := shennong
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Xiaomi 14 Pro
PRODUCT_MANUFACTURER := xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="twrp_shennong-eng 99.87.36 BP2A.250605.031.A2 eng.lu test-keys"

BUILD_FINGERPRINT := Xiaomi/twrp_shennong/qcom:99.87.36/BP2A.250605.031.A2/eng.lu:eng/test-keys
