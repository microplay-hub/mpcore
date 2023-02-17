#!/usr/bin/env bash

# This file is part of the microplay-hub
# Designs by Liontek1985
# for RetroPie and offshoot
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mpcore"
rp_module_desc="Microplay Base Setup"
rp_module_repo="git https://github.com/microplay-hub/mpcore.git master"
rp_module_section="main"
rp_module_flags="noinstclean"

function depends_mpcore() {
    local depends=(cmake)
     getDepends "${depends[@]}"
}


function sources_mpcore() {
    if [[ -d "$md_inst" ]]; then
        git -C "$md_inst" reset --hard  # ensure that no local changes exist
    fi
    gitPullOrClone "$md_inst"
}

function install_mpcore() {
    local mpcoresetup="$scriptdir/scriptmodules/supplementary"
    cd "$md_inst"
	
#	cp -r -u "mpcore.sh" "$mpcoresetup/mpcore.sh"
    chown -R $user:$user "$mpcoresetup/mpcore.sh"
	chmod 755 "$mpcoresetup/mpcore.sh"
	rm -r "mpcore.sh"
}


function remove_mpcore() {
	rm -rf "$md_inst"
}

function defaccess_mpcore() {
	echo "Set retropie folder permissions back"
	echo "Please wait"
	sleep 1
	chown -cR pi:pi "/home/pi/RetroPie"
	chown -cR pi:pi "/home/pi/RetroPie-Setup"
	chown -cR root:root "/home/pi/RetroPie-Setup/tmp"
	chown -cR root:root "/etc/emulationstation"
	chown -cR root:root "/opt/retropie"
	chown -cR pi:pi "/opt/retropie/configs"
}

function osupdate_mpcore() {
	echo "...starting OS Update and Upgrade"
	sleep 1
	apt-get update && apt-get upgrade -y
}


function defcontrol_mpcore() {
	echo "set default Controller config"
	rm "$configdir/all/emulationstation/es_input.cfg"
}

function hostname_mpcore() {
	echo "set FTP-Hostname"
	hostnamectl set-hostname microplay		
	sleep 1
}

function motd_mpcore() {
	echo "install motd logo file"
    if isPlatform "sun50i-h616"; then
		cp -r "motd_logo/10-orangepi-header" "/etc/update-motd.d"
		chmod 755 "/etc/update-motd.d/10-orangepi-header"
    elif isPlatform "sun50i-h6"; then
		cp -r "motd_logo/10-orangepi-header" "/etc/update-motd.d"
		chmod 755 "/etc/update-motd.d/10-orangepi-header"
    elif isPlatform "sun8i-h3"; then
		cp -r "motd_logo/10-armbian-header" "/etc/update-motd.d"
		chmod 755 "/etc/update-motd.d/10-armbian-header"
    elif isPlatform "armv7-mali"; then
		cp -r "motd_logo/10-armbian-header" "/etc/update-motd.d"
		chmod 755 "/etc/update-motd.d/10-armbian-header"
	elif isPlatform "rpi"; then
		cp -r "motd_logo/10-header" "/etc/update-motd.d"
		chmod 755 "/etc/update-motd.d/10-header"
    fi
}

function screensaver_mpcore() {
	echo "#install Screensaver images"
	cp -rf "Screensaver/." "/opt/retropie/configs/all/emulationstation"
	chown -cR pi:pi "/opt/retropie/configs/all/emulationstation"
	chmod -R 755 "/opt/retropie/configs/all/emulationstation"
}

function cleandebian_mpcore() {
	echo "Update folders"		
	sudo userdel -r orangepi
	rm -r /home/orangepi
	sleep 1
}

function useraccess_mpcore() {
	echo "we change now the User Access"
	yes mpcore | passwd root
	yes mpcore | passwd pi
}

function header-inst_mpcore() {
	echo "install & update mpcore-nxt base"
	echo "v1.01 - 2023-02"
	echo "#################################"
	echo "*check the packages"
	echo "*starting the installation"
	echo "#################################"
	sleep 3
	echo "activate mpcore modules"
}


function gui_mpcore() {
    while true; do
        local options=(
            A "Activate MPCORE Base"
			B "set default Controller config"
            U "OS Update and Upgrade"
			P "Set retropie folder permissions back"
			Z "Reboot System Now"
        )
        local cmd=(dialog --default-item "$default" --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"
        [[ -z "$choice" ]] && break
        case "$choice" in
            A)
				#change to mpcore folder
				cd "$md_inst"
				
				#mpcore base installer
				header-inst_mpcore
				
				#change the Useraccess
				useraccess_mpcore
				
				#Clean folders
				cleandebian_mpcore
				
				#Set retropie folder permission
				defaccess_mpcore
				
				#install motd logo file
				motd_mpcore
	
				#set FTP-Hostname
				hostname_mpcore
				
				#install Screensaver images
				screensaver_mpcore

				#install finish
                printMsgs "dialog" "mpcore installation successful"
                ;;
            B)
			#set default Controller config
				defcontrol_mpcore
				printMsgs "dialog" "Controller config set to default .\n\nRestart System to apply."
				;;
            U)
			#OS Update and Upgrade
				osupdate_mpcore
				printMsgs "dialog" "OS Update and Upgrade finish"
				;;
            P)
			#Set retropie folder permissions back
				defaccess_mpcore
				printMsgs "dialog" "original RetroPie rights restored"
				;;
            Z)
			#Reboot System Now
				echo "...Rebooting System"
				/usr/bin/sudo /sbin/reboot
				;;
        esac
    done
}
