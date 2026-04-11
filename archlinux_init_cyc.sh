#!/bin/bash
cdpwd=$(dirname "$(readlink -f "$0")")
cd "${cdpwd}" || exit 

#
#
#
export github_proxy="https://ghfast.top"
export dockerhub_proxy="https://docker.m.daocloud.io"

#
#
#
echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist
sudo sed -i '/archlinuxcn/d' /etc/pacman.conf
echo -e '[archlinuxcn]\nServer = https://mirrors.aliyun.com/archlinuxcn/$arch' | sudo tee -a /etc/pacman.conf

#
#
#
#
#pip
mkdir -p ~/.pip/ && cat <<'EOF' | tee ~/.pip/pip.conf >/dev/null
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF


#
#
#
#git
cat <<EOF | tee ~/.gitconfig >/dev/null
[user]
	email = cyc_archlinux_dev
	name = cyc_archlinux_dev
[init]
	defaultBranch = main
[url "https://github.com/lglgdouble/"]
	insteadOf = https://github.com/lglgdouble/
[url "${github_proxy}/https://github.com/"]
	insteadOf = https://github.com/
EOF

#
#
#
sudo pacman -Syu --noconfirm --needed networkmanager openssh
sudo systemctl enable NetworkManager
sudo systemctl enable sshd
sudo nmcli device status
sudo nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses "192.168.1.100/24" \
  ipv4.gateway "192.168.1.1" \
  ipv4.dns "192.168.1.1"
sudo systemctl restart NetworkManager
sudo systemctl restart sshd


##
##
##
#
#
sudo pacman -Sy --noconfirm --needed archlinuxcn-keyring 
sudo pacman -Sy --noconfirm --needed \
	paru vi man-db sudo lsof dos2unix base-devel bash-completion \
  git \
  python python-pip python-pipx \
  

#
#
#
#
#https://github.com/ultrafunkamsterdam/nodriver
paru -Sy --noconfirm --needed \
  google-chrome
sudo pacman -Sy --noconfirm --needed xorg-server-xvfb



#
#
#https://v2raya.org/
paru -Sy --noconfirm --needed v2raya
sudo systemctl enable v2raya
sudo lsof -i:2017




#
#
#https://localsend.org/zh-CN
#https://github.com/meowrain/localsend-go
#https://github.com/SykikXO/jocalsend
paru -Sy --noconfirm --needed localsend-bin jocalsend localsend-go #可能需要设置http代理，git下载慢


