# Set the variables appropriately
# Don't forget to set the variable PASS for admin and user password
TIME_ZONE="Asia/Kuala_Lumpur"
HOST_NAME="arch"
USER_PASS="pass"

read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Timezone
echo "Executing 'ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime'"
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
ls -al /etc | grep "localtime"


# Time Setup
read -p "Time zone selected, Continue to setup time? (Y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    hwclock --systohc
    timedatectl set-local-rtc 1 --adjust-system-clock
    timedatectl
elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping Time Setup"
fi


# Local Gen
read -p "Time setup complete, Continue to setup local? (Y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

    cat /etc/locale.gen
    cat /etc/locale.conf
elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping setup local"
fi


# Set the hosts file
read -p "Local setup complete, Continue to setup hosts? (Y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    echo "127.0.0.1	localhost
    ::1		localhost
    127.0.1.1	$HOST_NAME.localdomain	$HOST_NAME" >> /etc/hosts

    cat /etc/hosts
elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping setup hosts"
fi


# Set the Passwords
read -p "Hosts setup complete, Continue to setup password? (Y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    echo "root:$USER_PASS" | chpasswd

    useradd -m -G wheel black
    echo "black:$USER_PASS" | chpasswd

    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/black
    
    cat /etc/sudoers.d/black | grep "%wheel ALL=(ALL) ALL"
elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping setup password"
fi


# Install and configure grub
read -p "Password setup complete, Continue to setup Grub? (Y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    
    grub-mkconfig -o /boot/grub/grub.cfg

    ls -al /boot/efi

elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping setup GRUB"
fi


# Install necessary packages
pacman -Sy networkmanager # Add other packages as required

# Enable NetworkManager
read -p "Install complete, Continue to Network Manager Auto Start? (Y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]
then
    systemctl enable NetworkManager

elif [[ $confirm == [nN] || $confirm == [nN][oO] ]]
then
    exit 1
else
    echo "Skiping setup Network Manager Auto Start"
fi

exit 1
