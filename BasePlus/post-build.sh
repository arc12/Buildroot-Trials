TARGETDIR=$1
BR_ROOT=$PWD
FW_DIR=$TARGETDIR/../images/rpi-firmware

# make or use a backup of the vanilla fstab so that we don't append each time "make" is done
# if [ -e ${TARGET_DIR}/etc/fstab_bak ]; then
#   cp ${TARGET_DIR}/etc/fstab_bak ${TARGET_DIR}/etc/fstab
# else
#   cp ${TARGET_DIR}/etc/fstab ${TARGET_DIR}/etc/fstab_bak
# fi

# create an empty /boot directory in target
install -d -m 0755 $TARGETDIR/boot

# setup mount for /boot
# use a special marker in a comment on the line to avoid multiple appends each time
# "make" is done
MARKER="# !!post-build:mount-boot"
if ! grep -wq "$MARKER" $TARGETDIR/etc/fstab; then
  echo 'adding mount for /boot to fstab'
  echo '/dev/mmcblk0p1	/boot	vfat	defaults	0	0 ' $MARKER >> $TARGETDIR/etc/fstab
fi

# same for home (see also the use of genimage in the post-image script)
install -d -m 0755 $TARGETDIR/home
MARKER="# !!post-build:mount-home"
if ! grep -wq "$MARKER" $TARGETDIR/etc/fstab; then
  echo 'adding mount for /home to fstab'
  echo '/dev/mmcblk0p3  /home   ext4    defaults        0       0 ' $MARKER >> $TARGETDIR/etc/fstab
fi

# enable I2C kernel module
MARKER="# !!post-build:i2c"
if ! grep -wq "$MARKER" $FW_DIR/config.txt; then
  echo 'adding i2c to config.txt'
  echo 'dtparam=i2c_arm=on ' $MARKER >> $FW_DIR/config.txt
fi

# automatically load the I2C modules on boot. this may not be necessary in all cases but is convenient
# for tinkering and it illustrates a "How to"
cat > $TARGETDIR/etc/init.d/S99modules<<EOF
modprobe i2c-dev
modprobe i2c-bcm2835
EOF
chmod +x $TARGETDIR/etc/init.d/S99modules
