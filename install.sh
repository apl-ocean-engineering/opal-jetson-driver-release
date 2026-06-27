#!/usr/bin/sh
#
# Install script which is added to install.tar.bz2 by "make package"

sudo install -o root -g root -m 644 boot/*vc-mipi* /boot
sudo find lib/modules/5.15.185-tegra/updates/ -type f -print -exec install -D -o root -g root -m 644 \{\} /\{\} \;
sudo depmod -a
