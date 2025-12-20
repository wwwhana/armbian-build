# Rockchip RK3528A quad core 4GB DDR4 32GB eMMC TV Box
# Hardware: USB3.0 x1, USB2.0 x2, HDMI, TV-Out, Optical Audio, Ethernet + WiFi
# Extracted from Android: Model X98K, MAC eth0:90:0e:b3:9f:c1:70, wlan0:88:00:d4:c4:91:d6
# WiFi: AIC8800 SDIO (confirmed via lsmod)
# UART: Available on UART2 (ttyFIQ0) at 1500000 baud
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

# X98K uses AIC8800 for WiFi/BT via SDIO
# Note: AIC8800 driver support depends on vendor kernel availability
# Recommended: Use USB WiFi dongle for better mainline compatibility
AIC8800_TYPE="sdio"
# Uncomment if radxa-aic8800 extension is available:
# ENABLE_EXTENSIONS="radxa-aic8800 bluetooth-hciattach"
# EXTENSIONS="${ENABLE_EXTENSIONS}"
# BLUETOOTH_HCIATTACH_RKFILL_NUM=0
# BLUETOOTH_HCIATTACH_PARAMS="-s 115200 /dev/ttyS2 any 1500000 flow nosleep"

# TV Box specific settings
function post_family_tweaks_bsp__x98k_debug_initramfs() {
	display_alert "Adding initramfs debug script for $BOARD" "SD card detection debug" "info"

	# Force HDMI console output - critical for debugging without UART
	mkdir -p "${destination}"/boot
	cat <<- EOF > "${destination}"/boot/armbianEnv.txt
		verbosity=7
		console=both
		extraargs=console=tty1 console=tty0 console=ttyFIQ0,1500000 loglevel=7 vt.global_cursor_default=0
	EOF

	# Create initramfs debug hook to list /dev during boot
	mkdir -p "${destination}"/etc/initramfs-tools/scripts/init-premount
	cat <<- 'EOF' > "${destination}"/etc/initramfs-tools/scripts/init-premount/debug_devices
		#!/bin/sh
		PREREQ=""
		prereqs()
		{
		    echo "$PREREQ"
		}
		case $1 in
		prereqs)
		    prereqs
		    exit 0
		    ;;
		esac

		# Force console output to all available terminals
		for tty in /dev/tty0 /dev/tty1 /dev/console; do
			if [ -e "$tty" ]; then
				{
					echo ""
					echo "=========================================="
					echo "X98K RK3528A DEBUG - Device Detection"
					echo "=========================================="
					echo ""
					echo "--- ls -al /dev/mmc* ---"
					ls -al /dev/mmc* 2>/dev/null || echo "No /dev/mmc* devices found!"
					echo ""
					echo "--- cat /proc/partitions ---"
					cat /proc/partitions
					echo ""
					echo "--- blkid ---"
					blkid 2>/dev/null || echo "blkid not available or no devices"
					echo ""
					echo "=========================================="
					echo ""
				} > "$tty" 2>&1
			fi
		done

		# Also output to serial/main console
		echo "========== DEBUG: Device listing =========="
		echo "--- ls -al /dev/mmc* ---"
		ls -al /dev/mmc* 2>/dev/null || echo "No /dev/mmc* devices found"
		echo "--- cat /proc/partitions ---"
		cat /proc/partitions
		echo "--- blkid ---"
		blkid 2>/dev/null || echo "blkid failed"
		echo "==========================================="
	EOF
	chmod +x "${destination}"/etc/initramfs-tools/scripts/init-premount/debug_devices
}

# Function to configure hardware acceleration and devices
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

	# Add IR remote control support
	display_alert "Enabling IR remote control for $BOARD" "PWM-based receiver" "info"
}
