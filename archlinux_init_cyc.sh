#!/bin/bash
cdpwd=$(dirname "$(readlink -f "$0")")
cd "${cdpwd}" || exit 

#
#
#
export cdpwd
export self_github_proxy="https://ghfast.top"
export dockerhub_proxy="https://docker.m.daocloud.io"

#
#
#
sudo ls -l || exit 111
echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
sudo sed -i '/archlinuxcn/d' /etc/pacman.conf
echo -e '[archlinuxcn]\nServer = https://mirrors.aliyun.com/archlinuxcn/$arch' | sudo tee -a /etc/pacman.conf >/dev/null

#
#
#
cat <<EOF | sudo tee /etc/profile.d/proxy.sh >/dev/null
#!/bin/bash
export self_github_proxy="${self_github_proxy}"
EOF

#
#
#
sudo pacman -Sy --noconfirm --needed archlinuxcn-keyring || exit 111
sudo pacman -Sy --noconfirm --needed paru || exit 111
sudo pacman -Sy --noconfirm --needed \
    networkmanager openssh \
    git vi man-db sudo lsof dos2unix base-devel bash-completion unzip \
    || exit 111
sudo systemctl enable NetworkManager
sudo systemctl enable sshd

#
#
#
#curl
change_curl="1"
sudo pacman -Sy --noconfirm curl
if [ "$change_curl" = "" ]; then
    echo "。。。。。。。。。。。。。恢复curl"
else
    echo "。。。。。。。。。。。。。改变curl"
    curl=$(readlink -f $(which curl))
    old_curl=${curl}_old
    sudo mv ${curl} ${old_curl}

