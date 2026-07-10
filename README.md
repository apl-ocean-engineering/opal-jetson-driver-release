This is the repository for [OPAL](http://opal.apl.uw.edu/) Jetson out-of-tree kernel modules.

Every branch is versioned by by [Linux4Tegra distribution](https://developer.nvidia.com/embedded/jetson-linux-archive).

* The `generic/` branches contain non-camera-specific modifications:
    * The [hwpm](https://gitlab.com/nvidia/nv-tegra/linux-hwpm.git), [nvethernetrm](https://gitlab.com/nvidia/nv-tegra/kernel/nvethernetrm.git), [build/nvidia-public](https://gitlab.com/nvidia/nv-tegra/kernel/build/nvidia-public.git)  and [hardware/nvidia/tegra/nv-public](https://gitlab.com/nvidia/nv-tegra/device/hardware/nvidia/tegra-public-dts.git) submodules all track the upstream repos from Nvidia Gitlab.

    * [nvidia-oot] tracks the `l4t/l4t_<distro>` branch from our [fork of nvidia-oot](https://github.com/apl-ocean-engineering/nvidia-oot) which generally tracks the [nvidia upstream](https://gitlab.com/nvidia/nv-tegra/linux-nv-oot.git) repo.

    * [hardware/nvidia/t23x/nv-public](https://github.com/apl-ocean-engineering/opal-nvidia-t23x-public-dts.git) tracks the `apl/l4t_<distro>` branch.   We don't maintain separate branches for nano versus trisect because 

* The `vc/` branches are for [odometry nano](https://depts.washington.edu/uwaplopal/research/subsea_odometry_nano.html).
    * Yhe kernel module from the [Vision Components MIPI driver](https://github.com/VC-MIPI-modules/vc_mipi_nvidia) is added directly to the branch.

    * [nvidia-oot] uses the `vc/l4t_<distro>` branch from our [fork of nvidia-oot](https://github.com/apl-ocean-engineering/nvidia-oot) which includes OOT changes from VC.

    * VC-specific DTBs are included in the shared [hardware/nvidia/t23x/nv-public](https://github.com/apl-ocean-engineering/opal-nvidia-t23x-public-dts.git) 

* The `trisect/` branches are specific to the [Trisect subsea camera.](https://rsa-perception-sensor.gitlab.io/trisect-docs/index.html).
    * The kernel module for the [Allied Vision Alvium CSI2 cameras](https://github.com/alliedvision/alvium-csi2-driver) is added as a submodule.

    * [nvidia-oot] uses the `avt/l4t_<distro>` branch from our [fork of nvidia-oot](https://github.com/apl-ocean-engineering/nvidia-oot) which includes OOT changes from Antmicro and AVT.

    * VC-specific DTBs are included in the shared [hardware/nvidia/t23x/nv-public](https://github.com/apl-ocean-engineering/opal-nvidia-t23x-public-dts.git) 




## Building
1. Clone this repository **including all submodules**

    ```shell
        git clone --recurse-submodules https://github.com/apl-ocean-engineering/opal-jetson-driver-release.git
    ```

    or:

    ```shell
        git clone https://github.com/apl-ocean-engineering/opal-jetson-driver-release.git
        git submodule update --init
    ```

2. Download the Jetson Linux driver package (BSP) and cross compiler (registration with Nvidia required).   The driver package / BSP  **must** match your version of Jetpack:

    * [Downloads for Jetpack 7.2 / Linux4Tegra 39.2](https://developer.nvidia.com/embedded/jetpack/downloads/archive-7.2)

3. Extract the driver package **in this directory**: 
    ```shell
        tar -xvf Jetson_Linux_r*.tbz2
    ```
4. Extract the kernel headers from the driver package in the `Linux_for_Tegra/kernel` directory:
    ```shell
        cd Linux_for_Tegra/kernel/
        tar -xvf kernel_headers.tbz2
    ```
5. Extract the cross compiler **in this directory**:
   ```shell
        cd ../../
        tar -xvf x-tools.tbz2
   ```

6. Set the appropriate environment variables:

    ```shell
        source setup.sh
    ```

7. Build everything:
    ```shell
        make modules dtbs install
    ```

8. Build a distributable package `install.tar.bz2`:
    ```shell
        make package
    ```

At this point the rebuilt kernel modules -- including both the new VC modules and a few customized versions of NVidia camera handler modules -- and additional device tree overlays can be installed onto a Jetson.  

This can be done either by building a new set of images and flashing them to the device (essentially replacing the install process done through SDK Manager), or by installing them on an already-running module.  For simplicity, my focus is the latter ....

## Installing on a running system

1. Copy `install.tar.bz2`  to the device (called 'nano' in this case):

   ```shell
        scp -r install.tar.bz2 nano:~
   ```

2. Log into the device, and run the install script:

   ```shell
       ssh nano
       tar xvf install.tar.bz2
       cd install && ./install.sh
   ```

3. Instruct the bootloader to apply the device tree overlay on startup.  This can be done manually by editing the `/boot/extlinux/extlinux.conf` file, though the `jetson-io` wrapper can be used to automated the process, either graphically with:

   ```shell
       sudo /opt/nvidia/jetson-io/jetson-io.py
   ```

   or

   ```shell
       sudo /opt/nvidia/jetson-io/config-by-hardware.py -n 2="Camera VCMIPI Dual"
   ```

   Which instructs the scripts to install the overlay "Camera VCMIPI Dual" (this name is baked into the overlay file `tegra234-p3767-camera-p3768-vc_mipi-dual-imx.dtbo`) for header "2" (the CSI Camera header).

   4. Confirm the changes have created a new entry in `/boot/extlinux/extlinux.conf`
    A new entry something likethe following should exist (the args may vary)


    ```shell
    DEFAULT JetsonIO

    LABEL JetsonIO
        MENU LABEL Custom Header Config: <CSI Allied Vision Alvium Dual>
        LINUX /boot/Image
        FDT /boot/dtb/kernel_tegra234-p3768-0000+p3767-0000-nv.dtb
        INITRD /boot/initrd
        APPEND ${cbootargs} root=PARTUUID=8ee022d3-6e8b-4ecf-9e37-1946eacdc6f6 rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0 nv-auto-config
        OVERLAYS /boot/tegra234-p3767-camera-p3768-alvium-dual.dtbo
    ```

   5. Reboot
   
# Beta Disclaimer

Please be aware that all code revisions not explicitly listed in the Github Release section are
considered a **Beta Version**.

For Beta Versions, the following applies in addition to the GPLv2 License:

THE SOFTWARE IS PRELIMINARY AND STILL IN TESTING AND VERIFICATION PHASE AND IS PROVIDED ON AN “AS
IS” AND “AS AVAILABLE” BASIS AND IS BELIEVED TO CONTAIN DEFECTS. THE PRIMARY PURPOSE OF THIS EARLY
ACCESS IS TO OBTAIN FEEDBACK ON PERFORMANCE AND THE IDENTIFICATION OF DEFECTS IN THE SOFTWARE,
HARDWARE AND DOCUMENTATION.


