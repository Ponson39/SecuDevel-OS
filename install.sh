#!/bin/bash/

mkdir -p ~/temporal 
cd temporal
apt-get update
apt-get install git live-build cdebootstrap devscripts -y

git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git

apt-get source debian-installer
cd live-build-config

cat > config/package-lists/kali.list.chroot << EOF
  kali-linux-core
  xfce4
  light-dm
  john
  debian-installer-launcher
  alsa-tools
  locales-all
  xorg
EOF

mkdir -p config/includes.chroot/usr/share/wallpapers/kali/contents/images
wget 
