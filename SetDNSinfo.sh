#!/bin/sh

# Set Search Domains
# Author: richard at richard - purves dot com
# Version 1.0 : 15-10-2012 - Initial Version
# Version 1.1 : 16-10-2012 - Bugfixed Version
# Version 1.2 : 23-10-2012 - Use an array to pass spaces in network service name
# Version 1.3 : 24-10-2012 - Improved logging
# Version 2.0 : 14-09-2017 - Massively reworked based on a suggestion by Erik Berglund.

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

# Read the output of the networksetup command
# Grep that output through the specified service name and process

while read networkService; do
	printf "%s\n" "${networkService}"
	echo "Network Service name to be configured - ${networkService}"
	echo "Specified Search Domains addresses - ${searchDomain1} ${searchDomain2}"
	echo "Specified DNS server addresses - ${PrimaryDNS} ${SecondaryDNS}"
	networksetup -setsearchdomains "${networkService}" $searchDomain1 $searchDomain2
	networksetup -setdnsservers "${networkService}" $PrimaryDNS $SecondaryDNS
done < <( networksetup -listallnetworkservices | grep -E "$searchNetwork" )

# All done!
echo "Completed!"
exit 0