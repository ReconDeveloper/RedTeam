#!/bin/bash

OUTPUT=$(find / -perm -u=s -type f 2>/dev/null | xargs ls -l)
IFS=$'\n'
suidArray=($(find / -perm -u=s -type f 2>/dev/null | xargs ls -l | sed 's@.*/@@'))
orginalSuidArray=(${OUTPUT})
echo "arping at bwrap chfn chrome-sandbox chsh dbus-daemon-launch-helper dmcrypt-get-device exim4 fusermount gpasswd helper kismet_capture lxc-user-nic mount mount.cifs mount.ecryptfs_private mount.nfs newgidmap newgrp newuidmap ntfs-3g passwd ping ping6 pkexec polkit-agent-helper-1 pppd snap-confine ssh-keysign su sudo traceroute traceroute6 traceroute6.iputils ubuntu-core-launcher umount VBoxHeadless VBoxNetAdpCtl VBoxNetDHCP VBoxNetNAT VBoxSDL VBoxVolInfo VirtualBoxVM vmware-authd vmware-user-suid-wrapper vmware-vmx vmware-vmx-debug vmware-vmx-stats Xorg.wrap" > defFile
echo "ar aria2c arj arp as ash atobm awk base32 base64 basenc bash bridge busybox byebug bzip2 capsh cat chmod chown chroot column comm composer cp cpio cpulimit csh csplit csvtool cupsfilter curl cut dash date dd dialog diff dig dmsetup docker dosbox dvips ed emacs env eqn expand expect file find flock fmt fold gawk gcore gdb gimp git grep gtester gzip hd head hexdump highlight hping3 iconv iftop install ionice ip jjs join jq jrunscript ksh ksshell latex ldconfig ld.so less logsave look lwp-download lua lualatex luatex lwp-request make mawk more msgattrib msgcat msgconv msgfilter msgmerge msguniq mv mysql nano nasm nawk nc nice nl nmap node nohup octave od openssl openvpn paste pdflatex pdftex perl pg php pic pico pr pry python rake readelf restic rev rlwrap rpm rpmquery rsync run-parts rview rvim scp sed setarch shuf slsh socat soelim sort sqlite3 ss ssh-keygen ssh-keyscan start-stop-daemon stdbuf strace strings sysctl systemctl tac tail tar taskset tbl tclsh tee telnet tex tftp tic time timeout troff ul unexpand uniq unshare update-alternatives uudecode uuencode view vigr vim vimdiff vipw watch wc wget whiptail xargs xelatex xetex xmodmap xmore xxd xz zip zsh zsoelim" > gtfoFile
sed 's/ /\n/g' defFile > formattedDefFile
sed 's/ /\n/g' gtfoFile > formattedGTFOFile
rm gtfoFile
rm defFile
suidLength=${#suidArray[@]}
defSuidBinariesOnMachine=""
gtfoBinariesOnMachine=""
customBinariesOnMachine=""

for (( i=0; i<$suidLength; i++ ))   
 do  
 		defaultSuidCount=$(cat formattedDefFile | sed -n "/${suidArray[i]}/p" | wc -l)
 		gtfoSuidCount=$(cat formattedGTFOFile | sed -n "/${suidArray[i]}/p" | wc -l)
	 	
	if [ $defaultSuidCount -gt 0 ];
 	then
 		defSuidBinariesOnMachine="$defSuidBinariesOnMachine\n${orginalSuidArray[i]}"

 	elif [ $gtfoSuidCount -gt 0 ]; 
 	then
 	 	gtfoBinariesOnMachine="$gtfoBinariesOnMachine\n${orginalSuidArray[i]}"
 	else
 		customBinariesOnMachine="$customBinariesOnMachine\n${orginalSuidArray[i]}"
 	fi
 done

rm formattedDefFile
rm formattedGTFOFile
echo -e "\e[00;31m[-] Found default SUIDs:\e[00m\n$defSuidBinariesOnMachine" 
echo -e "\n"
echo -e "\n"
echo -e "\e[00;33m[+] Found GTFO SUIDs:\e[00m\n$gtfoBinariesOnMachine"
echo -e "\n"
echo -e "\n"
echo -e "\e[01;34m[+] Found Custom SUIDs:\e[00m\n$customBinariesOnMachine" 
echo -e "\n"
echo -e "\n"
