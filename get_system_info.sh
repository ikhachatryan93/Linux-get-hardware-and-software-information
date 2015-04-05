#!/bin/bash
args="$@"
count_of_needed_files=0
count_of_corrupted_files=0

#get username from 'usr/bin/whoami' program or $user variable
function get_user_name()
{
	 program_path=$(which whoami)
	 if [ -f "$program_path" ]; then
		echo "      User name            : $(whoami)"
	 elif [ "$USER" != "" ]; then
		echo "      User name            : $USER"
	 else
 		echo "      User name            : unknown (can not find whoami  ,,,,,,, program is missing!  USER variable is not founded!)"
   	 fi
}

#get hostname from lscpu or '/proc/...../hostame'
function get_hostname()
{
	hostname -s > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Hostname             : $(hostname -s)"
	elif [ -f "/proc/sys/kernel/hostname" ]; then
		echo "      Hostname             : $(cat /proc/sys/kernel/hostname)"
	else
		echo "      Hostname             : unknown (can not find /proc/sys/kernel/hostname /usr/bin/lscpu ,,,,,,, programs are missing !)"
	fi 
} 

#get date information from '/bin/date'
function get_date_time()
{
	program_path=$(which date)
	if [ -f "$program_path" ]; then
		echo "      Date/Time            : $(date)"
	else
 		echo "      Date/Time            : unknown (can not find '/bin/date' ,,,,,,, program is missing !)"
	fi 	
}

#get kernel version from '/bin/uname' or '/proc/version'
function get_kernel_version()
{	
	uname -mrs > /dev/null 2>&1
	if [ $? -eq 0 ]; then
  		echo "      Kernel Version       : $(uname -mrs)"
	elif [ -f "/proc/version" ]; then	
		echo "      Kernel Version 	     : $(cat /proc/version | awk -F'(' '{print $1}' )"
	else 
    	echo "      Kernel Version	     : unknown (can not find '/bin/uname' ,,,,,,, program is missing!)"
	fi 
}

#get architecture version of kernel from '/bin/uname' or '/usr/bin/arch'
function get_architecture_version()
{
 	program_path2=$(which arch)
	uname -m > /dev/null 2>&1
    	if [ $? -eq 0 ];then 
		architecture=$(uname -m)
	elif [ -f "$program_path2" ]; then
		architecture=$(arch)
	else 
		echo "      Kernel Architecture  : unknown (can not find '/bin/uname' ,,,,,,, program is missing!)"
		return
	fi
	if [ $architecture == "i686" -o $architecture == "i386" -o $architecture == "armv7l" ]; then 
		echo "      Kernel Architecture  : $(uname -m) (32 bit)"
	elif [ "$architecture" == "x86_64"  -o "$architecture" == "armv8" ]; then
		echo "      Kernel Architecture  : $(uname -m) (64 bit)"
	else 
		echo "      Kernel Architecture  : $(uname -m)"
	fi	 
}

#get distribution name from '/usr/bin/lsb_release' 
function get_distribution_name()
{
	lsb_release -d > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "      Distribution         : $(lsb_release -d | awk -F"Description:	" '{print $2}')"
	else
		echo "      Distribution 	     : unknown (can not find '/usr/bin/lsb_release' ,,,,,,, program id missing!)"
	fi	
}

#get processor name from '/proc/cpuinfo'
function get_processor_name()
{
	if [ -f "/proc/cpuinfo" ]; then
		if  grep -q "model name" /proc/cpuinfo ; then
			echo "      Processor            :$(grep -m 1 "model name" /proc/cpuinfo | awk -F: '{print $2}')" 
		elif grep -q "Processor" /proc/cpuinfo ; then 	
			echo "      Processor            :$(grep -m 1 "Processor" /proc/cpuinfo | awk -F: '{print $2}')"	
		else 
			echo "      Processor            : unknown"
		fi
	else 
		echo "      Processor            : unknown (can not find '/proc/cpuinfo' ,,,,,,, program missing!)"
	fi
}

