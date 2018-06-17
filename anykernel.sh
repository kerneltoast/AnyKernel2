# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Sultan Kernel for the Pixel 2 and Pixel 2 XL
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=taimen
device.name2=walleye
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;


# Detect whether we're in recovery or booted up
ps | grep zygote | grep -v grep >/dev/null && in_recovery=false || in_recovery=true;
! $in_recovery || ps -A 2>/dev/null | grep zygote | grep -v grep >/dev/null && in_recovery=false;
! $in_recovery || id | grep -q 'uid=0' || in_recovery=false;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel install
split_boot;


# Mount system to get some information about the user's setup (only needed in recovery)
if $in_recovery; then
  umount /system;
  umount /system 2>/dev/null;
  mkdir /system_root 2>/dev/null;
  mount -o ro -t auto /dev/block/bootdevice/by-name/system$slot /system_root;
  mount -o bind /system_root/system /system;
fi;


# Patch dtbo.img on custom ROMs
username="$(file_getprop /system/build.prop "ro.build.user")";
echo "Found user: $username";
case "$username" in
  "android-build") user=google;;
  *) user=custom;;
esac;
hostname="$(file_getprop /system/build.prop "ro.build.host")";
echo "Found host: $hostname";
case "$hostname" in
  *corp.google.com|abfarm*) host=google;;
  *) host=custom;;
esac;
if [ "$user" == "custom" -o "$host" == "custom" ]; then
  if [ ! -z /tmp/anykernel/dtbo.img ]; then
    ui_print " "; ui_print "You are on a custom ROM, patching dtbo to remove verity...";
    if $in_recovery; then
      # Temporarily block out all custom recovery binaries/libs
      mv /sbin /sbin_tmp;
      # Unset library paths
      OLD_LD_LIB=$LD_LIBRARY_PATH;
      OLD_LD_PRE=$LD_PRELOAD;
      unset LD_LIBRARY_PATH;
      unset LD_PRELOAD;
    fi;
    $bin/magiskboot --dtb-patch /tmp/anykernel/dtbo.img;
    if $in_recovery; then
      mv /sbin_tmp /sbin 2>/dev/null;
      [ -z $OLD_LD_LIB ] || export LD_LIBRARY_PATH=$OLD_LD_LIB;
      [ -z $OLD_LD_PRE ] || export LD_PRELOAD=$OLD_LD_PRE;
    fi;
  fi;
else
  ui_print " "; ui_print "You are on stock, not patching dtbo to remove verity!";
fi;


# Unmount system
if $in_recovery; then
  umount /system;
  umount /system_root;
  rmdir /system_root;
  mount -o ro -t auto /system;
fi;


# Install the boot image
flash_boot;
