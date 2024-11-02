export ARCH=arm64

# Assumes the cross compiler package has been unpacked in the current directory;
# see the README
export CROSS_COMPILE=$(pwd)/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-

# Assumes the BSP has been unpacked in the current directory,
# and kernel_sources.tar.bz2 has been unpacked in Linux_for_Tegra/kernel/
# see the README
export KERNEL_SRC=$(pwd)/Linux_for_Tegra/kernel/linux-headers-*-tegra-linux_x86_64/3rdparty/canonical/linux-jammy/kernel-source/

export INSTALL_MOD_PATH=$(pwd)/install