#get physical memory space from '/proc/meminfo' or '/usr/bin/free'
function get_physical_memory()
{
	program_path=$(which free)
	if [ -f "$program_path" ]; then
		echo "      Physical Memory      : $(free -m | grep "Mem *" | awk '{print $2 }') MB of RAM"
	elif [	-f "/proc/meminfo" ]; then
		echo "      Physical Memory      : $(cat /proc/meminfo | grep -i "memtotal:" | awk '{print $2 " " $3}')"
	else 
		echo "      Physical Memory	     : unknown (can not find '/usr/bin/free' and '/proc/meminfo'  ,,,,,,, programs are missing!)"
	fi	
}

#get hard disk space from /'bin/dmesg'
function get_hard_disk_space()
{
	program_path=$(which dmesg)
	if [ -f "$program_path" ]; then
		if [ "$(dmesg | grep blocks:)" != "" ]; then
			echo "      Hard Disk Total Space:$(dmesg | grep -m 1 "blocks:" | awk -F"blocks:" '{print $2}' | sed -e 's/[()]//g')"
		else	
			echo "      Hard Disk Total Space: unknown (can not find '/bin/dmesg' ,,,,,,, program is missing!"
		fi
	fi
}

#get display resolution from '/usr/bin/xdpyinfo' and '/usr/bin/xrandr' 
function get_display_resolution()
{	
	program_path=$(which xdpyinfo)
	program_path2=$(which xrandr)
	if [ -f "$program_path" ]; then
		echo "      Display Resolution   : $(xdpyinfo  | grep 'dimensions:' | awk '{print $2 " " $3}')"
	elif [ -f "$program_path2" ]; then 
		echo "      Display Resolution   : $(xrandr | grep '*' | awk '{print $1}')"
	else
		echo "      Display Resolution   : unknown (can not find '/usr/bin/xdpyinfo' and '/usr/bin/xrandr'  ,,,,,,, programs are missing!)"
	fi
}

#get kernel version from '/usr/name' or '/etc/*-release'
function get_kernel_version()
{
	uname -srm > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "      Kernel               : $(uname -sr)"
	elif [ -f "/etc/*-release" ]; then 
		echo "      Kernel               : $(cat /etc/*-release | sed "1q;d")"
	else 	
		echo "      Kernel               : unknown (can not find '/bin/uname' and '/etc/*-release ,,,,,,, programs are missing!)"
	fi
}

#get compilation info from '/bin/uname'
function get_kernel_compiled()
{
	program_path=$(which uname)
	if [ -f "$program_path" ]; then 
		echo "      Kernel Compiled      : $(uname -v)"
	elif [ -f "/proc/version" ]; then 
		echo "      Kernel Compiled      : $(awk -F# '{print "#" $2}' /proc/version)"
	else 
		echo "      Kernel Compiled	     : unknown (can not find '/bin/uname' and '/proc/version' ,,,,,,, programs are missing!)"
	fi
}

#get desktop environment name from $XDG_CURRENT_DESKTOP 
function get_desktop_environment()
{ 
	if [ -n "$XDG_CURRENT_DESKTOP" ]; then
		echo "      Desktop Environment  : $XDG_CURRENT_DESKTOP "
	else
		echo "      Desktop Environment  : unknown (XDG_CURRENT_DESKTOP variable is not found ,,,,,,,, unseted variable! "
	fi
}

#get distribution name from '/usr/..../lsb_release'
function get_distribution_name()
{
	lsb_release -d > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "      Distribution         : $(lsb_release -d | awk -F"Description:	" '{print $2}')"
	else 
		echo "      Distribution         : unknown (can not find '/usr/bin/lsb_release' ,,,,,,, program is missing!)"
	fi
}

#get gcc version from gcc --version 
function get_gcc_version()
{
	gcc --version > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "      GCC Version          : $(gcc --version | grep -m 1  'gcc')"
	else 	
		echo "      GCC Version          : unknown"
	fi
}

