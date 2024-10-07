# Root & Custom Orange Neva start phone


Manufactured by Mobiwire, the phone runs Android 9 Go edition on Mediatek MT6739 chipset.

I found one of these phones in the trash a while back, but I couldn't unlock it at the time. I hope this guide can help some people, so please don't hesitate to give feedback. 

## mtkclient : enter the BROM mode

Since Orange doesn't supply a stockrom, that's where BROM mode comes in: it lets you perform a wide range of operations as soon as the phone boots up, bypassing all protection even before the bootloader. Use [mtkclient](https://github.com/bkerler/mtkclient) to dump the partitions. For the rest, we'll need the boot, recovery and system partitions. 

## Enter in bootloader

volume up then power 2 sec and let volup

classic lk menu :

* [recovery	mode]
* [fastboot	mode]
* [normal	boot]

if you go recovery with stock recovery, power then vol up to skip "no command logo" 

If you need to unlock, go fastboot mode, then on PC : 

```
$ fastboot flashing unlock
$ fastboot reboot
```

But you will get this advise on every boot until you'll lock it.
```
your device has been unlocked and can't be trusted
your device will boot in 5 seconds
```

## Root the phone 

### using Magisk

You could now install Magisk, and provided the recovery.bin dumped image (this one use ramdisk), then use it to flash the boot partition (using mtkclient or fastboot). Magisk's trick is to use the ramdisk to add superuser capabilities, in order to avoid having to modify the system partition.

see https://android.stackexchange.com/questions/213167/how-does-magisk-work

### fixing system partition

Since you're not expecting any more updates for these phones anyway, you might as well modify the system partition directly. [TODO]

## Activate developer mode / ADB

Parameters => system => a propos du telephone => numero de build => click 7 times on
Parameters => system => options pour les developpeurs => debogage USB

## Cleanup your ROM

Like a large number of mobiles built in these years, it is compromised by the spyware [adups fota](https://securityblog.switch.ch/2017/02/28/adups-the-spy-in-your-pocket/). I'd recommand to use to [uda-ng](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) to clean up the rom on your PC via adb connection.

This repository provides a list of packages.
```
diff <(adb shell pm list packages) <(adb shell pm list packages -u) -n | grep ^package: | cut -c 9- > packages_uninstall.lst
```

## Build a custom twrp recovery ROM

download latest image on https://eu.dl.twrp.me/seedmtk/

```
unpack_bootimg --boot_img twrp-3.5.0_9-0-seedmtk.img --format mkbootimg --out recovery-twrp
```

fix fstab

```
mkdir -p twrp_ramdisk
cd twrp_ramdisk
gunzip -c ../ramdisk | cpio -idm
rg --files-with-matches mtk-msdc.0 | xargs sed -i 's/mtk-msdc.0/bootdevice/g'
find | cpio --create --format='newc' -R +0:+0 | gzip > ../ramdisk
```

```
$ unpack_bootimg --boot_img recovery.img --format mkbootimg --out recovery-eom
--header_version 1 --os_version 9.0.0 --os_patch_level 2021-08 --kernel out/kernel --ramdisk out/ramdisk --recovery_dtbo out/recovery_dtbo --pagesize 0x00000800 --base 0x00000000 --kernel_offset 0x40008000 --ramdisk_offset 0x45000000 --second_offset 0x40f00000 --tags_offset 0x44000000 --board '' --cmdline 'bootopt=64S3,32S1,32S1 buildvariant=user veritykeyid=id:7e4333f9bba00adfe0ede979e28ed1920492b40f'

$ mv ramdisk out/

$ mkbootimg --header_version 1 --os_version 9.0.0 --os_patch_level 2021-08 --kernel out/kernel --ramdisk out/ramdisk --recovery_dtbo out/recovery_dtbo --pagesize 0x00000800 --base 0x00000000 --kernel_offset 0x40008000 --ramdisk_offset 0x45000000 --second_offset 0x40f00000 --tags_offset 0x44000000 --board '' --cmdline 'bootopt=64S3,32S1,32S1 buildvariant=user veritykeyid=id:7e4333f9bba00adfe0ede979e28ed1920492b40f' --output twrp-nevastart.bin
```

=> yet not very functionnal ? anyway, this twrp doesn't offer much since we have
mtkclient...


## Customize the bootanimation

see https://www.rigacci.org/wiki/doku.php/doc/appunti/android/logo_bootanimation

https://www.mediafire.com/file/j1i3wu842onj212/Bootanimations%252BPreviews_229.zip/file

mount -o rw,remount /
/system/media/bootanimation.zip
$ cat desc.txt 
480 960 15
p 1 25 folder1
p 0 2 folder2

## NFC 

The phone has a NXP pn553 chipset, this could be exploitable via
https://github.com/Iskuri/PN553-Signature-Bypass to add features.

## 🪶 AUTHOR

Bignaux Ronan