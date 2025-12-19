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
OOT_SCENARIO="spl-blobs"
BOOT_SUPPORT_SPI="yes"
BOOT_SPI_RKSPI_LOADER="yes"
IMAGE_PARTITION_TABLE="gpt"
BOOTFS_TYPE="ext4"

# HK1 K8S uses AIC8800 for WiFi/BT via SDIO
# Verified with Android ADB logs showing aicbsp and aicbt_patch_table_load
# AIC8800 DKMS modules are installed via radxa-aic8800 extension
AIC8800_TYPE="sdio"
ENABLE_EXTENSIONS="radxa-aic8800 bluetooth-hciattach"
EXTENSIONS="${ENABLE_EXTENSIONS}"
BLUETOOTH_HCIATTACH_RKFILL_NUM=0
BLUETOOTH_HCIATTACH_PARAMS="-s 115200 /dev/ttyS2 any 1500000 flow nosleep"

function post_family_tweaks__hk1_k8s_use_ttyS1_console() {
	if [[ -f "${SDCARD}/boot/boot.cmd" ]]; then
		sed -i 's/console=ttyS2,1500000/console=ttyS1,1500000/g' "${SDCARD}/boot/boot.cmd"
		mkimage -C none -A arm -T script -d "${SDCARD}/boot/boot.cmd" "${SDCARD}/boot/boot.scr" >/dev/null 2>&1
	fi
}

function post_family_tweaks__hk1_k8s_enable_ir() {
	display_alert "Installing IR remote support" "ir-keytable" "info"

	# Install IR keytable package for remote control support
	chroot_sdcard_apt_get_install ir-keytable

	# Ensure IR modules are loaded at boot
	cat <<-EOF >> "${SDCARD}/etc/modules-load.d/ir-remote.conf"
	# IR receiver modules for HK1-K8S
	gpio_ir_recv
	rc_core
	EOF
}
