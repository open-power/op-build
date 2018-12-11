Introduction to OpenPOWER Firmware
==================================

The ``op-build`` project constructs a host firmware image for OpenPOWER
machines.

Firmware Components
-------------------

Buildroot_
  We use http://buildroot.net/ as the build system for assembling a firmware
  image. `op-build` is a "Buildroot overlay". We build a kernel and initramfs
  using buildroot to run the Petitboot boot loader in. We maintain a branch
  with a minimum number of patches on top of upstream buildroot.
SBE_
  the Self Boot Engine is the first unit inside the POWER processor to start
  executing. It's job is to set up a core and load Hostboot.
Hostboot_
  Low level system boot firmware. It brings up CPU cores, the OCC, Memory
  and hands control over to OPAL (skiboot)
OCC_
  The On Chip Controller is responsible for thermal limits and frequency
  management.
OPAL
  The OpenPOWER Abstraction Layer, provided by skiboot
skiboot_
  skiboot implements OPAL (the OpenPOWER Abstraction Layer). Skiboot is
  boot and runtime firmware and is responsible for bringing up PCI and
  providing runtime abstractions to the running OS.
Linux_
  Once skiboot has finished setting up the machine, it hands control over
  to a Linux kernel. This kernel provides device drivers and userspace to
  run the bootloader, Petitboot. We maintain our own branch with a minimal
  number of patches on top of the latest upstream stable release.
Petitboot_
  The bootloader. It is a normal user-space process running on Linux that
  searches the system for disks and network devices that it can boot the
  OS from.

.. _Buildroot: https://github.com/open-power/buildroot
.. _SBE: https://github.com/open-power/sbe
.. _OCC: https://github.com/open-power/occ
.. _Hostboot: https://github.com/open-power/hostboot
.. _skiboot: https://open-power.github.io/skiboot/
.. _Linux: https://github.com/open-power/linux
.. _Petitboot: https://github.com/open-power/petitboot/
