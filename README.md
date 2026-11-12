# LineageOS 21 device tree for Qualcomm QRD7325 (SM7325 "Yupik")

EVERYTHING IS AI SLOP BUT IT WORKED WELL. I DIDN'T EVEN WRITE A SINGLE LINE OF CODE
WARNING: Please do a full GPT backup with QFIL before doing anything. This phone might have everything emptied in slot b so check and replace them with backups from slot a.

Path in the source tree: `device/qcom/qrd7325`
Product: `lineage_qrd7325`

This tree is based on QRD-Development's QRD8350 tree
(`android_device_qcom_lahaina`, branch `lineage-21`). That board runs the same unified
Qualcomm "lahaina" build as the QRD7325 (one vendor image for Lahaina, Shima and Yupik).

## Status

Working on the QRD7325 with the stock Android 11 vendor:

| Area | State | Notes |
|---|---|---|
| Boot | Working | `PRODUCT_EXTRA_VNDK_VERSIONS := 30` for the Android 11 vendor |
| LineageOS Recovery | Working | ADB/sideload over USB (dwc3 role file labelled for recovery), reboot to recovery (IPA firmware in recovery, `misc` labelled) |
| Cameras | Working | Ultrawide / main / tele lens switching in Aperture (product overlay) |
| Mobile data | Working | Tested on Viettel. VinaPhone rejects data/LTE attach on the network side (reject #7 / #15) |
| 5G (NR NSA) | Working | `ro.telephony.default_network=26,26`, both SIM slots |
| VoLTE | Working | Needs the vendor tree below; IMS app runs in `vendor_qtelephony` |

## Vendor tree (VoLTE)

VoLTE needs the stock Qualcomm IMS pieces from the Android 11 `system_ext`
(`ims.apk`, `qcrilmsgtunnel.apk`, `qcrilhook.jar`, IMS libraries and permission XMLs).
They live in a separate tree at `vendor/qcom/qrd7325`, picked up by
`inherit-product-if-exists` in `device.mk`. Without it the ROM still builds and boots,
just without VoLTE.

The SELinux side is in this tree: `sepolicy/private/qtelephony.te`,
`sepolicy/private/seapp_contexts` and `prebuilt/sepolicy/system_ext_mapping_30.0.cil`,
which maps the stock vendor's `vendor_qtelephony_30_0` onto our type.

## Fixes in this port

Problems hit while bringing LineageOS 21 up on the stock Android 11 vendor, and how
each was fixed.

### Boot: stuck at the Qualcomm logo
The stock Android 11 vendor links against the VNDK 30 libraries, which a LineageOS 21
system does not ship by default. Fixed with `PRODUCT_EXTRA_VNDK_VERSIONS := 30`.

### Recovery: no USB / ADB
`init.recovery.qcom.rc` writes the dwc3 role file
(`/sys/devices/platform/soc/a600000.ssusb/mode`) to put the controller in device mode.
The recovery policy has no vendor genfs labels, so the file is plain `sysfs`, which init
may never write (neverallow). Without that write the PC only sees the Qualcomm EUD hub
(05C6:9501). Fixed with a recovery-only type `sysfs_usb_role_recovery`, a `genfscon`
for the file and a write rule for init. Works with SELinux enforcing. No host ADB key is built into the image; recovery behaves like any other
LineageOS recovery.

### Recovery: "reboot to recovery" hangs
Two causes:
- The IPA driver retries loading `yupik_ipa_fws` forever when `/vendor` is not
  mounted, so the kernel never finishes shutting down. The IPA firmware is now copied
  into the recovery ramdisk (`prebuilt/recovery/firmware`).
- The bootloader message for "reboot recovery" is written to `misc`, which only had
  the generic `block_device` label, so the write was denied. `misc` is now labelled
  `misc_block_device`.

### Camera: lens switch buttons did nothing
Aperture only uses the auxiliary cameras (ultrawide 2.24 mm, tele 6.0 mm) when
`config_enableAuxCameras` is true. The overlay was a device (vendor) overlay; with
`PRODUCT_ENFORCE_RRO_TARGETS := *` it became a vendor RRO, which is lost because the
vendor image is prebuilt. `overlay-lineage` is now a product overlay, and the logical
camera (ID 4) is ignored.

### 5G: missing from Settings
Without `ro.telephony.default_network`, telephony falls back to WCDMA_PREF. That value
is also used as the carrier-reason allowed network types, so NR was never allowed and
Settings hid every 5G entry. Set to `26,26` (NR/LTE/GSM/WCDMA) for both SIM slots. 5G NSA works.

### VoLTE
- The Qualcomm IMS pieces from the stock `system_ext` (`ims.apk`,
  `qcrilmsgtunnel.apk`, `qcrilhook.jar`, IMS libraries, permission XMLs) are provided by
  the vendor tree `vendor/qcom/qrd7325`, picked up with `inherit-product-if-exists`.
- On stock, `org.codeaurora.ims` runs in the system_ext domain `vendor_qtelephony`, and
  the stock vendor policy grants the IMS HALs and vendor radio/ims properties to
  `vendor_qtelephony_30_0`. Without that domain the app runs as `platform_app`, the
  vendor side denies it and the ImsService never comes up (no VoLTE toggle). Fixed with
  `sepolicy/private/qtelephony.te`, a `seapp_contexts` entry, and
  `prebuilt/sepolicy/system_ext_mapping_30.0.cil` installed as
  `system_ext/etc/selinux/mapping/30.0.cil`.

### Known limitations
- **VoNR:** not possible with this vendor. VoNR needs the AIDL radio HAL (voice 2.0);
  the Android 11 vendor only has radio HAL 1.x.
- **VinaPhone data:** the network rejects the data/LTE attach (reject #7 / #15). Viettel
  works with data, LTE, 5G NSA and VoLTE.

## Stage 1 (this tree): stock vendor, LineageOS system

The stock Android 11 `vendor` and `odm` images, kernel, dtb and dtbo are used as
prebuilts. LineageOS builds `system`, `system_ext`, `product`, `boot` (with LineageOS
Recovery), `vendor_boot`, `vbmeta` and `vbmeta_system`.

A LineageOS 21 GSI already runs on this exact stock vendor, with a working SIM,
so this is the combination most likely to boot first time.

| Item | Source |
|---|---|
| `prebuilt/kernel` | stock `boot_a.img` (Linux 5.4.147-qgki) |
| `prebuilt/dtb/stock.dtb` | stock `vendor_boot_a.img` (all Lahaina/Shima/Yupik SoC dtbs), with the serial console UART node disabled and `earlycon` removed |
| `prebuilt/dtbo.img` | stock `dtbo_a.img`, trimmed to its real size (contains the Yupik QRD overlays) |
| `prebuilt/modules/vendor_ramdisk/msm_drm.ko` | stock `vendor_boot_a.img` ramdisk |
| `init/fstab.default` | stock `vendor_boot_a.img` first-stage fstab |
| `init/init.recovery.qcom.rc` | stock `boot_a.img` ramdisk |
| `prebuilt/images/vendor.img`, `odm.img` | **you create these** from your `super.img` (below) |

### 1. Get the source

```bash
mkdir -p ~/android/lineage && cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0 --git-lfs --no-clone-bundle
mkdir -p .repo/local_manifests
cp /path/to/qrd7325/local_manifests/qrd7325.xml .repo/local_manifests/
repo sync -c -j8 --no-tags --no-clone-bundle --optimized-fetch --prune
```

Copy this folder to `device/qcom/qrd7325` (without the `local_manifests` folder).

### 2. Extract stock vendor and odm from your super dump

```bash
. build/envsetup.sh
m lpunpack
device/qcom/qrd7325/extract-prebuilts.sh /path/to/partition_backup/super.img a
```

This writes `prebuilt/images/vendor.img` and `prebuilt/images/odm.img`. If it says the
partition is empty, use slot `b`.

### 3. Build

```bash
. build/envsetup.sh
breakfast qrd7325 userdebug
m bacon -j$(nproc)
```

Use `userdebug` while bringing the board up: you get `adb root` and logcat from early boot.

### 4. Flash

Output is in `out/target/product/qrd7325/`.

```bash
adb reboot bootloader
fastboot flash boot boot.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash dtbo dtbo.img
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot reboot recovery
```

In LineageOS Recovery:
1. Choose **Factory reset > Format data / factory reset**.
2. Choose **Apply update > Apply from ADB**.
3. On the PC, run `adb sideload lineage-21.0-*-UNOFFICIAL-qrd7325.zip`.

To go back to stock, use your `partition_backup` images: `super`, `boot`, `vendor_boot`, `dtbo` and `vbmeta`.

### If it does not boot

Get a log from the first boot:

```bash
adb wait-for-device logcat -b all > boot_log.txt
```

If SELinux blocks boot, uncomment `androidboot.selinux=permissive` in `BoardConfig.mk`. It only works on
userdebug builds.

### Values to confirm on the device

- `TARGET_SCREEN_DENSITY := 420` and 1080x2400. The stock dtbo only has FHD+ (1080x2400)
  panels for Yupik QRD. Check with `adb shell wm size` and `adb shell wm density` on stock or the GSI.
- `overlay/Qrd7325Frameworks`: the QRD8350 rounded-corner values were removed. The status bar
  height and the 120 Hz peak refresh rate were kept from QRD8350.

## Stage 2 (later): build vendor from source

When Stage 1 boots, you can move to a vendor built from source, with the LineageOS kernel
and LineageOS HALs:

1. Kernel: the `lineage-21` branch of `android_kernel_qcom_sm8350` already contains
   `yupik-qrd.dts` and `yupik-qrd-overlay.dts`. Remove `TARGET_FORCE_PREBUILT_KERNEL` and the
   prebuilt dtb/dtbo lines. Also bring back the QRD8350 tree's kernel-module and `vendor_dlkm` setup.
2. Blobs: `stage2/proprietary-files.txt` is the QRD8350 blob list cut down to the 1701
   entries that exist in this board's stock dump. `stage2/missing-from-stock.txt` lists the 75
   entries it does not have, mostly newer IMS, GNSS and qtiradio versions and QSSI 14 `system_ext` apps.
   The QRD8350 tree pins those to QCM6490 Android 13 vendor and QSSI 14 blobs. QCM6490 is the same
   Yupik die, so a dump of that firmware is the natural place to get them.
3. Bring back the vendor parts of the QRD8350 `device.mk`: audio, display, GPS, power,
   sensors, Wi-Fi, vendor init scripts and sepolicy (`device/qcom/sepolicy_vndr`). Use the Yupik
   variants: `sku_yupik` audio files and `init.kernel.post_boot-yupik.sh`.

Stage 2 is also what makes VoLTE possible. Stage 1 has calls, SMS and data but no IMS apps.
