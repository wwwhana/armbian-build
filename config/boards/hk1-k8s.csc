# Rockchip RK3528 quad core 4GB SoC WIFI/BT AIC8800 64GB eMMC - LEMFO HK1 RBOX K8S
BOARD_NAME="HK1 K8S"
BOARDFAMILY="rk35xx"
BOOTCONFIG="hk1-k8s-rk3528_defconfig"
BOARD_MAINTAINER="leXiaLim"
KERNEL_TARGET="vendor"
KERNEL_BTF="no"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3528-hk1-k8s.dtb"
BOOT_SCENARIO="spl-blobs"
IMAGE_PARTITION_TABLE="gpt"
BOOTFS_TYPE="ext4"

# HK1 K8S uses AIC8800 for WiFi/BT via SDIO
# Verified with Android ADB logs showing aicbsp and aicbt_patch_table_load
# AIC8800 DKMS modules are installed via radxa-aic8800 extension
