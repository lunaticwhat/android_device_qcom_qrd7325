#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Qualcomm QRD7325 (SM7325 "Yupik") - LineageOS 21 device tree
#
# Stage 1 bring-up: stock Android 11 vendor/odm images, stock kernel,
# dtb and dtbo are used as prebuilts. LineageOS builds system,
# system_ext, product, boot (with LineageOS Recovery) and vendor_boot.
# This is the same stock vendor + Android 14 system combination that
# has already been tested with a LineageOS 21 GSI on this board.
#

BOARD_VENDOR := qcom

DEVICE_PATH := device/qcom/qrd7325

# A/B
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    odm \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a76

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := lahaina
TARGET_NO_BOOTLOADER := true

# Build
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# Display
TARGET_SCREEN_DENSITY := 420

# HIDL (system side only - the vendor manifest/matrix come from the stock vendor image)
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := \
    hardware/qcom-caf/common/vendor_framework_compatibility_matrix.xml \
    vendor/lineage/config/device_framework_matrix.xml

# Kernel
# Stock kernel 5.4.147-qgki from boot_a, stock dtb from vendor_boot_a and
# stock dtbo_a. The kernel source is still needed for headers; it is also
# what Stage 2 builds from (remove TARGET_FORCE_PREBUILT_KERNEL then).
BOARD_BOOT_HEADER_VERSION := 3
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_DTB_OFFSET := 0x01f00000
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_SEPARATED_DTBO := true
# Serial console disabled (stock had console=ttyMSM0,115200n8 and
# androidboot.console=ttyMSM0; the dtb in prebuilt/dtb also has the debug
# UART node turned off and earlycon removed). To get the UART log back for
# bring-up, add those two arguments again and use the stock dtb.
BOARD_KERNEL_CMDLINE := \
    androidboot.hardware=qcom \
    androidboot.memcg=1 \
    lpm_levels.sleep_disabled=1 \
    video=vfb:640x400,bpp=32,memsize=3072000 \
    msm_rtb.filter=0x237 \
    service_locator.enable=1 \
    androidboot.usbcontroller=a600000.dwc3 \
    swiotlb=0 \
    loop.max_part=7 \
    cgroup.memory=nokmem,nosocket \
    pcie_ports=compat \
    iptable_raw.raw_before_defrag=1 \
    ip6table_raw.raw_before_defrag=1
# Uncomment for first boots on a userdebug build if SELinux denials block boot:
# BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive

BOARD_MKBOOTIMG_ARGS += \
    --header_version $(BOARD_BOOT_HEADER_VERSION) \
    --kernel_offset $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) \
    --dtb_offset $(BOARD_DTB_OFFSET)

TARGET_KERNEL_SOURCE := kernel/qcom/lahaina
TARGET_KERNEL_CONFIG := vendor/lahaina-qgki_defconfig vendor/debugfs.config
TARGET_KERNEL_NO_GCC := true

TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img

# First stage (vendor ramdisk) kernel modules - same as stock vendor_boot
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := \
    $(DEVICE_PATH)/prebuilt/modules/vendor_ramdisk/msm_drm.ko
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := msm_drm.ko
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := msm_drm.ko

# Metadata
BOARD_USES_METADATA_PARTITION := true

# Partitions (sizes match the stock partition table of this board)
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x06000000
BOARD_DTBOIMG_PARTITION_SIZE := 0x01800000
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 0x06000000
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)

BOARD_PRODUCTIMAGE_MINIMAL_PARTITION_RESERVED_SIZE := false
-include vendor/lineage/config/BoardConfigReservedSize.mk

BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4

# Stock vendor and odm, extracted from your super.img (see README.md)
BOARD_PREBUILT_VENDORIMAGE := $(DEVICE_PATH)/prebuilt/images/vendor.img
BOARD_PREBUILT_ODMIMAGE := $(DEVICE_PATH)/prebuilt/images/odm.img

BOARD_SUPER_PARTITION_SIZE := 6442450944
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 6438256640
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := odm product system system_ext vendor

TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor

# Platform
BOARD_USES_QCOM_HARDWARE := true
TARGET_BOARD_PLATFORM := lahaina

# Properties
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/product.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/system_ext.prop

# Recovery
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_USES_RECOVERY_AS_BOOT := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/fstab.default
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 120
TARGET_USERIMAGES_USE_F2FS := true

# Security patch level (stock vendor/boot)
BOOT_SECURITY_PATCH := 2022-01-01
VENDOR_SECURITY_PATCH := $(BOOT_SECURITY_PATCH)

# SELinux
# The vendor policy is the precompiled stock one inside vendor.img. Only
# system_ext policy is added here, as on the GSI that already boots.
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private

# Use sha256 for dm-verity partitions
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# Verified Boot
BOARD_AVB_ENABLE := true
# Disable dm-verity/verification so addons (GApps) can change system/product/system_ext
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
