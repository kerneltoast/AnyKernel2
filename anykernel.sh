# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Enable Hall Sensor for the Pixel 2 and Pixel 2 XL
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

# Extract boot
split_boot;

# Append command line option
echo -n " uinput.enable_hall_ic=1" >> "$split_img/boot.img-cmdline"

# Flash modified boot
flash_boot;