#get cpu operation mode from '/usr/bin/lscpu'
function get_cpu_operation_mode()
{
	program_path=$(which lscpu)
	if [ -f "$program_path" ]; then
		echo "      CPU Op-mod(s)        : $(lscpu | grep -i "op-mod" | awk -F":        " '{print $2}')"   
	else
		echo "      CPU Op-mod(s)        : unknown (can not find '/usr/bin/lscpu' ,,,,,,, program is missing!)"
	fi
}

#get number of cpu cores from '/usr/bin/lscpu" 
function get_number_of_cpu_cores()
{
	program_path=$(which lscpu)
	if [ -f "$program_path" ]; then
		echo "      CPU Cores            : $(lscpu | grep -i "CPU(s)" | awk -F":                " '{print $2}')"   
	else
		echo "      CPU Cores            : unknown (can not find '/usr/bin/lscpu' ,,,,,,, program is missing!)"
	fi
}

#get current cpu frequency from '/usr/bin/lscpu' or '/proc/cpuinfo'
function get_cpu_current_freq()
{
	program_path=$(which lscpu)
	if [ -f "$program_path" ]; then
		if [ "$(lscpu  | grep -i "CPU MHz")" != "" ] ; then
			echo "      Current CPU Frequency: $(lscpu | grep -i "CPU MHz" | awk -F":               " '{print $2}') MHz"
		elif [ -f "/proc/cpuinfo" ];  then
			if  [ "$(grep -i "cpu MHz" /proc/cpuinfo)" != "" ]; then 
				echo "      Current CPU Frequency:$(grep -i "cpu MHz" /proc/cpuinfo | awk -F: '{print $2}') MHz"
			else 
				echo "      Current CPU Frequency: unknown"
			fi
		fi
	else 
		echo "      Current CPU Frequency: unknown (can not find '/usr/bin/lscpu' and '/proc/cpuinfo' ,,,,,,, programs are missing!)"
	fi	
}

#get cpu maximum frequency
function get_max_cpu_freq()
{
	if [ -f "/proc/cpuinfo" ];  then 
	if  grep "model name" /proc/cpuinfo | grep -q "@"  ; then
		echo "      Max CPU Frequency    :$(grep -m 1 "model name" /proc/cpuinfo | awk -F@ '{print $2}')" 
	elif  grep  "Processor" /proc/cpuinfo | grep -q "@"  ; then 	    
		echo "      Max CPU Frequency    :$(grep -m 1 "Processor" /proc/cpuinfo | awk -F@ '{print $2}')"
	elif [ -f "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq" ];  then
		frequency=$[$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)/1000]
		echo "      Max CPU Frequency    : $frequency MHz"
	else 
		echo "      Max CPU Frequency    : unknown (can not find /proc/cpuinfo or /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ,,,,,,, files are missing!/)"
	fi 
	fi	
}


#get info about cpu cache size from '/proc/cpuinfo'
function get_cpu_cache_size()
{
	if [ -f "/proc/cpuinfo" ];  then 
		echo "      Cache Size           :$( grep -m 1 "cache size" /proc/cpuinfo | awk -F: '{print $2}')"
	else 
		echo "      Cache Size           : unknown (can not find '/proc/cpuinfo' ,,,,,,, program is missing!)"
	fi
}

#get info about cpu loading from '/proc/loadavg' or '/usr/bin/utime'
function get_cpu_load_average()
{
	program_path=$(which uptime)
	if [ -f "$program_path"  ]; then
		echo "      Load Average         :$(uptime | grep "load average" | awk -F "load average:" '{print $2}' )"
	elif [ -f "/proc/loadavg" ] ; then 
  		echo "      Load Average         : $(cat /proc/loadavg) "
	else
		echo "      Load Average         : unknown (can not find '/usr/bin/uptime' and '/proc/loadavg' ,,,,,,, programs are missing!)"	
	fi
}

