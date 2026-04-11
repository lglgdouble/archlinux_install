#!/bin/bash
cdpwd=$(dirname "$(readlink -f "$0")")
cd "${cdpwd}" || exit 1

#
#
#如果是虚拟机把固件类型设为uefi
#
#
#

#
#
#
read -p "确认继续？(y/n): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo "执行..."
else
    echo "取消操作"
    exit 3
fi

#
#
#
echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
sed -i '/archlinuxcn/d' /etc/pacman.conf
echo -e '[archlinuxcn]\nServer = https://mirrors.aliyun.com/archlinuxcn/$arch' >>/etc/pacman.conf

#
#
#这里要改变disk
disk="/dev/sda"
efi="${disk}1"
swap="${disk}2"
root="${disk}3"

echo 'label: gpt' | sfdisk ${disk}
cat << EOF | sfdisk ${disk}
label: gpt
${efi} : size=2G, type=U, name=efi
${swap} : size=12G, type=S, name=swap
${root} : type=L, name=root
EOF

mkfs.ext4 -F ${root}
mkswap ${swap}
mkfs.fat -F 32 ${efi}

mount --mkdir ${root} /mnt
mount --mkdir ${efi} /mnt/boot
swapon ${swap}

pacstrap -K /mnt base linux linux-firmware || exit 110
genfstab -U /mnt >> /mnt/etc/fstab


#
#
#
#
cat <<'EOF' | tee ./archlinux_init_root.sh >/dev/null
#!/bin/bash
cdpwd=$(dirname "$(readlink -f "$0")")
cd "${cdpwd}" || exit 1

echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
sed -i '/archlinuxcn/d' /etc/pacman.conf
echo -e '[archlinuxcn]\nServer = https://mirrors.aliyun.com/archlinuxcn/$arch' >>/etc/pacman.conf

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/; s/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >/etc/locale.conf
echo 'yonan' >/etc/hostname
echo 'root' | passwd -s

pacman -Syu --noconfirm --needed sudo grub efibootmgr os-prober networkmanager openssh
systemctl enable NetworkManager
systemctl enable sshd


echo '%wheel ALL=(ALL:ALL) ALL' >/etc/sudoers.d/wheel && chmod --reference /etc/sudoers /etc/sudoers.d/wheel && chown --reference /etc/sudoers /etc/sudoers.d/wheel
useradd -m -s /bin/bash -G wheel cyc
echo 'cyc' | passwd -s cyc

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

chown cyc:cyc ./archlinux_init_cyc.sh && mv ./archlinux_init_cyc.sh /home/cyc/

EOF
chmod u+x ./archlinux_init_root.sh
cp ./archlinux_init_root.sh /mnt/root/
cp ./archlinux_init_cyc.sh /mnt/root/

#
#
#
arch-chroot /mnt
reboot