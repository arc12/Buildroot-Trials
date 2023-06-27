# Notes on Extending the Base Image
Additions for my old v1 model B.

## Menuconfig Options for RPi
_These all refer to menu entries in `make menuconfig` UI._

### Build Options
Enable compiler cache = YES [object files built with a given command line (compiler configuration) are saved in a cache and are reused when the same object file is to be built again. This saves a lot of time with repeated builds (typical when tinkering).]

### System configuration
Change System hostname and System banner to something indicative ("adampi" and "Welcome to Adam Pi")

Enable root login with password.  
_Set a root password as this may be needed by SSH server (dropbear does); default is no password. Use "root" for testing._

### Target packages >>
Networking applications > dropbear [SSH server]  
Text editors > nano

## Filesystem 
Two issues are addressed: 1) that /boot is not mounted automatically; 2) that there is no /home/.

#1 is useful because manual edits to /boot/config.txt (followed by a reboot) are needed for tinkering with the boot setup.  
#2 is being done with a separate partition as this is how I would want to handle application code and sensor logging etc.

### Creating the partition for /home
This is being done with a very small partition size for testing. A small size is good from the POV of having a small sdcard.img to load on the SD Card (fast) and because the card capacity is unknown. Partition resizing on first use is not hard; see https://serverfault.com/questions/509468/how-to-extend-an-ext4-partition-and-filesystem.

This will be achieved with a post-image script using genimage. Note that this is "post-image" in the sense that buildroot considers "the image" to be the root fs. Genimage is run after this is created in order to generate the SD card image. Refer to [post-image.sh](post-image.sh).

The post-image.sh file is based on the file in board/rasperrypi. This should be usable for other projects by changing GENIMAGE_CFG only.

The required genimage config file is based on the relevant genimage-*.cfg file in board/rasperrypi, renamed genimage to genimage-{project}.cfg for clarity (also in the repo).

The changes to the genimage config are:  
1. below the image boot.vfat entry, and at the same level:
```
image home.ext4 {
        size = 10M
        empty = true
        temporary = true
        ext4 {
            label = "home"
            use-mke2fs = true
        }
}
```

2. within the image sdcard.img block, add a new partition below the boot entry:
```
partition home {
	partition-type = 0x83
	image = "home.ext4"
}
```

Finally, use `make menuconfig` to CHANGE the post-image script to the one in the out of tree project directory.

After running `make`, the sdcard image can be checked using: `fdisk -l images/sdcard.img`.

### Adding Mounts to /etc/fstab (using post-build script)
These are done by an additional post-build script in ~/Buildroot/BasePlus, which must have `chmod 755` applied.

The default config already executes board/raspberrypi/post-build.sh, see: System configuration > Custom scripts...

A second script can be added by appending the path to the custom script config, separated by a space character. The working directory when the script is run will be the buildroot in-tree root. I have opted to put my specialised scripts in the relevant out of tree project directory and to give an explicit path (I did try to use $TARGETDIR, but it failed) in `make menuconfig`.

An issue which must be overcome when using the post-build script is that it runs each time you `make`, so there is a likelyhood of appending multiple fstab entries for the same mount unless a countermeasure is taken. One approach suggested on the web is to copy $BR_ROOT/system/skeleton/etc/fstab, but I could not find that path. Hence, I have used special "markers" in a comment on added lines. See (post-build.sh)[post-build.sh].

## GPIO, I2C etc
For info on overlays in config.txt, see: https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README.

To enable I2C, add "dtparam=i2c_arm=on" to config.txt. This will take effect on next boot.
Load the kernel modules using:
```
modprobe i2c-dev
modprobe i2c-bcm2835
# modprobe i2c-bcm2708 # is given in some accounts but does not seem to work
# modprobe spi-bcm2835 # if SPI is required... 
```
Now `i2cdetect 1` should find connected devices

Presumably, the settings which make the serial terminal work should be changed to allow for normal UART working. See /boot/cmdline.txt as well as looking at the dtparam/overlay docs. There may be more, however: see /etc/inittab!

The kernel modules may be auto-loaded on boot by doing the following (an alt which I have not done is using the fs overlay feature). Alter the post-build.sh script to create a file /etc/init.d/S99modules in $TARGETDIR containing the modprobe commands and `chmod +x` that file. The section in post-build.sh is:
```
cat > $TARGETDIR/etc/init.d/S99modules<<EOF
modprobe i2c-dev
modprobe i2c-bcm2835
EOF
chmod +x /etc/init.d/S99modules
```

Assuming busybox is handling init then S99modules will be run from /etc/init.d/rcS

## Things not done
System > Locales (etc) + timezone

System > Path to the users tables [how to create non-root users - see manual]

Target > look through all! look in "Hardware handling" for I2C, GPIO, etc  
!! note that some packages (e.g. i2c-tools) are not shown in menuconfig unless Target packages > Show packages that are also provided by busybox = YES

Host utilities > lots of good stuff. Python is somewhere here + mosquitto, zip ...

pigpio

Configure raspi-gpio = YES in Target packages > Hardware handling via `make menuconfig`. ["Tool to help debug / hack at the BCM283x GPIO. You can dump the state of a GPIO or (all GPIOs). You can change a GPIO mode and pulls (and level if set as an output)."]