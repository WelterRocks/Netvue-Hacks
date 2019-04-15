#!/bin/sh
#
# Copyright (C) 2019 Oliver Welter <contact@verbotene.zone>
#
# This is free software, for non-commercial use, licensed under
# The Non-Profit Open Software License version 3.0 (NPOSL-3.0).
#
# See /LICENSE for more information.
#

KERNEL_VERSION="3.4.43-gk"
PLATFORM_NAME="armv6l"
KNOWN_DEVICE="netvue"
FALSE_FIRMWARE_PATH="/mnt/mtd/firmware"
REAL_FIRMWARE_PATH="/mnt/mtd/netvue/firmware"

LOCAL_UNAME=`uname -a`
TF_BLOCKS_AVAIL=`df | grep "/mnt/TF" | awk '{print $4}' || echo 0`
MY_IP_ADDRESS=`ifconfig | grep "inet addr" | grep -v "127.0.0.1" | cut -d : -f2 | cut -d \  -f1 | uniq`

if [ -e `echo "$LOCAL_UNAME" | grep $KERNEL_VERSION >/dev/null 2>&1 && echo 1` ]; then
	echo "ERROR: Invalid kernel version."
	exit 1
fi
	
if [ -e `echo "$LOCAL_UNAME" | grep $PLATFORM_NAME >/dev/null 2>&1 && echo 1` ]; then
	echo "ERROR: Not an $PLATFORM_NAME platform."
	exit 2
fi

if [ -e `echo "$LOCAL_UNAME" | grep $KNOWN_DEVICE >/dev/null 2>&1 && echo 1` ]; then
	echo "ERROR: Not a $KNOWN_DEVICE device."
	exit 3
fi

if [ -e `echo "$PATH" | grep $REAL_FIRMWARE_PATH >/dev/null 2>&1 && echo 1` ]; then
	if [ -e `echo "$PATH" | grep $FALSE_FIRMWARE_PATH >/dev/null 2>&1 && echo 1` ]; then
		echo "ERROR: Firmware path not registered."
		exit 4
	else
		echo -n "Correcting false firmware path..."
		ln -s $REAL_FIRMWARE_PATH $FALSE_FIRMWARE_PATH >/dev/null 2>&1
		echo "DONE"
	fi
fi

if [ "$1" = "--uninstall" ]; then
	echo -n "Disabling hack loader..."
	if [ -e `cat /etc/init.d/rcS | grep netvuehack.sh | grep -v "^#" >/dev/null 2>&1 && echo 1` ]; then
		cat /etc/init.d/rcS | grep -v netvuehack.sh > /etc/init.d/rcS.new
		mv /etc/init.d/rcS.new /etc/init.d/rcS >/dev/null 2>&1
		chmod 755 /etc/init.d/rcS >/dev/null 2>&1
		echo "OK"
	else
		echo "ALREADY DEACTIVATED"	
	fi
	
	echo -n "Disabling FTP..."
	if [ -e `cat /etc/init.d/rcS | grep ftpd | grep -v "^#" >/dev/null 2>&1 || echo 1` ]; then
		cat /etc/init.d/rcS | grep -v ftpd > /etc/init.d/rcS.new
		mv /etc/init.d/rcS.new /etc/init.d/rcS >/dev/null 2>&1
		chmod 755 /etc/init.d/rcS >/dev/null 2>&1
		echo "OK"
	else
		echo "ALREADY DEACTIVATED"	
	fi
	
	echo -n "Enabling firmware updater..."
	if [ -f $REAL_FIRMWARE_PATH/bin/upgrade.sh.orig ]; then
		mv $REAL_FIRMWARE_PATH/bin/upgrade.sh.orig $REAL_FIRMWARE_PATH/bin/upgrade.sh
		chmod 755 $REAL_FIRMWARE_PATH/bin/upgrade.sh >/dev/null 2>&1
		echo "DONE"
	else
		echo "ALREADY ENABLED"
	fi
	
	echo "Removed modifications."
	echo "EXCEPTION: Telnet is still active"
else
	echo -n "Activating telnetd..."
	if [ -e `cat /etc/init.d/rcS | grep telnetd | grep -v "^#" >/dev/null 2>&1 && echo 1` ]; then
		echo "/usr/sbin/telnetd &" >> /etc/init.d/rcS
		echo "OK"
	else
		echo "ALREADY ACTIVE"	
	fi
	
	echo -n "Activating FTP..."
	if [ -e `cat /etc/init.d/rcS | grep ftpd | grep -v "^#" >/dev/null 2>&1 && echo 1` ]; then
		echo "(sleep 30 && [ -d /mnt/TF ] && tcpsvd -E 0.0.0.0 21 ftpd -w /mnt/TF) &" >> /etc/init.d/rcS
		echo "OK"
	else
		echo "ALREADY ACTIVE"	
	fi
	
	echo -n "Activating hack loader..."
	if [ -e `cat /etc/init.d/rcS | grep netvuehack.sh | grep -v "^#" >/dev/null 2>&1 && echo 1` ]; then
		echo "(sleep 35 && [ -x /mnt/TF/netvuehack.sh ] && /mnt/TF/netvuehack.sh) &" >> /etc/init.d/rcS
		echo "OK"
	else
		echo "ALREADY ACTIVE"	
	fi
	
	echo -n "Disabling firmware updater..."
	if [ -e `cat $REAL_FIRMWARE_PATH/bin/upgrade.sh | grep upgrade >/dev/null 2>&1 && echo 1` ]; then
		echo "ALREADY DISABLED"
	else
		cp $REAL_FIRMWARE_PATH/bin/upgrade.sh $REAL_FIRMWARE_PATH/bin/upgrade.sh.orig
		echo -e "#!/bin/sh\nsleep 60\n/bin/true\n" > $REAL_FIRMWARE_PATH/bin/upgrade.sh
		chmod 755 $REAL_FIRMWARE_PATH/bin/upgrade.sh >/dev/null 2>&1
		chmod 644 $REAL_FIRMWARE_PATH/bin/upgrade.sh.orig >/dev/null 2>&1
		echo "DONE"
	fi
	
	if [ $TF_BLOCKS_AVAIL -gt 16384 ]; then	
		echo "System has been patched."
		echo "Your camera has to be rebooted."
	else
		echo "You will be unable to install the cool stuff."
		echo "Please insert a sd/tf card, with a minimum of 16 MB free space."
		exit 4
	fi
fi

