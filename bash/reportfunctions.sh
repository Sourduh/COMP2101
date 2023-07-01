#!/bin/bash
#Function library for systems info report. Beginning with formatting to keep consistency 
function sectionTitle {
	echo "-----------------------------"
	echo "$1"
	echo "-----------------------------"
	echo
}

#To maintain a consistent style for each report, I made a function to display each row consistently.
function componentDescription {
	echo "$1" "$2"
}

#Create a series of variables to store hardware info that would have to be run multiple times.

function cpuHardware {
	cpuName=$(lscpu | grep 'Model name:'| sed 's/.*Model name: *//')
	cpuArchitect=$(lscpu | grep 'Architecture:'| sed 's/.*Arcitecture: *//'| sed -e 's/^[[:space:]]*//')
	cpuL1=$(lscpu | grep "L1d" | head -n1 | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' -e 's/ (.*)//')
	cpuL2=$(lscpu | grep "L2" | head -n1 | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' -e 's/ (.*)//')
	cpuL3=$(lscpu | grep "L3" | head -n1 | cut -d':' -f2 | sed -e 's/^[[:space:]]*//' -e 's/ (.*)//')
}

function memoryHardware {
	memoryInformation=$(sudo dmidecode -t 17)
}
function diskHardware {
	diskInfo=$(lshw -c disk)
}
function videoHardware {
	videoVendor=$(lshw -c video | grep "vendor" | cut -d':' -f2)
	videoProduct=$(lshw -c video | grep "product" | cut -d':' -f2)
}

#cpureport function, using the nested title function to creat a header for the report itself.
#Using lscpu we can specifically pull up cpu information and use grep to parse out the desired line for info and then using cut and sed to trim the results to trim the info into a cleaner result. In 
function cpuReport {
	sectionTitle "CPU Report"

	componentDescription "CPU Manufacturer and Model:" "$cpuName"

	componentDescription "CPU Architecture:" "$cpuArchitect"
	componentDescription "CPU Core Count:" "$(nproc)"
	componentDescription "CPU Maximum Speed" "$(sudo dmidecode -s processor-frequency  | head -n1)"
	componentDescription "L1 Cache Size:" "$cpuL1"
	componentDescription "L2 Cache Size:" "$cpuL2"
	componentDescription "L3 Cache Size:" "$cpuL3"
}

# Creating the computer report using the dmidecode command.
function computerReport {
    sectionTitle "Computer Report"

    componentDescription "Manufacturer:" "$(sudo dmidecode -s system-manufacturer)"
    componentDescription "Model:" "$(sudo dmidecode -s system-product-name)"
    componentDescription "Serial Number:" "$(sudo dmidecode -s system-serial-number)"
}

# Creating the OS Report using lsb_release
function osReport {
    sectionTitle "OS Report"

    componentDescription "Linux Distro:" "$(lsb_release -ds)"
    componentDescription "Distro Version:" "$(lsb_release -rs)"
}

# Creating the Memory Report. I used a different approach to this so the table could be formated as a table. I made a row listing the required information regarding components and then used awk to pull from the variable storing all the memory info. I then formated the table so that each lined up with the appropraite header by using -n with echo to ensure each stayed on the same line.
function ramReport {
	sectionTitle "Memory Report"
	
	echo "Memory Components:"
	echo "---------------------------"
	echo "Manufacturer		Model/Name              Size          Speed         Location"
	echo "---------------------------------------------------------------------------------------"
	echo -n "$(echo "$memoryInformation" | awk '/Manufacturer/' | cut -d':' -f2 | head -n1)		"
	echo -n "$(echo "$memoryInformation" | awk '/Part Number/' | cut -d':' -f2 | head -n1)		"
	echo -n "$(echo "$memoryInformation" | awk '/Size/' | cut -d':' -f2 | head -n1)		"
	echo -n "$(echo "$memoryInformation" | awk '/Speed/' | cut -d':' -f2 | head -n1)	"
	echo "$(echo "$memoryInformation" | awk '/Locator/' | cut -d':' -f2 | head -n1)"
	echo  "Total RAM:" "$(echo "$memoryInformation" | awk '/Size:/' | cut -d':' -f2 | head -n1)"
}

# Function to generate video report
function videoReport {
    sectionTitle "Video Report"

    componentDescription "Video Card/Chipset Manufacturer:" "$videoVendor"
    componentDescription "Video Card/Chipset Description or Model:" "$videoProduct"
}

# Function to generate disk report
function diskReport {
	sectionTitle "Disk Report"

	echo "Installed Disk Drives:"
	echo "----------------------"
	echo "Manufacturer	Model			Size		Partition	Mount Point	Filesystem	Free Space"
	echo "-----------------------------------------------------------------------------------------------"

	echo -n "$(echo "$diskInfo" | awk '/vendor/' | cut -d':' -f2 | sed -e 's/,//'  | head -n1)	"
	echo -n "$(echo "$diskInfo	" | awk '/product/' | cut -d':' -f2 | head -n1)	"
	echo -n "$(echo "$diskInfo" | awk  '/size/' | cut -d':' -f2| head -n1 | sed -e 's/(.*)//')		"
	echo -n "$(echo "$diskInfo" | awk  '/logical name/' | cut -d':' -f2| head -n1)	" 
	echo -n "$(echo "$(df -h | grep "20G" | awk '{print $6}')")		"
	echo -n "$(echo "$(df -h | grep "20G" | awk '{print $1}')")	"
	echo "$(echo "$(df -h | grep "20G" | awk '{print $4}')")	"
}

# Function to generate network report
function networkReport {
	sectionTitle "Network Report"

	echo "Installed Network Interfaces:"
	echo "-----------------------------"
	echo "Manufacturer    Model/Description       Link State    Speed         IP Addresses                      Bridge Master       DNS Servers                 Search Domains"
	echo "-------------------------------------------------------------------------------------------------------------------------------------------------------"
	echo -n "$(echo "$networkInfo" | awk '/vendor/' | cut -d':' -f2)"
	echo -n "$(echo "$networkInfo" | awk '/product/' | cut -d':' -f2)"
	echo -n "$(echo "$(ip addr show | awk '/state/'| awk '{print $9}' | tail -n1)")"
	echo -n "$(echo "$networkInfo" | awk '/size/' | cut -d':' -f2)"
	echo -n "$(hostname -I)"
}

# Function to log and display error message
function errorReport {
    local errorMessage="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo "$timestamp: $error_message" >> /var/log/systeminfo.log

    if [ "$verbose" = true ]; then
        echo "Error: $error_message" >&2
    fi
}

#Functions to create the various reports

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
