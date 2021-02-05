#!/bin/bash

apt-get update
apt-get install git live-build cdebootstrap devscripts -y
echo "Clonando live-build-config.git"
git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git

cd live-build-config

cat > kali-config/variant-default/package-lists/kali.list.chroot << EOF
  dconf-editor
  openssh-server
  kali-linux-core
  xfce4
  xfce4-terminal
  xfce4-power-manager-plugins
  lightdm
  mousepad
  john
  alsa-tools
  locales-all
  xorg
EOF

echo Añadiendo imagen a Wallpapers

mkdir -p kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images
wget https://i.imgur.com/LEhta3r.jpg
mv LEhta3r.jpg kali-config/common/includes.chroot/usr/share/wallpapers/kali/contents/images/logo.jpg

echo Clonando tema GTK3
mkdir -p kali-config/common/includes.chroot/usr/share/themes/
git clone https://github.com/vinceliuice/Matcha-gtk-theme.git
cd Matcha-gtk-theme
chmod a+x install.sh
./install.sh -d ../kali-config/common/includes.chroot/usr/share/themes/ -t aliz
cd ..

cat > kali-config/common/hooks/xfce.chroot << EOF 
  #!/bin/bash
  systemctl enable ligthdm.service
  systemctl start lightdm.service
  xconf-query -c xsettings -p /Net/ThemeName -s "Matcha-dark-aliz"
  xfconf-query -c xfwm4 -p /general/theme -s "Matcha-dark-aliz"
EOF

mkdir -p kali-config/common/debian-installer/
wget https://gitlab.com/kalilinux/recipes/kali-preseed-examples/-/raw/master/kali-linux-full-unattended.preseed -O kali-config/common/debian-installer/preseed.cfg
sed -i 's/make-user boolean false/make-user boolean true/' kali-config/common/debian-installer/preseed.cfg
echo "d-i passwd/root-login boolean false" >> kali-config/common/debian-installer/preseed.cfg

mkdir -p paquetes
touch paquetes/prueba.txt
cd paquetes/
cat > prueba.txt <<EOF
    https://az764295.vo.msecnd.net/stable/ea3859d4ba2f3e577a159bc91e3074c5d85c0523/code_1.52.1-1608136922_amd64.deb
EOF

wget -i prueba.txt

cd ..

mkdir kali-config/common/packages.chroot/
mv paquetes/* kali-config/common/packages.chroot/

echo se va a construir el paquete

./build.sh -v 
