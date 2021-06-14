.. _versioning:

Version Scheme
==============

Each firmware component has its own versioning scheme, and `op-build` brings
all of these components together in one image with one global version
number.

Firmware versions are exposed to the user through both the device tree
(:ref:`skiboot:device-tree/ibm,firmware-versions`) and the VERSION firmware
partition. As such, firmware versioning numbers **MUST** follow the
requirements in order for some functionality to be correct.

skiboot
  :ref:`skiboot:versioning`
Hostboot
  Currently just uses the git SHA1 of the commit
OCC
  Currently just uses the git SHA1 of the commit
Petitboot
  Uses a X.Y.Z versioning scheme.
Linux
  We use the upstream Linux kernel version, and always append ``-openpowerN``
  where N is a number starting at 1 that increases for each change we make
  to any additional patches carried in `op-build` for that specific kernel
  version.
  We follow the stable tree and have an "upstream *first*" policy in place.

