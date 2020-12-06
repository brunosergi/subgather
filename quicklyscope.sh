#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

domain=$1

if [ $# -lt 1 ]; then
	echo "${red}[!] You need to enter a target domain!${reset}"
	echo "Usage: ./quicklyscope.sh <domain to search>"
	exit 1
else
	if [ $# -ge 2 ]; then
		echo "${red}[!] You supplied more than 2 arguments!${reset}"
		echo "Usage: ./quicklyscope.sh <domain to search>"
		exit 1
	fi
fi

discovery () {
	recon $domain
	hostalive $domain
	screenshots $domain
}

#Assetfinder is a tool created by @tomnomnom that finds domains and subdomains potentially related to a given domain.
recon () {
	echo "${green}[+] Gathering subdomains with AssetFinder...${reset}"
	assetfinder -subs-only $domain > $quicklyscope
	echo "$(cat $quicklyscope | sort -u | grep $domain)" > $quicklyscope

#remove the tags to search for subdomains in the subdomains found
	#echo "${green}[+] Re-searching for new subdomains with AssetFinder...${reset}"
	#assetfinder -subs-only # >> $quicklyscope
	#echo "$(cat $quicklyscope | sort -u | grep $domain)" > $quicklyscope
}

#httprobe is a tool created by @tomnomnom that takes a list of domains and probes for working http and https servers.
hostalive () {
	echo "${green}[+] Probing for live hosts with httprobe...${reset}"
	echo "$(cat $quicklyscope | sort -u | httprobe -c 50 -t 3000)" > $quicklyscope
	echo "$(cat $quicklyscope | sed 's/\http\:\/\///g' | sed 's/\https\:\/\///g' | sort -u)" > $quicklyscope
}

#Gowitness is a website screenshot utility written in Golang created by @sensepost.
screenshots () {
	echo "${green}[+] Taking screenshots with GoWitness...${reset}"
	gowitness file -f $quicklyscope --disable-logging -P $screenshot
}

main () {
	if [ -d "./$domain" ]; then
		echo "${red}[!] This target already exists!${reset}"
		exit 1
	else
		mkdir ./$domain
	fi

	mkdir ./$domain/$foldername
	touch ./$domain/$foldername/quicklyscope.txt
	mkdir ./$domain/$foldername/screenshots
	screenshot="./$domain/$foldername/screenshots"
	quicklyscope="./$domain/$foldername/quicklyscope.txt"

	discovery $domain

	echo "[~] The process was done. A total of ${yellow}$(wc -l $quicklyscope | awk '{print $1}')${reset} live subdomains were found."
	echo "[~] You can access the results at: ${yellow}$quicklyscope${reset}"
	exit 0
}

todate=$(date +"%Y-%m-%d")
foldername=recon-$todate
main $domain
