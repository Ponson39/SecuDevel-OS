#!/bin/bash

apt-get update
apt-get install git live-build cdebootstrap devscripts -y
echo "Clonando live-build-config.git"
git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git

cd live-build-config

lb config --apt aptitude --bootappend-live "username=secudevel locales=es_CO.UTF-8 keyboards-layouts=latam autologin" --iso-publisher "SecuDEVEL" --debian-installer-gui true

cat > config/package-lists/kali.list.chroot << EOF
  kali-root-login
  kali-linux-core
  kali-menu
  kali-debtags
  kali-archive-keyring
  debian-installer-launcher
  b43-fwcutter
  dconf-editor
  openssh-server
  xfce4
  xfce4-terminal
  xfce4-power-manager-plugins
  lightdm
  mousepad
  john
  alsa-tools
  locales-all
  xorg
  squashfs-tools
  plymouth
EOF

echo Añadiendo imagen a Wallpapers

mkdir -p config/includes.chroot/usr/share/wallpapers/gidis/
wget https://i.imgur.com/LEhta3r.jpg
mv LEhta3r.jpg config/includes.chroot/usr/share/wallpapers/gidis/logo.jpg

echo Clonando tema GTK3
mkdir -p config/includes.chroot/usr/share/themes/
git clone https://github.com/vinceliuice/Matcha-gtk-theme.git
cd Matcha-gtk-theme
chmod a+x install.sh
./install.sh -d ../config/includes.chroot/usr/share/themes/ -t aliz
cd ..

echo Añadiendo tema de plymouth

mkdir -p config/includes.chroot/usr/share/plymouth/themes/
sudo cp -r ../gidis config/includes.chroot/usr/share/plymouth/themes/

cat > config/hooks/xfce.chroot << EOF 
  #!/bin/bash
  systemctl enable ligthdm.service
  systemctl start lightdm.service
  xconf-query -c xsettings -p /Net/ThemeName -s "Matcha-dark-aliz"
  xfconf-query -c xfwm4 -p /general/theme -s "Matcha-dark-aliz"
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/last-image -s /usr/share/wallpapers/gidis/logo.jpg
EOF

cat > config/hooks/plymouth.chroot << EOF 
  #!/bin/bash
  plymouth-set-default-theme -R gidis
EOF


mkdir -p config/debian-installer/
wget https://gitlab.com/kalilinux/recipes/kali-preseed-examples/-/raw/master/kali-linux-full-unattended.preseed -O config/debian-installer/preseed.cfg
sed -i 's/make-user boolean false/make-user boolean true/' config/debian-installer/preseed.cfg
echo "d-i passwd/root-login boolean false" >> config/debian-installer/preseed.cfg

mkdir -p paquetes
touch paquetes/prueba.txt
cd paquetes/
cat > prueba.txt <<EOF
    https://az764295.vo.msecnd.net/stable/ea3859d4ba2f3e577a159bc91e3074c5d85c0523/code_1.52.1-1608136922_amd64.deb
EOF

wget -i prueba.txt

cd ..

#mkdir kali-config/common/packages.chroot/
mv paquetes/* config/packages.chroot/

echo se va a construir el paquete

#./build.sh -v 
lb build --verbose 2>&1 | tee build.log
