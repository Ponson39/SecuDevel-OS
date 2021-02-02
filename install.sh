#!/bin/bash/

mkdir -p ~/temporal 
cd temporal
apt-get update
apt-get install git live-build cdebootstrap devscripts -y

git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git

apt-get source debian-installer
cd live-build-config

cat > kali-config/variant-default/package-lists/kali.list.chroot << EOF
  kali-linux-core
  xfce4
  light-dm
  john
  debian-installer-launcher
  alsa-tools
  locales-all
  xorg
EOF

mkdir -p kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images
wget https://i.imgur.com/LEhta3r.jpg
mv LEhta3r.jpg kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images/logo.jpg

mkdir -p kali-config/common/includes.chroot/usr/share/themes/
git clone https://github.com/vinceliuice/Matcha-gtk-theme.git
sh Matcha-gtk-theme/install.sh -d kali-config/common/includes.chroot/usr/share/themes/ -t aliz

cat > kali-config/common/hooks/xfce.chroot << EOF 
  #!/bin/bash
  systemctl enable ligthdm.service
  systemctl start lightdm.service
  xconf-query -c xsettings -p /Net/ThemeName -s "Matcha-dark-aliz"
EOF

mkdir -p kali-config/common/debian-installer/
cp ../debian-installer-*/build/preseed.cfg config/debian-installer/
sed -i 's/make-user boolean false/make-user boolean true/' config/debian-installer/preseed.cfg
echo "d-i passwd/root-login boolean false" >> config/debian-installer/preseed.cfg

mkdir kali-config/common/packages.chroot/
mv ../paquetes/ kali-config/common/packages.chroot/

./build.sh -v --dist chaquen_OS
