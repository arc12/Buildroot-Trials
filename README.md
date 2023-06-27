This repository contains notes and output from an investigation into using Buildroot to generate SD card images for Raspberry Pi SBCs. The motivations include:
- possible future creation of light-weight fast-booting Pis for specific purposes;
- exploring the feasibility of creating an embedded OS for other SBCs which have proliferated, esp cheap Chinese devices without a well-developed distribution;
- interest, esp to understand what goes on the embedded linux.

The repository is essentially the "out of tree" structure which can be used with buildroot (but only committing the config and bespoke script files, of course). i.e. it is what would be created using the O= command line argument to make *_defconfig (see Buildroot manual 8.5). Each directory in the repo comprises a Buildroot "project" with its own Makefile; `make menuconfig` and `make` are run with the project directory as the working directory. To this, I have added notes on the exploration as various markdown files.

_This is essentially MY notes for future reference, so includes things which reflect MY setup and my level of understanding; it is not a tutorial._

There are two "projects":
- Base = what gets created by `make raspberrypi.def_config O=~/Buildroot/Base`. For observations, see [Base.md](Base/Base.md).
- BasePlus is a fairly minimal set of additions to the Base config which explores the "how to" of some things which I think would be essential for an embedded linux device (as I would use such). Notes on the changes, findings, and some things which were not done are in [BasePlus.md](BasePlus/BasePlus.md).

## Practical Notes
Buildroot 2023.02 was used.  
The "out of tree" location is ~/Buildroot.  
I am using an old Raspberry Pi model B.

### Buildroot Installation
Setting up a VM using vagrant and Hyper-V turned out to be quite convenient and easy once I changed the "vagrantfile" to change "ubuntu/bionic64" to "hashicorp/bionic64". No hassle installing dependencies; the VM just works!

The username and password for the VM are "vagrant". A normal SSH terminal is better than the crap in Hyper-V manager.

### Serial Connection to Pi
In the first instance, especially for the Base project, which has no SSH, use of serial-USB adapter + kitty/putty will be required. Port speed should be 115200.

RPi header pins (even numbers are at board edge, with 2 at the corner):
6 = GND
8 = TX
10 = RX

### Approach to Out-of-Tree
The OOT directory is essentially for the project-specific .config and the output. I have avoided copying things from the Buildroot installation files. So, for example, the post-build.sh which comes with Buildroot remains in the boards/raspberrypi directory and an additional post-build script is created in the project.