#get cpu vendor_id
function get_cpu_vendor()
{
	if [ -f "/proc/cpuinfo" ]; then
		if [ "$(cat /proc/cpuinfo | grep -i vendor_id)" != "" ]; then
			echo "      Vendor name          :$(cat /proc/cpuinfo | grep -im 1 vendor_id | awk -F":" '{print $2}')"
		fi
	fi	
}
#get cpu flags from '/proc/cpu/info'
function get_processor_flags()
{
	if [ ! -f "/proc/cpuinfo" ]; then 
		echo "      Flags                : unknown (can not find '/proc/cpuinfo' ,,,,,,, programs is missing!)"
		return 0
	elif ! grep -q "flags" /proc/cpuinfo; then
		echo "      Flags                : unknown"
		return 0
	fi
	count_of_flags=$(grep -m 1 "flags" /proc/cpuinfo | awk -F: '{printf $2}' | wc -w)
  	list=$(grep -m 1 "flags" /proc/cpuinfo | awk -F: '{print $2}')  
  	printf "      Flags                : "
    	for ((k=1;k<=$count_of_flags;k++)); 
	do    
        	if [ $(($k%6)) -eq 0 ]; then
				printf "\n                             "
         	fi
         	printf "$(echo "$list" | awk '{print $'$k' }'  ORS=" ")"
	done
}

#get network information from '/sbin/config'
function get_network_information()
{
	ifconfig > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		connection_names=$(/sbin/ifconfig | grep -i "link encap" | awk '{print $1}')
		for line in $connection_names
		do            
			echo "    $line"
			if [ "$(/sbin/ifconfig "$line" | grep -im 1 "inet addr")" != "" ]; then
				echo "      IP Address           : $( /sbin/ifconfig "$line" | grep -im 1 "inet addr" | awk '{print $2}' | awk -F: '{print $2}')"
			fi
			if [ "$(/sbin/ifconfig "$line" | grep -im 1 "hwaddr")" != "" ]; then
				echo "      Mac Address          : $( /sbin/ifconfig "$line" | grep -im 1 hwaddr | awk '{print $5}')"
			fi
			if [ "$(/sbin/ifconfig "$line" | grep -im 1 "Mask")" != "" ]; then
				echo "      Subnet Mask          : $( /sbin/ifconfig "$line" | grep -im 1 "Mask:*" | awk -F"Mask:" '{print $2}')"
			fi
			if [ "$(/sbin/ifconfig "$line" | grep -im 1 "bcast")" != "" ]; then
					echo "      Broadcast Address    : $( /sbin/ifconfig "$line" | grep -im 1 "bcast*" | awk '{print $3}' | awk -F: '{print $2}')"
			fi
			if [ "$(/sbin/ifconfig "$line" | grep -im 1 "rx bytes")" != "" ]; then
					echo "      Sent                 : $( /sbin/ifconfig "$line" | grep -im 1 "RX bytes*" | awk '{print $3 " " $4}')"
			fi
			if [ "$(/sbin/ifconfig "$line" | grep -im 1 "tx bytes")" != "" ]; then
				echo "      Receive              : $( /sbin/ifconfig "$line" | grep -im 1 "TX bytes*" | awk '{print $7 " " $8}')"
			fi
		done
		echo ""
	else 
		echo "      can not find '/sbin/ifconfig' ,,,,,,, program is missing!"
	fi
}

#get getway address
function get_getway()
{	
	ip route show > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Default getway IP    : $(ip route | grep 'default' | awk '{print $3}' )"
	else
		netstat -rn > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "      Default getway IP    : $(netstat -rn | tail -1 | awk '{print $2}')"
		else
			echo "      Default getway IP    : can not find 'ip route' command ,,,,,,, file is missing!"
		fi
	fi
}

#get Domain and DNS
function get_domain_dns()
{
	#information about DNS and Hostname
	if [ -f "/etc/resolv.conf" ]; then
		name_servers="/etc/resolv.conf"
		if [ "$(cat /etc/resolv.conf | grep -e domain)" != "" ];then
			echo "      Domain               :$(cat /etc/resolv.conf | grep domain | awk -F"domain" '{print $2}')"
		fi
		printf "      DNS addresses        :" 
		while read line; do
		    if [ "$(echo $line | grep -e nameserver)" != "" ]; then
				printf " $(echo $line | grep nameserver | awk '{print $2}'),"
		    fi
		done < ${name_servers}
			echo ""
		else
			echo "can not found /etc/resolv.conf ,,,,,,, file is missing!"
	fi 
}

