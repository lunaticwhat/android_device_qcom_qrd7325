#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from the device configuration.
$(call inherit-product, device/qcom/qrd7325/device.mk)

# Inherit from the Lineage configuration.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_BRAND := qti
PRODUCT_DEVICE := qrd7325
PRODUCT_MANUFACTURER := QUALCOMM
PRODUCT_MODEL := QRD7325
PRODUCT_NAME := lineage_qrd7325

PRODUCT_GMS_CLIENTID_BASE := android-qualcomm
