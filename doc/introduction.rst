Introduction to OpenPOWER Firmware
==================================

The ``op-build`` project constructs a host firmware image for OpenPOWER
machines.

Firmware Components
-------------------

Buildroot
  We use http://buildroot.net/ as the build system for assembling a firmware
  image. `op-build` is a "Buildroot overlay". We build a kernel and initramfs
  using buildroot to run the Petitboot boot loader in.
SBE
  the Self Boot Engine is the first unit inside the POWER processor to start
  executing. It's job is to set up a core and load Hostboot.
Hostboot
  Low level system boot firmware. It brings up CPU cores, the OCC, Memory
  and hands control over to OPAL (skiboot)
OCC
  The On Chip Controller is responsible for thermal limits and frequency
  management.
OPAL
  The OpenPOWER Abstraction Layer, provided by skiboot
skiboot
  skiboot implements OPAL (the OpenPOWER Abstraction Layer). Skiboot is
  boot and runtime firmware and is responsible for bringing up PCI and
  providing runtime abstractions to the running OS.
Linux
  Once skiboot has finished setting up the machine, it hands control over
  to a Linux kernel. This kernel provides device drivers and userspace to
  run the bootloader, Petitboot
Petitboot
  The bootloader. It is a normal user-space process running on Linux that
  searches the system for disks and network devices that it can boot the
  OS from.
