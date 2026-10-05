#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/shennong

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    vendor \
    system_ext \
    system \
    vendor_dlkm \
    product \
    system_dlkm \
    odm
# shennong 有独立 recovery 分区 (原厂 recovery.img 104MB, ramdisk-only),
# 非 recovery-as-boot, 不设置 BOARD_USES_RECOVERY_AS_BOOT

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 := 
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo300

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := kryo300

# APEX
DEXPREOPT_GENERATE_APEX_IMAGE := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := pineapple
TARGET_NO_BOOTLOADER := true

# Kernel
BOARD_BOOTIMG_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_KERNEL_IMAGE_NAME := Image
TARGET_KERNEL_CONFIG := qcom_defconfig
TARGET_KERNEL_SOURCE := kernel/xiaomi/qcom

# Kernel - prebuilt
# 实测原厂 recovery.img 为纯 ramdisk (header v4, kernel_size=0), 内核由 boot 分区 GKI 提供,
# 故与 houji 同方案: ramdisk-only recovery.img, 内核不打包
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
BOARD_RAMDISK_USE_LZ4 := true
TARGET_FORCE_PREBUILT_KERNEL := true
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL),true)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel_empty
endif

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 104857600
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
BOARD_SUPER_PARTITION_SIZE := 9126805504 # TODO: Fix hardcoded value
BOARD_SUPER_PARTITION_GROUPS := xiaomi_dynamic_partitions
BOARD_XIAOMI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system system_ext system_ext product product vendor vendor vendor_dlkm vendor_dlkm system_dlkm system_dlkm odm odm mi_ext mi_ext
BOARD_XIAOMI_DYNAMIC_PARTITIONS_SIZE := 9122611200 # TODO: Fix hardcoded value

# Platform
TARGET_BOARD_PLATFORM := xiaomi_sm8650

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Security patch level
VENDOR_SECURITY_PATCH := 2021-08-01

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

# Metadata partition for FBE metadata decryption (Android 13+ incl. 17)
BOARD_USES_METADATA_PARTITION := true

# Crypto / FBE decryption (Qualcomm SM8650, Android 17)
# FSCRYPT_POLICY 2 = fscrypt v2 + wrappedkey + inlinecrypt, A13-A17 必需
BOARD_USES_QCOM_FBE_DECRYPTION := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := 2
RECOVERY_SDCARD_ON_DATA := true
TW_PREPARE_DATA_MEDIA_EARLY := true
TW_EXCLUDE_APEX := true
# Pixel8Pro A17 PBRP 方案验证: recovery 解密期间保持 vendor 挂载,
# 否则 AIDL KeyMint/Gatekeeper/Weaver HAL 在 vendor 卸载后掉线 (需配合 patches/0001+0002)
TW_KEEP_VENDOR_MOUNTED_FOR_CRYPTO := true

# Hack: prevent anti rollback
# prepdecrypt 会在运行时从挂载的 system/vendor 读取真实 patch level 覆盖此处,
# 所以这里保持 2099 不影响 A17 解密, 反而避免刷入时报 rollback 错误
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
PLATFORM_VERSION := 17
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)

# TWRP Configuration
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_FASTBOOTD := true
TARGET_USES_MKE2FS := true

# TWRP board configs (Soong 变量导出等, 缺了会报 TW_THEME: not set)
-include vendor/twrp/config/BoardConfigTWRP.mk
