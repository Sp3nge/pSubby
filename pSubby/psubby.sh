#!/bin/bash

# !! REQUIREMENTS !!
# go get github.com/subfinder/subfinder
# go get -u github.com/subfinder/subfinder
# pip3 install shodan
# CONFIGURE SHODAN API! (shodan init <api key>)

# Made by SpengeSec (Spenge @HTB)

if [[ $# -lt 1 ]];then # If the number of arguments is less than 1
		printf "[*] Please specify a domain\n"
		printf "Usage:\n" # Print usage
		printf "\t$0 <domain name>\n\n" # Print argument 1 must be domain name
		exit 1 # Exit the script
fi

# Subdomain Enumeration

printf "[*] Enumerating subdomains for $1..."
subfinder -d $1 -o subdomains.txt --silent 1>/dev/null
printf "\n"

# Enumerate IP for each subdomain in the list
printf "[*] Getting IP adresses for each subdomain"
for sub in $(cat subdomains.txt);do
	host $sub 2>/dev/null | grep "has address" | cut -d" " -f4 >> sub_iplist.txt 
done
printf "\n"

# Collect info about each IP in the list using Shodan
printf "[*] Searching each IP on Shodan..."
for ip in $(cat sub_iplist.txt);do
	shodan host $ip 2>/dev/null | grep -v "Organization\|Country" > $ip
done

printf "\n"
printf "[*] Cleaning up..."
# Clean up
find . -type f -size 0 -delete

# Show the results
printf "\n\nResults:\n"
for ip in $(ls | grep -v "txt\|sh\|pSubby_results");do
	printf "IP address: $ip \nHostname: $(cat $ip | grep 'Hostnames' | awk -F' ' '{print $2}')\n\n"
	printf "Number of open ports: $(cat $ip | grep 'Number' | tail -c 2)\n"
	printf "Open ports: \n$(cat $ip | grep "/tcp\|/udp")\n"
	printf "$(cat $ip | grep 'CVE')\n"
	printf "\n"
	printf "+-+-+-+-+-+-+-+-+-+-+-+--+-\n"
	printf "\n"
done

if [ ! -d pSubby_results ]; then
  mkdir pSubby_results
fi
if [ ! -d pSubby_results/$1 ]; then
  mkdir pSubby_results/$1
fi
for file in $(ls | grep -v "sh\|pSubby_results" ); do
    mv $file pSubby_results/$1
done

printf "\n"
printf "[*] Finished, check results"
printf "\n"