#information about pci devices and drivers
function get_pci_devices()
{
	lspci > /dev/null 2>&1
	#check that file exists
	if [ $? -ne 0 ];then
		echo "      can not find /usr/bin/lspci ,,,,,,, program is missing!"
		return 0
	fi
	#get pci device information from lspci
	count=$(lspci -k | wc -l)
	length=30
	n=0
	for ((index=1;index<=$count;++index)); do
		line=$(lspci -k | sed "${index}q;d")
		if  [ "$(echo $line | grep Kernel)" != "" ]; then 
			n=$((n+1))
			number_of_wrd=$(echo $line | awk -F: '{print $1}' | wc -m)
			padding=$(($length - $number_of_wrd - 2))
			str=$(for i in $(seq -s " " $padding); do echo -n " "; done)
			echo "        $(echo $line | sed s/:/"$str:"/ )"
			if [ "$(echo $line | grep -i "kernel modules")" != "" ]; then
				mod_names=$(echo $line | awk -F: '{ print $2 }')
				mod_count=$(echo $mod_names | grep -o ',' | wc -l)
				mod_count=$((mod_count+1))
				for ((i=1;i<=$mod_count;++i)); do
	    				mod_name=$(echo $mod_names | awk -F, '{print $'$i' }') 
					if [ "$(modinfo $mod_name | grep -im 1 "filename")" != "" ]; then
						echo "           Module Path             : $(modinfo $mod_name | grep -im 1 filename | awk '{print $2}'  )"
					fi
					if [ "$(modinfo $mod_name | grep -im 1 "license")" != "" ]; then
					    echo "           License                 : $(modinfo $mod_name | grep -im 1 license | awk -F":        " '{print $2}'  )"
					fi    
        				if [ "$(modinfo $mod_name | grep -im 1 "description")" ]; then
  						echo "           Description             : $(modinfo $mod_name | grep -im 1 description | awk -F":    " '{print $2}'  )"
					fi
				done
    			fi
		elif [ "$( echo $line | grep -i subsystem: )" != "" ]; then
			n=$((n+1))
			echo "        Subsystem                  :$(echo $line | awk -F: '{print $2}')"
		else
			if [ "$n" -gt 0 ]; 
				then echo ""; n=0;
			fi
			number_of_wrd=$(echo $line | sed 's/[\ \t]*[a-z0-9A-Z:\.]*[\ \t]//' | awk -F: '{print $1}' | wc -m)
			padding=$(($length - $number_of_wrd))
			str=$(for i in $(seq -s " " $padding); do echo -n " "; done)
			printf "      $( echo $line | sed 's/[\ \t]*[a-z0-9A-Z:\.]*[\ \t]//' | sed s/:/"$str:"/) \n"
		fi
	
	done 
}

#get Firefox version 
function get_firefox()
{
	firefox --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
  		echo "      Firefox version      : $(firefox --version)" 
	fi
}

#get Chrom version
function get_chrom()
{
	chromium-browser --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Chrome version       : $(chromium-browser --version | awk '{print $1 " " $2}')"
	fi 
}

#get Opera version
function get_opera()
{
	opera --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Opera version        : $(opera --version)" 
	fi
}

#get Epiphany version
function get_epiphany()
{
	epiphany --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Epiphany version     : $(epiphany --version)" 
	fi
}

#get Lynx version
function get_lynx()
{
	lynx --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Lynx version         : $(lynx --version | sed "1q;d")" 
	fi      
}

#get Libre office version
function get_libre_office()
{
	libreoffice --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      LibreOffice version  : $(libreoffice --version)"
	fi
}

#get Kria version
function get_kria()
{
	kria --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Kria version         : $(kria --version | grep -i ktur )"
	fi
}

#get Gimp Editor version
function get_gimp()
{
	gimp -version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Gimp Editor version  : $(gimp --version)"
	fi
}

