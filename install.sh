#!/usr/bin/sh
#
# Script which is added to install.tar.bz2

sudo chown -R root:root boot/ lib/

sudo install -o root -g root boot/* /boot
sudo install -o root -g root lib/modules/5.15.148-tegra/updates /lib/modules/5.15.148-tegra/
sudo depmod -a
