MAKEFILE_DIR := $(abspath $(shell dirname $(lastword $(MAKEFILE_LIST))))
NVIDIA_CONFTEST ?= $(MAKEFILE_DIR)/out/nvidia-conftest

all: nvidia-nvgpu-modules nvidia-oot-modules vc-mipi-driver-modules
install: nvidia-modules-install vc-mipi-driver-modules-install

# Build a tarball for installation on Nano
# Some serious tar black magic for transforming the absolute INSTALL_MOD_PATH
# to the relative path install/
# Need -P option to _not_ strip the leading slash, 
# so the regex (which includes the leading slash) works

# mkdir -p vc_install/lib/modules/5.15.148-tegra/updates/drivers/media/platform/tegra/camera/
# mkdir -p vc_install/lib/modules/5.15.148-tegra/updates/drivers/video/tegra/camera/
# mkdir -p vc_install/boot

# Delete the modules we _know_ we don't need
package: install
	rm $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/nv*
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/sound/
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/block
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/bluetooth
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/bmi088
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/cpuidle
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/crypto
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/devfreq
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/firmware
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/gpu
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/gpio
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/hwmon
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/i2c
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/mfd
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/misc
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/mtd
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/net
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/nv-p2p
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/nvpmodel
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/nvpps
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/nv-virtio
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/pci
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/pinctrl
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/power
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/pwm
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/ras
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/regulator
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/rtc
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/scsi
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/spi
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/thermal
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/tty
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/usb
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/virt
	rm -r $(INSTALL_MOD_PATH)/lib/modules/*-tegra/updates/drivers/watchdog
	install -m 755 install.sh $(INSTALL_MOD_PATH)
	tar --transform "flags=r;s|$(INSTALL_MOD_PATH)|install|" -Pcjf install.tar.bz2  $(INSTALL_MOD_PATH)

vc-mipi-driver-modules: nvidia-oot-modules check-env
	$(MAKE) -j $(NPROC) \
		KBUILD_EXTRA_SYMBOLS=$(MAKEFILE_DIR)/nvidia-oot/Module.symvers \
		CONFIG_TEGRA_OOT_MODULE=y \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.vc-mipi-driver=$(MAKEFILE_DIR)/vc-mipi-driver \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		M=$(MAKEFILE_DIR)/vc-mipi-driver \
		-C $(KERNEL_SRC) 

vc-mipi-driver-modules-install: vc-mipi-driver-modules check-env
	$(MAKE) \
		KBUILD_EXTRA_SYMBOLS=$(MAKEFILE_DIR)/nvidia-oot/Module.symvers \
		CONFIG_TEGRA_OOT_MODULE=y \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		KERNEL_SRC=$(KERNEL_SRC) \
		-C $(MAKEFILE_DIR)/vc-mipi-driver install


nvidia-oot-conftest: check-env
	mkdir -p $(NVIDIA_CONFTEST)/nvidia;
	cp -av $(MAKEFILE_DIR)/nvidia-oot/scripts/conftest/* $(NVIDIA_CONFTEST)/nvidia
	$(MAKE) -j $(NPROC) ARCH=arm64 \
		src=$(NVIDIA_CONFTEST)/nvidia obj=$(NVIDIA_CONFTEST)/nvidia \
		CC=$(CROSS_COMPILE)gcc LD=$(CROSS_COMPILE)ld \
		NV_KERNEL_SOURCES=$(KERNEL_SRC) \
		NV_KERNEL_OUTPUT=$(KERNEL_SRC) \
		-f $(NVIDIA_CONFTEST)/nvidia/Makefile
		
nvidia-hwpm-modules: nvidia-oot-conftest check-env
	$(MAKE) -j $(NPROC) \
		CONFIG_TEGRA_OOT_MODULE=m \
		srctree.hwpm=$(MAKEFILE_DIR)/nvidia-hwpm \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		M=$(MAKEFILE_DIR)/nvidia-hwpm/drivers/tegra/hwpm  \
		-C $(KERNEL_SRC) \
		modules

nvidia-hwpm-modules-install: nvidia-hwpm-modules check-env
	$(MAKE) \
		CONFIG_TEGRA_OOT_MODULE=m \
		srctree.hwpm=$(MAKEFILE_DIR)/nvidia-hwpm \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		M=$(MAKEFILE_DIR)/nvidia-hwpm/drivers/tegra/hwpm  \
		-C $(KERNEL_SRC) \
		modules_install
		
		
nvidia-oot-modules: nvidia-oot-conftest nvidia-hwpm-modules check-env
	cp -av $(MAKEFILE_DIR)/nvidia-nvethernetrm $(MAKEFILE_DIR)/nvidia-oot/drivers/net/ethernet/nvidia/nvethernet/nvethernetrm
	$(MAKE) -j $(NPROC) \
		CONFIG_TEGRA_OOT_MODULE=m \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		srctree.hwpm=$(MAKEFILE_DIR)/nvidia-hwpm \
		KBUILD_EXTRA_SYMBOLS=$(MAKEFILE_DIR)/nvidia-hwpm/drivers/tegra/hwpm/Module.symvers \
		M=$(MAKEFILE_DIR)/nvidia-oot \
		-C $(KERNEL_SRC) \
		modules

nvidia-oot-modules-install: nvidia-oot-modules check-env
	$(MAKE) \
		CONFIG_TEGRA_OOT_MODULE=m \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		srctree.hwpm=$(MAKEFILE_DIR)/nvidia-hwpm \
		KBUILD_EXTRA_SYMBOLS=$(MAKEFILE_DIR)/nvidia-hwpm/drivers/tegra/hwpm/Module.symvers \
		M=$(MAKEFILE_DIR)/nvidia-oot \
		-C $(KERNEL_SRC) \
		modules_install

nvidia-nvgpu-modules: nvidia-oot-modules nvidia-oot-conftest check-env
	$(MAKE) -j $(NPROC) \
		CONFIG_TEGRA_OOT_MODULE=m \
		KBUILD_EXTRA_SYMBOLS=$(MAKEFILE_DIR)/nvidia-oot/Module.symvers \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.nvidia=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		M=$(MAKEFILE_DIR)/nvidia-nvgpu/drivers/gpu/nvgpu  \
		-C $(KERNEL_SRC) \
		modules

nvidia-nvgpu-modules-install: nvidia-nvgpu-modules check-env
	$(MAKE) \
		CONFIG_TEGRA_OOT_MODULE=m \
		KBUILD_EXTRA_SYMBOLS=$(MAKEFILE_DIR)/nvidia-oot/Module.symvers \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.nvidia=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		M=$(MAKEFILE_DIR)/nvidia-nvgpu/drivers/gpu/nvgpu  \
		-C $(KERNEL_SRC) \
		modules_install

nvidia-modules-install: nvidia-nvgpu-modules-install nvidia-oot-modules-install nvidia-hwpm-modules-install

check-env:
ifndef ARCH
	$(error Environment variable ARCH must be defined)
endif
ifndef CROSS_COMPILE
	$(error Environment variable CROSS_COMPILE must be defined)
endif
ifndef KERNEL_SRC
	$(error Environment variable KERNEL_SRC must be defined)
endif


clean: 
	rm -rf out/
	$(MAKE) \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		srctree.nvconftest=$(NVIDIA_CONFTEST) \
		M=$(MAKEFILE_DIR)/nvidia-oot \
		-C $(KERNEL_SRC) clean
	$(MAKE) \
		srctree.nvidia-oot=$(MAKEFILE_DIR)/nvidia-oot \
		KERNEL_SRC=$(KERNEL_SRC) \
		-C $(MAKEFILE_DIR)/vc-mipi-driver clean

.PHONY: clean package install all check-env