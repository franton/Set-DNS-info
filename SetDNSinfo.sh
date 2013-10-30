#!/bin/sh

# Set Search Domains
# Author: r.purves@arts.ac.uk
# Version 1.0 : 15-10-2012 - Initial Version
# Version 1.1 : 16-10-2012 - Bugfixed Version
# Version 1.2 : 23-10-2012 - Use an array to pass spaces in network service name
# Version 1.3 : 24-10-2012 - Improved logging

# This script should detect the names of any present specified network ports and
# configure the search domains settings accordingly.

# Based loosely off the JAMF script that does the same thing for policy compatibility reasons.

# Set variables up here
# Casper reserves $1 to 3 for itself, so we have to use $4 onwards.
# So when calling this script, use the following fields of information:
# Field 4: Name of a Network Service
# Field 5: First search domain address. (eg. arts.local)
# Field 6: Second search domain address. (eg. arts.ac.uk)

searchNetwork="$4"
searchDomain1="$5"
searchDomain2="$6"
PrimaryDNS="$7"
SecondaryDNS="$8"

# Let's check to see if we've been passed the Search Domain details in field 5 & 6.

if [ "$searchNetwork" == "" ]; then
	echo "Error:  No network service name in parameter 4 was specified."
	exit 1
fi

if [ "$searchDomain1" == "" ]; then
	echo "Error:  No search domain in parameter 5 was specified."
	exit 1
fi

if [ "$searchDomain2" == "" ]; then
	echo "Error:  No search domain in parameter 6 was specified."
	exit 1
fi

if [ "$PrimaryDNS" == "" ]; then
	echo "Error:  No DNS address in parameter 7 was specified."
	exit 1
fi

if [ "$SecondaryDNS" == "" ]; then
	echo "Error:  No DNS address in parameter 8 was specified."
	exit 1
fi

# We're going to be doing clever things with $IFS
# (internal field separator)
# So we need to save IFS so we can change it back later 
OLDIFS=$IFS
IFS=$'\n'

# Let's start setting the search domains
 
# Read the output of the networksetup command
# Grep that output through the specified service name
# Then read all of it into an array
NetServiceArray=($( networksetup -listallnetworkservices | grep $searchNetwork ))
 
# We'll stop being clever with $IFS and put it back the way it was
IFS=$OLDIFS
 
# What's the length of the array? We need it for the following loop
tLen=${#NetServiceArray[@]}
 
# This is the bit that actually does the work
# Loop around the array and process the contents
for (( i=0; i<${tLen}; i++ ));
do
  echo "Network Service name to be configured - " "${NetServiceArray[$i]}"
  echo "Specified Search Domains addresses - " $searchDomain1 $searchDomain2
  echo "Specified DNS server addresses - " $PrimaryDNS $SecondaryDNS
  networksetup -setsearchdomains "${NetServiceArray[$i]}" $searchDomain1 $searchDomain2
  networksetup -setdnsservers "${NetServiceArray[$i]}" $PrimaryDNS $SecondaryDNS
done

# Let's make sure the DNS hostnames match the computer name
setName=`networksetup -getcomputername`
scutil --set ComputerName ${setName}
scutil --set LocalHostName ${setName}
scutil --set HostName ${setName}

# All done!
echo "Completed!"
exit 0
