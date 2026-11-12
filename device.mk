#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Qualcomm QRD7325 (SM7325 "Yupik") - LineageOS 21
#
# Stage 1: everything on /vendor and /odm is the stock Android 11 image, so
# only system-side packages are listed here. Anything that would install
# into /vendor is left out on purpose: it would not reach the device.
#

# A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# checkpoint_gc ships in the stock vendor image (/vendor/bin/checkpoint_gc)
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    otapreopt_script

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# Boot animation (QRD7325 panels in the stock dtbo are FHD+ 1080x2400)
TARGET_SCREEN_HEIGHT := 2400
TARGET_SCREEN_WIDTH := 1080

# Boot control (recovery / fastbootd side; the vendor side is stock)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl-qti.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# Display (system-side QTI display libraries)
PRODUCT_PACKAGES += \
    libdisplayconfig.system.qti \
    libqdMetaData.system \
    vendor.display.config@1.0 \
    vendor.display.config@2.0

# Fastboot
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl.custom \
    fastbootd

# Health (recovery)
PRODUCT_PACKAGES += \
    android.hardware.health-service.qti_recovery

# Init (first stage fstab in the vendor ramdisk, as on stock)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init/fstab.default:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.default \
    $(LOCAL_PATH)/init/init.recovery.qcom.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc

# Kernel
PRODUCT_ENABLE_UFFD_GC := false

# NFC (the NFC HAL is in the stock vendor image)
PRODUCT_PACKAGES += \
    com.android.nfc_extras \
    NfcNci \
    Tag

# Overlays
PRODUCT_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay-lineage

PRODUCT_ENFORCE_RRO_TARGETS := *

PRODUCT_PACKAGES += \
    CarrierConfigResCommon \
    FrameworksResCommon \
    Qrd7325Frameworks \
    Qrd7325Settings \
    Qrd7325SystemUI \
    SystemUIResCommon \
    TelephonyResCommon \
    WifiResCommon

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# QTI service tracker / whitelist (system side)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/privapp-permissions-qti.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/privapp-permissions-qti.xml \
    $(LOCAL_PATH)/configs/qti_whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/qti_whitelist.xml

# Shipping API
BOARD_SHIPPING_API_LEVEL := 30
PRODUCT_SHIPPING_API_LEVEL := $(BOARD_SHIPPING_API_LEVEL)

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)

# Storage
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# VNDK
# The stock vendor image is Android 11 (VNDK 30). Ship the matching VNDK
# snapshot APEX on system, as GSIs do, or every vendor HAL fails to link.
PRODUCT_EXTRA_VNDK_VERSIONS := 30

# Telephony (system-side QTI telephony glue; RIL and IMS daemons are stock vendor)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/qti_telephony_system_packages_config.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/sysconfig/qti_telephony_system_packages_config.xml

PRODUCT_PACKAGES += \
    extphonelib \
    extphonelib-product \
    extphonelib.xml \
    extphonelib_product.xml \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti-telephony-hidl-wrapper-prd \
    qti_telephony_hidl_wrapper.xml \
    qti_telephony_hidl_wrapper_prd.xml \
    qti-telephony-utils \
    qti-telephony-utils-prd \
    qti_telephony_utils.xml \
    qti_telephony_utils_prd.xml \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# VINTF: stock kernel is 5.4 and the stock vendor targets FCM level 5 (Android 11)
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

# Recovery: IPA firmware. Recovery has no /vendor, so without these the IPA
# driver retries the firmware load forever and the kernel never finishes
# shutting down (reboot from recovery hangs).
PRODUCT_COPY_FILES += \
    $(foreach f,$(wildcard device/qcom/qrd7325/prebuilt/recovery/firmware/*),\
        $(f):$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/$(notdir $(f)))

# SELinux: map the stock vendor's vendor_qtelephony_30_0 onto our system_ext type
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/sepolicy/system_ext_mapping_30.0.cil:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/selinux/mapping/30.0.cil

# Proprietary IMS / RIL glue from stock system_ext (vendor/qcom/qrd7325)
$(call inherit-product-if-exists, vendor/qcom/qrd7325/qrd7325-vendor.mk)
