$BOOT_PARTITION="/dev/sdx"
$ROOT_PARTITION="/dev/sdy"

mount_disk() {
    mount -o noatime,ssd,compress=zstd:3,space_cache=v2,subvol=@ "$ROOT_PARTITION" /mnt

    mkdir -p /boot/efi
    mount --mkdir "$BOOT_PARTITION" /mnt/boot/efi

    mkdir -p /mnt/home
    mount -o noatime,ssd,compress=zstd:3,space_cache=v2,subvol=@home "$ROOT_PARTITION" /mnt/home

    mkdir -p /mnt/var/log
    mount -o noatime,ssd,compress=zstd:3,space_cache=v2,subvol=@log "$ROOT_PARTITION" /mnt/var/log

    mkdir -p /mnt/var/cache/pacman/pkg
    mount -o noatime,ssd,compress=zstd:3,space_cache=v2,subvol=@pkg "$ROOT_PARTITION" /mnt/var/cache/pacman/pkg
}

main() {
    mount_disk

    arch-chroot /mnt
}

# Execute the script
main "$@"