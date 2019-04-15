# Netvue-Hacks
Hacking your Netvue Cloud cameras

## Preparation
Assuming, you have console access to your device, which can be obtained by
using an open telnet port (some devices have port 23 enabled) or by using
the serial port, placed somewhere on the mainboard (marked as RX, TX, GND).

You have to login using the username 'root' with no password. Exactly, there
is no root password. Dont cry for security reasons, so it is easier for us
the reach our freaky goals.

After you logged in, make sure you are in the /root folder, by typing:

 cd /root

After that, just download our prepare tool. Therefore a configured internet
connection is needed. Type in order:

 LD_LIBRARY_PATH="/mnt/mtd/netvue/firmware/lib:$LD_LIBRARY_PATH" /mnt/mtd/netvue/firmware/bin/curl https://raw.githubusercontent.com/VerboteneZone/Netvue-Hacks/master/prepare/prepare.sh > /root/prepare.sh; chmod 755 /root/prepare.sh
 /root/prepare.sh

After the tool has been finished successfully, it gives you the order to
reboot the device. After rebooting, there should be:

- an open telnet port (by default 23 and if there wasnt one before)
- an open ftp port (pointing to the sd/tf card, with write access)
- disabled firmware upgrades (deny unwanted modifications by vendorside)
- an autoloader for hacks, placed on the sd/tf card

The last one is named netvuehack.sh and should be placed into the root
folder of the sd/tf card. Also it should have 755 permissions. The file is
executed, 35 seconds after the systems rcS file has finished booting. By
default, we use this file to stop the netvue main process from beeing
executed and start our own peer to peer process. 

Also, you could use this file to make changes on your own, but beware!!! Any
changes to the filesystem are permanent! If you dont know, what you are
doing, leave this file alone. In default configuration, there is still a way
to remove the maid changes!

So, if you take out the sd/tf card, the system is running as it has been
designed for, except of firmware upgrades and the telnet access. If you
execute:

 /root/prepare.sh --uninstall

the changes by the tool would be reverted. FTP is disabled, netvuehack.sh
autoexecution is removed and the firmware upgrade process is re-enabled. The
telnet process will remain in /etc/init.d/rcS and has to be removed by hand,
if wanted, because of lockout-prevention.

Have fun and dont forget to honour my work. 
Paypal: https://paypal.me/welterrocks

