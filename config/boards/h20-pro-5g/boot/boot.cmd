# H20-Pro-5G Boot Script for U-Boot
# This script is compiled to boot.scr by mkimage

# Load kernel and device tree from boot partition
load mmc 0:1 ${kernel_addr_r} /boot/Image
load mmc 0:1 ${fdt_addr_r} /boot/dtb/allwinner/sun50i-h616-h20-pro-5g.dtb

# Optional: load initrd (if available)
# load mmc 0:1 ${ramdisk_addr_r} /boot/initrd.img

# Set kernel command line with both serial and display console
setenv bootargs "console=ttyS0,115200 console=tty0 root=/dev/mmcblk0p2 rw rootwait earlycon=uart,mmio32,0x02500000"

# Boot the kernel
booti ${kernel_addr_r} - ${fdt_addr_r}
