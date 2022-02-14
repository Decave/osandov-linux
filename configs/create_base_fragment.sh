#!/bin/bash
# SPDX-FileCopyrightText: Omar Sandoval <osandov@osandov.com>
# SPDX-License-Identifier: MIT

set -euo pipefail

# Options that the distro config may override but we want to use the default
# for.
default_options=(
	'ATA'
	'BLK_DEV_NVME'
	'CONSOLE_LOGLEVEL[^=]*'
	'DEBUG_INFO_BTF'
	'DEFAULT_HOSTNAME'
	'GCC_PLUGIN_STRUCTLEAK[^=]*'
	'HID'
	'HYPERVISOR_GUEST'
	'LEDS_CLASS'
	'LOCALVERSION'
	'MODULE_COMPRESS[^=]*'
	'MODULE_SIG[^=]*'
	'NVM'
	'NVME_CORE'
	'SCSI'
	'SECURITY_LOCKDOWN_LSM[^=]*'
	'USB'
	'VFIO'
)

trap 'rm -f .config lsmod defconfig' EXIT

zcat -f "${1:-/proc/config.gz}" |
	grep -v -E "$(IFS="|"; echo "^CONFIG_(${default_options[*]})=")" > .config
make olddefconfig

# Disable all (non-built-in) modules.
echo "Module                  Size  Used by" > lsmod
make LSMOD=lsmod localmodconfig
make savedefconfig

echo "# Generated defconfig" > base.fragment
echo "silent" >> base.fragment
cat defconfig - << "EOF" >> base.fragment
endsilent

# General sanity.
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_LOCALVERSION_AUTO=y

# Module compression makes kernel installation really slow and makes it harder
# to use debugging tools.
CONFIG_MODULE_COMPRESS=n

# Debugging.
CONFIG_BPF_KPROBE_OVERRIDE=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_DWARF4=y
CONFIG_DEBUG_KERNEL=y
CONFIG_KPROBES=y
CONFIG_KPROBE_EVENTS=y
CONFIG_UPROBES=y
CONFIG_UPROBE_EVENTS=y

# Filesystems.
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_EXT4_FS=m
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_FUSE_FS=m
CONFIG_ISO9660_FS=m
CONFIG_NLS_CODEPAGE_437=m
CONFIG_NLS_ISO8859_1=m
CONFIG_SQUASHFS=m
CONFIG_SQUASHFS_DECOMP_MULTI=y
CONFIG_SQUASHFS_FILE_DIRECT=y
CONFIG_SQUASHFS_LZ4=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_XZ=y
CONFIG_SQUASHFS_ZLIB=y
CONFIG_VFAT_FS=m
CONFIG_XFS_FS=m
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_RT=y

# NFS.
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_V4_SECURITY_LABEL=y
CONFIG_NFS_FS=m
CONFIG_NFS_FSCACHE=y
CONFIG_NFS_SWAP=y
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_1_MIGRATION=y
CONFIG_NFS_V4_2=y
CONFIG_NFS_V4_SECURITY_LABEL=y

# Block devices.
CONFIG_ATA=m
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_NULL_BLK=m
CONFIG_BLK_DEV_NVME=m
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_SG=m
CONFIG_SCSI=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_SCSI_MOD=m
CONFIG_SCSI_SCAN_ASYNC=y
EOF
