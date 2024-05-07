#!/bin/bash

BOOT_DISK="sda1"
FS_DISK="sda2"

# Partition the disk
mkfs.fat -F32 /dev/$BOOT_DISK
mkfs.btrfs /dev/$FS_DISK

# Mount the root partition
mount /dev/$FS_DISK /mnt

# Create subvolumes

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@.snapshots
umount /mnt

# Mount subvolumes
mount -o subvol=@ /dev/$FS_DISK /mnt

mkdir -p /boot/efi
mount /dev/$BOOT_DISK /mnt/boot/efi

mkdir -p /mnt/home
mount -o subvol=@home /dev/$FS_DISK /mnt/home

mkdir -p /mnt/var/log
mount -o subvol=@log /dev/$FS_DISK /var/log

mkdir -p /mnt/var/cache/pacman/pkg
mount -o subvol=@pkg /dev/$FS_DISK /var/cache/pacman/pkg

# Install essential packages
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs grub efibootmgr vim

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt
