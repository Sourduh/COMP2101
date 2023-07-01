#!/bin/bash


# Source the function library file
source ~/.bashrc

#if [[ $EUID -ne 0 ]]; then
#	echo "Error: Script must be run as root or with sudo priviledge"
#	exit 1
#fi

#Populate hardware information variables.

cpuHardware
videoHardware
memoryHardware
diskHardware
videoHardware

# Default behavior: Print full system report
function full_report {
	computerReport
	osReport
	cpuReport
	ramReport
	videoReport
	diskReport
	networkReport
}

function system_report {
	computerReport
	cpuReport
	osReport
	ramReport
	videoReport
}

function disk_report {
	diskReport
}
	
function network_report {
	networkReport
}

function invalid_option {
	echo "Invalid option chosen"
	exit 1
}		
# Command line set up using get opts
while getopts ":hvsystemdisknetwork" option; do
	case "$option" in
		h)
			echo "Usage: sysinfo.sh [options]"
			echo "Options:"
			echo "  -h: Display help"
			echo "  -v: Run script verbosely, showing errors to the user"
			echo "  -system: Only displays core system info"
			echo "  -disk: Only displays information about disk drives"
			echo "  -network: Run displays network related information"
			exit 0
			;;
		v)
			verbose=true
			full_report
			;;
		system)
			system_report
			;;
		disk)
			disk_report
			;;
		network)
			network_report
			;;
		\?)
			invalid_option
			;;
	esac
done

# Default behaviour to ensure that the report runs with out an options chosen.
if [ $OPTIND -eq 1 ]; then
    full_report
fi
