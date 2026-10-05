#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/xiaomi/shennong
# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# Boot control HAL: 用 QTI AIDL 服务 + xiaomi bootctrl.
# 不要引入 AOSP HIDL android.hardware.boot@1.x-service: 本树 soong 不安装
# vendor/etc/init 下的 init_rc, TWRP 的 relink 会因缺该 rc 报错.
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl-qti \
    android.hardware.boot@1.2-impl-qti.recovery \
    bootctrl.xiaomi_sm8650 \
    bootctrl.xiaomi_sm8650.recovery

PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# Decryption (QCOM FBE, Android 17)
# vendor/twrp/common.mk 在新版 TWRP 会自动拉入 qcom_decrypt*,
# 这里显式声明以兼容 omni common.mk (当前 omni_shennong.mk 用的是 vendor/omni)
PRODUCT_PACKAGES += \
    qcom_decrypt \
    qcom_decrypt_fbe

# Shipping / VNDK - 解密 HAL 需要的版本对齐 (SM8650 pineapple, A14-A17 通用)
PRODUCT_SHIPPING_API_LEVEL := 32
PRODUCT_TARGET_VNDK_VERSION := 34

# 引入 extract-files.sh 提取的 A17 解密 blobs (若不存在则跳过, 兼容 minimal manifest 预置 blobs 方式)
$(call inherit-product-if-exists, vendor/xiaomi/shennong/shennong-vendor.mk)
