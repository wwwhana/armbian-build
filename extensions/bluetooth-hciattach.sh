#
# SPDX-License-Identifier: GPL-2.0
# Copyright (c) 2023 Ricardo Pardini <ricardo@pardini.net>
# This file is a part of the Armbian Build Framework https://github.com/armbian/build/
#

# Some boards needs a special treatment for bluetooth, running hciattach manually.
# To use, enable_extension bluetooth-hciattach, and set BLUETOOTH_HCIATTACH_PARAMS and BLUETOOTH_HCIATTACH_RKFILL_NUM.

function extension_prepare_config__bluetooth_hciattach() {
	display_alert "Extension: ${EXTENSION}: ${BOARD}" "initializing config" "info"

	# Bomb if BLUETOOTH_HCIATTACH_PARAMS is not set.
	if [[ -z "${BLUETOOTH_HCIATTACH_PARAMS}" ]]; then
		exit_with_error "Extension: ${EXTENSION}: ${BOARD} - BLUETOOTH_HCIATTACH_PARAMS is not set - please set in the board file."
	fi

	# Default BLUETOOTH_HCIATTACH_RKFILL_NUM to 0 if not set.
	if [[ -z "${BLUETOOTH_HCIATTACH_RKFILL_NUM}" ]]; then
		declare -g BLUETOOTH_HCIATTACH_RKFILL_NUM=0
	fi
}

# Add bluetooth packages to the image (not rootfs cache)
function post_family_config__bluetooth_hciattach_add_bluetooth_packages() {
	display_alert "Extension: ${EXTENSION}: ${BOARD}" "adding bluetooth packages to image" "info"
	add_packages_to_image rfkill bluetooth bluez bluez-tools
}

# Deploy the script and the systemd service in the BSP. It'll be enabled below in the image.
function post_family_tweaks_bsp__bluetooth_hciattach_add_systemd_service() {
	display_alert "Extension: ${EXTENSION}: ${BOARD}" "adding bluetooth hciattach service to BSP" "info"
	: "${destination:?destination is not set}"

	declare script_dir="/usr/local/sbin"
	run_host_command_logged mkdir -pv "${destination}${script_dir}"
	declare script_path="${script_dir}/bluetooth-hciattach.sh"

	cat <<- BT_HCIATTACH_SCRIPT > "${destination}${script_path}"
		#!/bin/bash
		
		# GPIO Setup for X98K (AIC8800)
		if [[ "${BOARD}" == "X98K" ]]; then
			# RTS (GPIO1_B2 = 42) -> Output Low (Active/Ready)
			if [ ! -d /sys/class/gpio/gpio42 ]; then echo 42 > /sys/class/gpio/export; fi
			echo out > /sys/class/gpio/gpio42/direction
			echo 0 > /sys/class/gpio/gpio42/value

			# WAKE (GPIO1_B4 = 44) -> Output High (Wake chip)
			if [ ! -d /sys/class/gpio/gpio44 ]; then echo 44 > /sys/class/gpio/export; fi
			echo out > /sys/class/gpio/gpio44/direction
			echo 1 > /sys/class/gpio/gpio44/value

			# RESET (GPIO1_C1 = 49) -> Pulse Low (Reset) then High (Run)
			if [ ! -d /sys/class/gpio/gpio49 ]; then echo 49 > /sys/class/gpio/export; fi
			echo out > /sys/class/gpio/gpio49/direction
			echo 0 > /sys/class/gpio/gpio49/value
			sleep 0.2
			echo 1 > /sys/class/gpio/gpio49/value
			sleep 0.5
		fi

		rfkill unblock ${BLUETOOTH_HCIATTACH_RKFILL_NUM}
		hciattach -n ${BLUETOOTH_HCIATTACH_PARAMS}
	BT_HCIATTACH_SCRIPT
	run_host_command_logged chmod -v +x "${destination}${script_path}" # Make it executable

	cat <<- BT_HCIATTACH_SYSTEMD_SERVICE > "$destination"/lib/systemd/system/bluetooth-hciattach.service
		[Unit]
		Description=${BOARD} Bluetooth HCIAttach fix
		After=network.target
		StartLimitIntervalSec=0
		[Service]
		Type=simple
		ExecStart=${script_path}

		[Install]
		WantedBy=multi-user.target
	BT_HCIATTACH_SYSTEMD_SERVICE

	return 0
}

# Enable the service created in the BSP above.
function post_family_tweaks__bluetooth_hciattach_enable_bt_service_in_image() {
	display_alert "Extension: ${EXTENSION}: ${BOARD}" "enabling bluetooth hciattach service in the image" "info"

	chroot_sdcard systemctl --no-reload enable "bluetooth-hciattach.service"

	return 0
}
