# Rockchip RK3528A quad core 4GB DDR4 32GB eMMC TV Box
# Hardware: Ethernet (YT8531 RMII), USB 3.0 x1, USB 2.0 x2, HDMI + Audio, S/PDIF Optical
# WiFi/BT: AIC8800 SDIO (requires out-of-tree driver, USB dongle recommended)
BOARD_NAME="X98K"
BOARD_VENDOR="rockchip"
BOARDFAMILY="rk35xx"
BOOTCONFIG="generic_rk3528_defconfig"
BOARD_MAINTAINER=""
KERNEL_TARGET="vendor"
FULL_DESKTOP="yes"
BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3528-x98k.dtb"
BOOT_SCENARIO="spl-blobs"
BOOT_SUPPORT_SPI="yes"
BOOT_SPI_RKSPI_LOADER="yes"
IMAGE_PARTITION_TABLE="gpt"
BOOTFS_TYPE="ext4"
SERIALCON="ttyFIQ0"
BOOTSCRIPT="boot-x98k.cmd"

# AIC8800 WiFi/BT - requires out-of-tree driver
# Recommended: Use USB WiFi dongle for better mainline compatibility
AIC8800_TYPE="sdio"
# Uncomment if radxa-aic8800 extension is available:
ENABLE_EXTENSIONS="radxa-aic8800 bluetooth-hciattach"
EXTENSIONS="${ENABLE_EXTENSIONS}"
BLUETOOTH_HCIATTACH_RKFILL_NUM=0
BLUETOOTH_HCIATTACH_PARAMS="1500000 flow"

# Hardware acceleration and device permissions
function post_family_tweaks__x98k_hardware_config() {
	display_alert "Configuring hardware device permissions for $BOARD" "Mali GPU + VPU" "info"

	# Create Mali GPU udev rules
	mkdir -p "${destination}"/etc/udev/rules.d
	cat <<- EOF > "${destination}"/etc/udev/rules.d/50-mali.rules
		KERNEL=="mali[0-9]*", MODE="0660", GROUP="video"
		KERNEL=="rga", MODE="0660", GROUP="video"
	EOF

	# Create VPU device permissions
	cat <<- EOF > "${destination}"/etc/udev/rules.d/50-vpu.rules
		KERNEL=="mpp_service", MODE="0660", GROUP="video"
		KERNEL=="rkvdec", MODE="0660", GROUP="video"
		KERNEL=="rkvenc", MODE="0660", GROUP="video"
		KERNEL=="vepu", MODE="0660", GROUP="video"
		KERNEL=="vpu_service", MODE="0660", GROUP="video"
		KERNEL=="vpu-service", MODE="0660", GROUP="video"
		KERNEL=="hevc_service", MODE="0660", GROUP="video"
		KERNEL=="hevc-service", MODE="0660", GROUP="video"
		KERNEL=="dri/renderD*", MODE="0660", GROUP="video"
	EOF
}
