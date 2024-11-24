---
title: "Installing LineageOS 21 over OxygenOS 14"
date: 2024-08-24T14:35:00-04:00
draft: false
---

This post enumerates the process I followed to install LineageOS 21 on an unlocked, North American OnePlus 9 (model LE2115) running OxygenOS 14.
When I performed this installation, LineageOS explicitly _only_ supported installation over Android 13.
Downgrading proved much more complicated than I expected, so I wrote this post to document the successful path I eventually found.

## Requirements

Before you begin, you will need:

1. Physical access to and full privileges on a OnePlus 9
1. Physical access to and admin privileges on a Windows 10+ box
1. USB-C cable capable of data transfer

## Steps

1. Copy the downloaded stock ROM to your computer via `adb pull /sdcard/$rom_zip` where `$rom_zip` is the name of the downloaded ROM file.
   For example, `adb pull /sdcard/2937d9d6e8a03973c33443f809287435e44858b8.zip`.

1. Downgrade to OxygenOS 11.

   1. Install Qualcomm's USB Drivers on the PC for Emergency Download (EDL) capabilities.
      This will require a reboot to fully install.
   1. Install MSMDownloadTool.
      - I spent upwards of an hour looking for an official source for this software and was not able to find one.
        As such, I can't really recommend any one source over any other.
      - This tool _appears_ to have originated from a hardware assembly company;
        it is unclear to me whether it was leaked or deliberately released.
   1. Download the OxygenOS 11 ROM from <https://onepluscommunityserver.com/list/Unbrick_Tools/OnePlus_9/>.
   1. Boot the phone into EDL mode.
      1. If the phone is currently plugged in, unplug in.
      1. Turn the phone off.
      1. Hold down the Volume Up and Volume Down buttons.
      1. Connect the phone to your Windows PC via a USB cable.
   1. Use the MSMDownloadTool to install the downloaded OxyenOS 11 ROM

1. Update to the most recent release of OxygenOS 11.
   Attempting to update directly to OxygenOS 12 or 13 without this step will fail.

   1. Let the phone boot normally then skip through the setup.
   1. Enable USB debugging on the phone.
      1. Enable developer mode.
      1. Enable USB debugging.
   1. Download the latest OxygenOS 11 ROM.
      1. Visit <https://service.oneplus.com/global/search/search-detail?id=2096329&articleIndex=1>, the redirect target of <https://www.oneplus.com/global/support/softwareupgrade>.
      1. Download `11.2.10.10.LE25BA` for the OnePlus 9. <!-- spellchecker:disable-line -->
         The downloaded file will be named `OnePlus9Oxygen_22.O.13_OTA_0130_all_2111112106_03a66541157c4af5.zip`.
      1. Verify that the md5sum of the downloaded file matches the checksum shown on the webpage.
   1. Push the downloaded ROM archive to your phone, e.g. `adb push OnePlus9Oxygen_22.O.13_OTA_0130_all_2111112106_03a66541157c4af5.zip /sdcard/`.
   1. Install the ROM via the phone's System Updates app.
      1. Settings > System > System Updates
      1. Tap the gear icon in top right.
      1. Select your ROM Zip file.
      1. Choose "Install Now".

1. Upgrade to OxygenOS 12.

   1. Let the phone boot normally then skip through the setup.
   1. Enable USB debugging on the phone.
      1. Enable developer mode.
      1. Enable USB debugging.
   1. Download the latest full (non-incremental) OxygenOS 12 ROM from <https://www.xda-developers.com/oneplus-oxygenos-12-android-12-update-tracker/>.
      For the North American model, this should be `12.0 (C.48)` which will download as `1797d47ddef0fca1411fb006b9c7a1a7ba33d818.zip`.
   1. Push the downloaded ROM archive to your phone, e.g. `adb push 1797d47ddef0fca1411fb006b9c7a1a7ba33d818.zip /sdcard/`
   1. Install the ROM.
      1. Settings > System > System Updates
      1. Tap the gear icon in top right.
      1. Select your ROM Zip file.
      1. Choose "Install Now".

1. Upgrade to OxygenOS 13.
   1. Let the phone boot normally then skip through the setup.
   1. Settings > System > System Updates
   1. Check for updates.
   1. Choose the discovered OxygenOS 13 ROM.
   1. Follow the normal OS upgrade process.

You are now ready to install LineageOS 21 via the normal installation guide!