#get version of Gimp using libraries
function get_gimp_libraries()
{
	gimp -v > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "      Gimp Using Libraries :$(gimp -v | grep -m 1 using | awk -F"using" '{print $2}')" 
		exclude=$(gimp -v | sed "3q;d")
		echo "$(gimp -v | grep -v "$exclude" | grep using | awk -F"using" '{print "                            " $2}')" 
	fi
}

#get Vim version
function get_vim()
{
	vim --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Vim version          : $(vim --version | sed "1q;d")" 
	fi
}

#get Skype version 
function get_skype()
{	
	skype --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Skype version        : $(skype --version | sed "1q;d")" 
	fi
}

#get Java version 
function get_java()
{
	java -version > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		JAVA_VERSION=`java -version 2>&1 | awk 'NR==1{ gsub(/"/,""); print $3 }'` 
		echo "      Java version         : $JAVA_VERSION" 
	fi
}

#get MySQL version
function get_mysql()
{
	mysql --version > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "      MySQL version        : $(mysql --version | grep -i "mysql" | awk -F"Ver " '{print $2}')"
	fi
}

#get Python version
function get_php()
{
	php --version > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "      PHP version          : $( php --version | grep -i 'built' | sed "1q;d") "
	fi
}

#get Gedit version
function get_gedit()
{
	gedit --version > /dev/null 2>&1
	if [ $? -eq 0 ]; then 
		echo "      Gedit version        : $(gedit --version )"
    	fi
}

#get Thunderbird version
function get_thunderbird()
{
	thunderbird --version > /dev/null 2>&1
	if [ $? -eq 0 ];then 
		echo "      Thunderbird version  : $(thunderbird --version)"
	fi
}

#check files by name
function check()
{
	which $1 > /dev/null 2>&1
	if [ $? -ne 0 ];then
	echo "the '$1' file needs to be installed for the program to work correctly"
	count_of_needed_files=$((count_of_needed_files+1))
	else
		$1 > /dev/null 2>&1
		if [ $? -ne 0 ];then
		echo "the '$1' file is working not correctly, please check errors or reinstall the file"
			count_of_corrupted_files=$((count_of_corrupted_files+1))
		fi
	fi
}

#check paths by path
function check_path()
{
	if [ ! -f "$1" ]; then
 		echo "the '$1' file needs to be installed for the program to work correctly"
        count_of_needed_files=$((count_of_needed_files+1))
	fi
}

#chek the existence of needed files by using check_path() and check() functions
function check_files()
{
	echo "Checking the existence of needed files ...."
	check "echo"
	check "lscpu"
	check "lspci"
	check "ifconfig"
	check_path "/proc/cpuinfo"
	check_path "/proc/meminfo"
	check_path "/etc/resolv.conf"
	check_path "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
	check "ip route"
	check "hostname"
	check "uname"
	check "whoami"
	check "xdpyinfo"
	#check "xrandr"
	check "dmesg"
	check "lsb_release"
	check "date"
	sleep 1
	if [ "$count_of_needed_files" -gt "0" -o "$count_of_corrupted_files" -gt "0" ]; then 
		if [ "$count_of_needed_files" -gt "0" ]; then
			echo "the program can not work correctly because some files are missing from your computer!"
		fi
		if [ "$count_of_corrupted_files" -gt "0" ]; then 
			echo "the program can not work correctly because some files are corrupted in your computer!"
		fi
	else    
		echo "Checking is complete successfully."
		sleep 1
	fi    
	printf "\n \n"
}

#find some program versions
function find_some_programs()
{
	get_firefox
	get_chrom
	get_opera
	get_epiphany
	get_lynx
	get_libre_office
	get_kria
	get_gimp
	get_gimp_libraries
	get_vim
	get_skype
	get_java
	get_mysql
	get_php
	get_gedit
	get_thunderbird
}

