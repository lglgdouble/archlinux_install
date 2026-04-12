#!/bin/bash
cdpwd=$(dirname "$(readlink -f "$0")")
cd "${cdpwd}" || exit 

#
#
#
export cdpwd
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
sudo pacman -Syu --noconfirm --needed archlinuxcn-keyring  networkmanager openssh paru
sudo systemctl enable NetworkManager
sudo systemctl enable sshd

#
#
#
#
#curl
change_curl="1"
if [ "$change_curl" = "" ]; then
    echo "。。。。。。。。。。。。。恢复curl"
    sudo pacman -Syu --noconfirm curl
else
    echo "。。。。。。。。。。。。。改变curl"
    sudo pacman -Syu --noconfirm curl
    curl=$(readlink -f $(which curl))
    old_curl=${curl}_old
    sudo mv ${curl} ${old_curl}

cat <<'EOF' | sudo tee ${curl} >/dev/null
#!/bin/bash
arg=""
while [ $# != 0 ]; do
    case "$1" in
    https://raw.githubusercontent.com*)
        xx=${1/#"https://raw.githubusercontent.com/"/"https://ghfast.top/https://raw.githubusercontent.com/"}
        arg="${arg} $xx"
        ;;

    https://github.com*)
        xx=${1/#"https://github.com/"/"https://ghfast.top/https://github.com/"}
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

    sudo sed -i "s#github_proxy_placeholder#${github_proxy}#g" ${curl}
    sudo chmod --reference ${old_curl} ${curl} && sudo chown --reference ${old_curl} ${curl}
fi


#
#
#git
sudo pacman -Sy --noconfirm --needed  git
git config --global user.name "cyc_archlinux_dev"
git config --global user.email "cyc_archlinux_dev"
git config --global init.defaultBranch main
git config --global url."https://github.com/lglgdouble/".insteadOf "https://github.com/lglgdouble/"
git config --global url."${github_proxy}/https://github.com/".insteadOf "https://github.com/"

#
#
#pip
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
#
#npm
#https://npmmirror.com/
sudo pacman -Sy --noconfirm --needed  npm
npm config set registry https://registry.npmmirror.com

#
#
#
#
#yazi
#https://yazi-rs.github.io/docs/installation
#https://github.com/ryanoasis/nerd-fonts
sudo pacman -Sy --noconfirm --needed yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick ttf-jetbrains-mono-nerd
sudo fc-cache -fv
cat <<'EOF' | sudo tee /etc/profile.d/yazi.sh >/dev/null
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
#zsh
#https://github.com/ohmyzsh/ohmyzsh/wiki
#sh -c "$(curl -fsSL https://install.ohmyz.sh)"
sudo pacman -Sy --noconfirm --needed  zsh  zsh-completions
sed -i 's#plugins=(git)#plugins=(git z)#g' ~/.zshrc

#
#
#
#
#
#
#
#
#
sudo pacman -Sy --noconfirm --needed \
	git vi man-db sudo lsof dos2unix base-devel bash-completion 

#
#
#
#
#https://github.com/ultrafunkamsterdam/nodriver
paru -Sy --noconfirm --needed   google-chrome
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


