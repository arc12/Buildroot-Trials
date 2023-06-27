# Notes on the Base Image
_Vanilla, using the .config created using raspberrypi.def_config._

The command to shutdown is `halt`.

The default hostname = "buildroot"

## Network/comms
Serial works fine with baud rate 115200.

Actually, the raspberrypi_defconfig DOES have network! (and since I set a fixed IP address on the router the IP is the same whatever OS is on the MAC).

## File system
Filesystem seems incomplete:
```
# df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/root               109525     59956     40968  59% /
devtmpfs                168848         0    168848   0% /dev
tmpfs                   201828         0    201828   0% /dev/shm
tmpfs                   201828        28    201800   0% /tmp
tmpfs                   201828        20    201808   0% /run
```
And there is no /home

/dev/mmcblk0p1 is unmounted and contains the "/boot" stuff (start.elf etc).  
/dev/mmcblk0p2 is already mounted as the rootFS.


## GPIO etc
### On-board LED
There are supposed to be "GPIO LED" and "LED trigger" modules. These all work:
```
echo default-on > /sys/devices/platform/leds/leds/led0/trigger
echo heartbeat > /sys/devices/platform/leds/leds/led0/trigger
echo none > /sys/devices/platform/leds/leds/led0/trigger
```

### GPIO
There is a directory /sys/class/gpio

Manual working with GPIO:
```
# make GPIO4 be an input
echo "4" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio4/direction
# read value (I think pulled up; I got a 1 with pin not attached)
cat /sys/class/gpio/gpio4/value
# set GPIO4 low then check we read 0:
cat /sys/class/gpio/gpio4/value
# clean up
echo "4" > /sys/class/gpio/unexport
```

## I2C
The base image does have i2c-tools (e.g. i2cdetect) as part of BusyBox BUT I don't think any I2C buses are enabled (try `i2cdetect -l`). Running `make linux-menuconfig` and checking in "Device drivers" shows I2C is included in the kernel.

This page - https://openest.io/en/services/activate-raspberry-pi-4-i2c-bus/ - has some info but the path to the config.txt file does not exist. That file may be found in the out of tree area - e.g. ~/Buildroot/BasePlus/images/rpi-firmware - but is not created by `make raspberrypi_defconfig`.

## Questions!
System > Init system: is "BusyBox" and alternatives are "systemV", "OpenRC", "systemd", and None. What is this about? What should I choose?  
_General recommendation seems to be to use BusyBox for embedded systems, so I will continue with the default._

System > /dev management:
```
( ) Static using device table
(X) Dynamic using devtmpfs only
( ) Dynamic using devtmpfs + mdev
( ) Dynamic using devtmpfs + eudev
```
One source says of "... + mdev": "this pseudo fs is automatically populated when Linux detects new hardware."  
_I think this may be to do with "hot-plugging" support._