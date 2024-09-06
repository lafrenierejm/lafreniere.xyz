---
title: "Install LineageOS 21 over OxygenOS 14"
date: 2024-08-24T14:35:00-04:00
draft: false
---

This post enumerates the process I followed to install LineageOS 21 on an unlocked, North American OnePlus 9 (model LE2115) running OxygenOS 14.
When I performed this update, LineageOS explicitly _only_ supports installing on OnePlus 9 models that are running Android 13;
that meant I needed to first downgrade the phone from OxygenOS 14 to 13.
Downgrading proved much more complicated than I expected, so I wrote this post to document the successful path I eventually found.

1. Copy the downloaded stock ROM to your computer via `adb pull /sdcard/$rom_zip` where `$rom_zip` is the name of the downloaded ROM file.
   For example, `adb pull /sdcard/2937d9d6e8a03973c33443f809287435e44858b8.zip`.

1. Lots of MSMDownloadTool stuff
1. You end up with OxygenOS 11.

1. Let the phone boot normally then skip through the setup.
1. Enable developer mode.
1. Enable USB debugging.

1. Update to the most recent release of OxygenOS 11.
   Attempting to update directly to OxygenOS 12 or 13 without this step will fail.
   1. Download the latest OxygenOS 11 ROM.
      1. Visit <https://service.oneplus.com/global/search/search-detail?id=2096329&articleIndex=1>, the redirect target of <https://www.oneplus.com/global/support/softwareupgrade>.
      1. Download `11.2.10.10.LE25BA` for the OnePlus 9.
         The downloaded file will be named `OnePlus9Oxygen_22.O.13_OTA_0130_all_2111112106_03a66541157c4af5.zip`.
      1. Verify that the md5sum of the downloaded file matches the checksum shown on the webpage.
   1. Push the downloaded ROM archive to your phone, e.g. `adb push OnePlus9Oxygen_22.O.13_OTA_0130_all_2111112106_03a66541157c4af5.zip /sdcard/`.
   1. Install the ROM via the phone's System Updates app.
      1. Settings > System > System Updates
      1. Tap the gear icon in top right.
      1. Select your ROM Zip file.
      1. Choose "Install Now".

1. Download the latest full (non-incremental) OxygenOS 12 ROM from <https://www.xda-developers.com/oneplus-oxygenos-12-android-12-update-tracker/>.
   For the North American model, this should be `12.0 (C.48)` which will download as `1797d47ddef0fca1411fb006b9c7a1a7ba33d818.zip`.

1. Push the downloaded ROM archive to your phone, e.g. `adb push 1797d47ddef0fca1411fb006b9c7a1a7ba33d818.zip /sdcard/`
1. Install the ROM.
   1. Settings > System > System Updates
   1. Tap the gear icon in top right.
   1. Select your ROM Zip file.
   1. Choose "Install Now".

1. Install [Oxygen Updater](https://play.google.com/store/apps/details?id=com.arjanvlek.oxygenupdater) on the phone.
1. Within Oxygen Updater:
   1. Enable advanced options.
   1. Download the latest full (i.e. non-delta) ROM.
   1. Wait for the download to finish.
      It should be expected to be multiple GB.
      Once complete, the ROM will be in `/sdcard` on the device.

1. Push the previously downloaded ROM to the phone, e.g. `adb push 2937d9d6e8a03973c33443f809287435e44858b8.zip /sdcard/`.
1. Install the ROM.
   1. Settings > System > System Updates
   1. Tap the gear icon in top right.
   1. Select your ROM Zip file.
   1. Choose "Install Now".

1. Reboot the phone into recovery: `adb -d reboot bootloader`
1. Unlock the phone's bootloader:
   1. `fastboot oem unlock`
   1. Follow the prompts on the phone's screen to confirm.
   1. Wait for the phone to completely reboot.
1. Re-enable USB debugging on the phone following its reboot.
1. Reboot the phone into recovery again: `adb -d reboot bootloader`
1. Using [payload-dumper-go](https://github.com/ssut/payload-dumper-go), extract the stock ROM you had previously pulled from the device.
1. Flash all of the extracted `.img` files:

   ```shell
   for file in $(find *); do
       fastboot flash --slot=all "${file%.*}" "$file" || fastboot flash "${file%.*}" "$file"
   done
   ```

1. Run the commands listed in step 5 of <https://wiki.lineageos.org/devices/lemonade/fw_update/>.
   As of the time of this writing, those are:
   ```shell
   for file in $(find *); do
      echo "$file"
   done
   ```