cat <<'EOF' | sudo tee ${curl} >/dev/null
#!/bin/bash
arg=""
while [ $# != 0 ]; do
    case "$1" in
    https://raw.githubusercontent.com*)
        xx=${1/#"https://raw.githubusercontent.com/"/"${self_github_proxy}/https://raw.githubusercontent.com/"}
        arg="${arg} $xx"
        ;;
    https://github.com*)
        xx=${1/#"https://github.com/"/"${self_github_proxy}/https://github.com/"}
        arg="${arg} $xx"
        ;;
    *)
        arg="${arg} $1"
        ;;
    esac
    shift
done
echo "$(date '+%Y-%m-%d %H:%M:%S')  -->$(pwd) -->  ${arg}"  | tee -a /tmp/new_curl.log >/dev/null
curl_old ${arg}
EOF
    sudo chmod --reference ${old_curl} ${curl} && sudo chown --reference ${old_curl} ${curl}
fi

#
#
#
#git
sudo pacman -Sy --noconfirm --needed  git
git config --global user.name "cyc_archlinux_dev"
git config --global user.email "cyc_archlinux_dev"
git config --global init.defaultBranch main
git config --global url."https://github.com/lglgdouble/".insteadOf "https://github.com/lglgdouble/"
git config --global url."${self_github_proxy}/https://github.com/".insteadOf "https://github.com/"

#
#
#
#python
#https://mirrors.tuna.tsinghua.edu.cn/help/pypi/
sudo pacman -Sy --noconfirm --needed   python python-pip python-pipx 
pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

#
#
#
#go
#https://goproxy.cn/
sudo pacman -Sy --noconfirm --needed  go
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct

#
#
#
#npm
#https://npmmirror.com/
sudo pacman -Sy --noconfirm --needed  npm
npm config set registry https://registry.npmmirror.com

#
#
#
#zsh
#https://github.com/ohmyzsh/ohmyzsh/wiki
sudo pacman -Sy --noconfirm --needed  zsh  zsh-completions
sh -c "$(curl -fsSL https://install.ohmyz.sh)"
sed -i 's#plugins=(git)#plugins=(git z)#g' ~/.zshrc

#
#
#
#yazi
#https://yazi-rs.github.io/docs/installation
#https://github.com/ryanoasis/nerd-fonts
sudo pacman -Sy --noconfirm --needed yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick ttf-jetbrains-mono-nerd
sudo fc-cache -f
cat <<'EOF' | sudo tee /etc/profile.d/yazi.sh >/dev/null
#!/bin/bash
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
EOF

#
#
#
#fastfetch
function add_fastfetch() {
    #https://github.com/AnabasaSoft/fastfetch-configurator
    fastfetchconfigstr="alias fastfetch_config='(git clone https://github.com/AnabasaSoft/fastfetch-configurator.git ~/.fastfetch-configurator; cd ~/.fastfetch-configurator; python -m venv .venv; source .venv/bin/activate; pip install PyQt6 ansi2html; python main.py)'"
    ftmpystr="alias fastfetch_ftm='(bash <(curl -fsSL https://raw.githubusercontent.com/itz-dev-tasavvuf/fastfetch-theme-manager/main/install.sh); ~/.local/bin/ftm pick)'" #https://github.com/tasavvuf/fastfetch-theme-manager
    fastcatstr="alias fastfetch_cat='(git clone https://github.com/m3tozz/FastCat.git ~/.FastCat; cd ~/.FastCat; bash ./install-icons.sh; bash ./fastcat.sh --shell)'" #https://github.com/m3tozz/FastCat
    sed -i '/fastfetch_config/d' $1
    sed -i '/fastfetch_ftm/d' $1
    sed -i '/fastfetch_cat/d' $1
    echo ${fastfetchconfigstr} >> $1
    echo ${ftmpystr} >> $1
    echo ${fastcatstr} >> $1
}
sudo pacman -Sy --noconfirm --needed fastfetch
add_fastfetch ~/.bashrc
add_fastfetch ~/.zshrc

#
#
#
#nodriver 爬虫网页
#https://github.com/ultrafunkamsterdam/nodriver
paru -Sy --noconfirm --needed   google-chrome
sudo pacman -Sy --noconfirm --needed xorg-server-xvfb

#
#
#
#v2raya
#https://v2raya.org/
paru -Sy --noconfirm --needed v2raya
sudo systemctl enable v2raya
sudo lsof -i:2017

#
#
#
#localsend
#https://localsend.org/zh-CN
#https://github.com/meowrain/localsend-go
#https://github.com/SykikXO/jocalsend
paru -Sy --noconfirm --needed localsend-bin jocalsend localsend-go #可能需要设置http代理，git下载慢

exit 123
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#niri
#https://danklinux.com/
#https://wiki.archlinux.org/title/VMware/Install_Arch_Linux_as_a_guest
sudo pacman -Sy --noconfirm --needed  sddm  open-vm-tools 
sudo systemctl enable sddm vmtoolsd vmware-vmblock-fuse
curl -fsSL https://install.danklinux.com | sh

#
#
#
#输入法，只对wayland设置
#https://wiki.archlinux.org/title/Fcitx5
sudo pacman  -Sy --noconfirm --needed fcitx5-im fcitx5-chinese-addons fcitx5-lua

#
#
#
#中文字体
#https://wiki.archlinux.org/title/Localization/Simplified_Chinese
sudo pacman  -Sy --noconfirm --needed adobe-source-han-sans-cn-fonts \
    adobe-source-han-serif-cn-fonts \
    noto-fonts-cjk \
    wqy-microhei \
    wqy-microhei-lite \
    wqy-bitmapfont \
    wqy-zenhei \
    ttf-arphic-ukai \
    ttf-arphic-uming 
sudo fc-cache -f

# 
#
#
#微信
#https://wiki.archlinux.org/title/Desktop_entries#Modify_environment_variables
#https://wiki.archlinux.org.cn/title/WeChat
function add_fcitx() {
    mkdir -p ~/.local/share/applications/
    cp /usr/share/applications/$1.desktop ~/.local/share/applications/
    sed -i 's#^Exec=#Exec=env QT_IM_MODULE=fcitx #' ~/.local/share/applications/$1.desktop
}
paru -Sy --noconfirm --needed wechat-bin 
add_fcitx wechat

#
#
#
#迅雷
#https://aur.archlinux.org/packages/xunlei-bin
paru -Sy --noconfirm --needed xunlei-bin

#
#
#
#visual-studio-code-bin
#https://wiki.archlinux.org/title/Visual_Studio_Code
paru -Sy --noconfirm --needed visual-studio-code-bin
