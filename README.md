n.b. This repository is a mashup of the out-of-tree (OOT) kernel module build structure from [Allied Vision Alvium CSI Driver for Jetpack 6](https://github.com/alliedvision/alvium-jetson-driver-release) with the AVT kernel module removed; and the [Vision Components MIPI driver](https://github.com/VC-MIPI-modules/vc_mipi_nvidia) added.

# Vision Components MIPI driver for Jetpack 6 

## Submodule status:

Following the pattern from the [AVT driver package](https://github.com/alliedvision/alvium-jetson-driver-release), the four Nvidia OOT kernel packages are included as submodules:

 * `nvidia-hwpm`, `nvidia-nvethernetrm`, and `nvidia-nvgpu` use the upstream repos from _Nvidia's_ git server.
 * `nvidia-oot` points to [my nvidia-oot repo](https://github.com/apl-ocean-engineering/nvidia-oot) which contains the **Nvidia** OOT module source with the [VC patches](https://github.com/VC-MIPI-modules/vc_mipi_nvidia/tree/master/patch/kernel_Xavier_36.2.0%2B) applied.  

The `vc-mipi-driver` contain copies the VC module sources [from their repo](https://github.com/VC-MIPI-modules/vc_mipi_nvidia/tree/master/src), rearranged for this build system.

## Building
1. Clone this repository **including all submodules**

    ```shell
        git clone --recurse-submodules https://github.com/apl-ocean-engineering/vc-jetson-driver-release.git
    ```

    or:

    ```shell
        git clone https://github.com/apl-ocean-engineering/vc-jetson-driver-release.git
        git submodule update --init
    ```

2. Download the Jetson Linux driver package (BSP) and cross compiler (registration with Nvidia required).   The driver package / BSP  **must** match your version of Jetpack:

    * [Downloads for Jetpack 6.1 / Linux4Tegra 36.4](https://developer.nvidia.com/embedded/jetson-linux-r3640)

3. Extract the driver package **in this directory**: 
    ```shell
        tar -xvf Jetson_Linux_r36*.tbz2
    ```
4. Extract the kernel headers from the driver package in the `Linux_for_Tegra/kernel` directory:
    ```shell
        cd Linux_for_Tegra/kernel/
        tar -xvf kernel_headers.tbz2
    ```
5. Extract the cross compiler **in this directory**:
   ```shell
        cd ../../
        tar -xvf aarch64--glibc--stable-2022.08-1.tar.bz2
   ```

6. Set the appropriate environment variables:

    ```shell
        source setup.sh
    ```

7. Build everything:
    ```shell
        make all 
    ```

8. Build a distributable package `install.tar.bz2`:
    ```shell
        make package
    ```

At this point the rebuilt kernel modules -- including both the new VC modules and a few customized versions of NVidia camera handler modules -- and additional device tree overlays can be installed onto a Jetson.  

This can be done either by building a new set of images and flashing them to the device (essentially replacing the install process done through SDK Manager), or by installing them on an already-running module.  For simplicity, my focus is the latter ....

## Installing on a running Nano

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
    LABEL extlinux
      MENU LABEL Vision Components cameras
      LINUX /boot/Image
      INITRD /boot/initrd
      FDT /boot/tegra234-p3767-camera-p3768-vc_mipi-dual-imx.dtbo
      APPEND ${cbootargs} root=PARTUUID=6b929ca4-a2b3-4d61-b7e3-47cffb186889 rw rootwait rootfstype=ext4 mminit_loglevel=4 console=ttyTCU0,115200 firmware_class.path=/etc/firmware fbcon=map:0 nospectre_bhb video=efifb:off console=tty0 nv-auto-config

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


