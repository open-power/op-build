Supported Boot Devices
======================

The OpenPower firmware uses Linux as a bootloader in order to discover boot
devices, and boot the final operating system. In order to discover boot devices
and load the operating system image from them, the bootloader's kernel needs to
include support for that hardware.

This table lists the network adaptors and disk controllers that are currently
enabled.

If you are adding a device to the kernel, please add the details here including
your email address in the owner field. We will use this to contact users when
considering the removal of modules.

Likewise, if you are removing an option from the kernel config, please remove
it from this table and notify the person mentioned in the owner field.

+-------------------------------+-----------------------+--------+----------------------------+
| Device name                   | Kconfig option        | System | Owner                      |
+===============================+=======================+========+============================+
| AOC-SG-I2 NIC                 | IGB                   | Boston | maurosr@linux.vnet.ibm.com |
+-------------------------------+-----------------------+--------+----------------------------+
| Broadcom NetExtreme II        | BNX2X                 |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Mellanox ConnectX-4           | MLX5_CORE_EN          |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Alteon AceNIC                 | ACENIC                |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Broadcom Tigon3               | TIGON3                |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Chelsio 10Gb Ethernet         | CHELSIO_T1            |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| SeverEngine BladeEngine 10Gb  | BE2NET                |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Exar Xframe 10Gb              | S2IO                  |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Intel PRO/1000 PCIe           | E1000E                |        |                            |
| Intel PRO/1000                | E1000                 | Qemu   | stewart@linux.vnet.ibm.com |
+-------------------------------+-----------------------+--------+----------------------------+
| Intel PRO/10GbE               | IXGB                  |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Intel 10GbE PCIe              | IXGBE                 |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Intel XL710 Ethernet          | I40E                  | P9DSU  | jk@ozlabs.org              |
+-------------------------------+-----------------------+--------+----------------------------+
| Mellanox 1/10/40Gbit Ethernet | MLX4_EN               |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Myricom Myri-10G Ethernet     | MYRI10GE              |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| QLogic QLGE 10Gb Ethernet     | QLGE                  |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| NetXen Gigabit Ethernet       | NETXEN_NIC            |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Adaptec AACRAID               | SCSI_AACRAID          |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| QLogic BNX2                   | SCSI_BNX2_ISCSI       |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Chelsio T3 iSCSI              | SCSI_CXGB3_ISCSI      |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| Chelsio T4 iSCSI              | SCSI_CXGB4_ISCSI      |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| LSI Logic MegaRAID            | MEGARAID_NEWGEN       |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| LSI MPT Fusion SAS (legacy)   | SCSI_MPT2SAS          |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| QLogic QLA2xxx Fibrechannel   | SCSI_QLA_FC           |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
| QLogic ISP4xxx and ISP82xxx   | SCSI_QLA_ISCSI        |        |                            |
+-------------------------------+-----------------------+--------+----------------------------+