#display main information about os, hardware and users
function main_info()
{
	echo "GENERAL { "
	get_user_name 
	get_hostname
	get_date_time
	echo "	OS information"
	get_kernel_version
	get_architecture_version
	get_distribution_name
	echo "	Hardware information"
	get_processor_name
	get_cpu_vendor
	get_physical_memory
	get_cpu_current_freq 
	get_max_cpu_freq
	get_hard_disk_space
	get_display_resolution  
	echo "}"
	echo ""
}

#call functions for complete information about software, hardware, network, and users
function complete_info()
{	
	#software info
	echo "Complete information{"
	echo ""
	echo "  Kernel information{"
	get_kernel_version
	get_kernel_compiled
	get_architecture_version
	get_distribution_name
	get_desktop_environment
	get_gcc_version
	echo "  }"
	echo ""
	#hardware info
	echo "  Hardware information{"
	get_processor_name
	get_cpu_vendor
	get_cpu_operation_mode
	get_number_of_cpu_cores
	get_max_cpu_freq
	get_cpu_current_freq
	get_cpu_cache_size
	get_cpu_load_average
	get_hard_disk_space
	get_physical_memory
	get_display_resolution
	get_processor_flags
	echo ""
	echo "  }"
	echo ""
	#get_input_devices
	echo "  PCI devices information{"
	    get_pci_devices
	echo "  }"
	echo ""
	#get network information
	    get_network_info
	#programs info
	    echo ""
	echo "  Program information{"
	find_some_programs
	echo "  }"
	echo ""
}
  
#call functions for information about operation system
function get_os_info()
{
	echo "OS information{"
	get_kernel_version
	get_kernel_compiled
	get_architecture_version
	get_distribution_name
	get_desktop_environment
	get_gcc_version
	echo "}"
	echo ""
}

#call functions for information about cpu and display
function get_cpu_info()
{
	#get cpu information
	echo "CPU information{"
	get_processor_name
	get_cpu_vendor
	get_cpu_operation_mode
	get_number_of_cpu_cores
	get_max_cpu_freq
	get_cpu_current_freq
	get_cpu_cache_size
	get_cpu_load_average
	get_processor_flags
	echo ""
	echo "}"
	echo ""
}

#get programs
function get_programs()
{
	echo "Program information{"
	find_some_programs
	echo "}"
	echo ""
}

#get devices
function get_device_info()
{
	echo "Device and Driver information{"
	get_pci_devices
	echo "}"
	echo ""
}

#call function for network information
function get_network_info()
{
	echo "  Network information{"
	get_network_information
	echo "    Network properties "
	get_hostname
	get_getway
	get_domain_dns
	echo "  }"
}
function show_help()
{
	echo "For main information press: 1"
	echo "For complete information press: 2"
	echo "For os information press: 3"
	echo "For cpu information press: 4"
	echo "For pci information press: 5"
	echo "For network information press: 6"
	echo "For major application programs press: 7" 
	echo "To quit press: q"
}

function show_options()
{
    echo "Display options:"
	echo "--main            main information"
	echo "--all             complete information"
	echo "--os              os information"
	echo "--cpu             cpu information"
	echo "--dev             pci information"
	echo "--net             network information"
	echo "--soft           application programs" 
}

function process_command()
{
	read choice
	case "$choice" in
		"1" ) 	main_info
			;;
		"2" )	complete_info
			;;
		"3" )	get_os_info
			;;
		"4" )	get_cpu_info
			;;
		"5" )	get_device_info
			;;
		"6" )  	get_network_info
			;;
		"7" )	get_programs
			;;	
		"q" )	sleep 1
			exit
			;;
		*) echo invalid option;;
	esac   
}

function main()
{    
    for opt in "$args"
    do 
        case "$opt" in
        --all)    complete_info;;
        --main)   main_info;;
        --os)     get_os_info;;
        --cpu)    get_cpu_info;;
        --dev)    get_device_info;;
        --net)    get_network_info;;
        --soft)   get_programs;;
        --help)   show_options;;
        *)  
            show_options
            exit -1
            ;;
        esac
        shift
    done

    if [ "$args" == "" ] 
    then
	    check_files
	    while true ; do
            show_help
            process_command
	    done
    fi
}

main
