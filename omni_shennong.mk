#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from qcom device
$(call inherit-product, device/xiaomi/shennong/device.mk)

PRODUCT_DEVICE := shennong
PRODUCT_NAME := omni_shennong
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Xiaomi 14 Pro
PRODUCT_MANUFACTURER := xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="twrp_shennong-eng 99.87.36 BP2A.250605.031.A2 eng.lu test-keys"

BUILD_FINGERPRINT := Xiaomi/twrp_shennong/qcom:99.87.36/BP2A.250605.031.A2/eng.lu:eng/test-keys
