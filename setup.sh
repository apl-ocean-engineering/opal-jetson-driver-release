export ARCH=arm64

# Assumes the cross compiler package has been unpacked in the current directory;
# see the README
export CROSS_COMPILE=$(pwd)/x-tools/aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-

# Assumes the BSP has been unpacked in the current directory,
# and kernel_sources.tar.bz2 has been unpacked in Linux_for_Tegra/kernel/
# see the README
#export KERNEL_HEADERS=$(pwd)/Linux_for_Tegra/source/kernel/kernel-noble/

export KERNEL_HEADERS=$(pwd)/Linux_for_Tegra/kernel/linux-headers-6.8.12-1021-tegra-linux_x86_64/3rdparty/canonical/linux-noble/
export kernel_name=noble

export INSTALL_MOD_PATH=$(pwd)/install
