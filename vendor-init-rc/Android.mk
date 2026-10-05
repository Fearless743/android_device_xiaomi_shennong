# Android.mk: 补上 minimal twrp-14 源里 soong 不生成的 vendor/etc/init rc 安装规则.
# 这些 rc 属于从产品继承引入的 vendor HIDL 服务, 本树 soong 只安装二进制不安装其
# init_rc, 但 TWRP relink_binaries 的依赖图要求这些路径存在. recovery 不使用这些
# 服务, 内容为空即可, 仅用于满足 ninja 依赖.
#
# 用唯一模块名 + LOCAL_MODULE_STEM 精确产出目标文件名, 避免与其它模块重名.

ifeq ($(TARGET_DEVICE),shennong)

include $(CLEAR_VARS)
LOCAL_MODULE := shennong_rc_health20
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_STEM := android.hardware.health@2.0-service.rc
LOCAL_MODULE_PATH := $(PRODUCT_OUT)/vendor/etc/init
LOCAL_SRC_FILES := android.hardware.health@2.0-service.rc
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := shennong_rc_health21
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_STEM := android.hardware.health@2.1-service.rc
LOCAL_MODULE_PATH := $(PRODUCT_OUT)/vendor/etc/init
LOCAL_SRC_FILES := android.hardware.health@2.1-service.rc
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE := shennong_rc_vndservicemanager
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_STEM := vndservicemanager.rc
LOCAL_MODULE_PATH := $(PRODUCT_OUT)/vendor/etc/init
LOCAL_SRC_FILES := vndservicemanager.rc
include $(BUILD_PREBUILT)

endif
