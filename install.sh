#!/usr/bin/sh
#
# Install script which is added to install.tar.bz2 by "make package"

sudo install -o root -g root boot/* /boot
sudo find lib/modules/5.15.148-tegra/updates/ -type f -print -exec install -o root -g root \{\} /\{\} \;
sudo depmod -a
