#!/bin/bash

BOOT_DISK="sda1"
FS_DISK="sda2"

# Disk Selection
lsblk

read -p "Continue To Format the Boot Disk? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    mkfs.fat -F32 /dev/$BOOT_DISK
elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping Formating Boot Disk"
fi

# Partition and setup install disk
read -p "Continue To Format the Install Disk? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    mkfs.btrfs /dev/$FS_DISK

    mount /dev/$FS_DISK /mnt
    # Create subvolumes
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@log
    btrfs subvolume create /mnt/@pkg
    btrfs subvolume create /mnt/@.snapshots
    
    ls /mnt
    umount /mnt

elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping Seting up Install Disk"
fi




# Mount Sub-Volumes
read -p "Continue To Mount the Install Disk? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
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

    lsblk

elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping Mounting the Install Disk"
fi

# Install essential packages
read -p "Continue Install Base System? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    pacstrap /mnt base base-devel linux linux-firmware btrfs-progs grub efibootmgr vim

elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping Install Base System"
fi

lsblk

# Generate fstab
read -p "Continue Generate fstab? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    genfstab -U /mnt >> /mnt/etc/fstab

    cat /mnt/etc/fstab
elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping Generate fstab"
fi


# Chroot into the new system
read -p "Chroot into the new system? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    arch-chroot /mnt
else
    exit 1
fi
