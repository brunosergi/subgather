#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
purple=`tput setaf 5`
reset=`tput sgr0`

tput civis

function ctrl_c(){
     echo -e "${red}\n[!] Ctrl + C pressed. Script ended...${reset}\n"
     tput cnorm; exit 1
}
trap ctrl_c INT

function banner(){
echo "${purple}
            ___.     ________        __  .__                  
  ________ _\\_ |__  /  _____/_____ _/  |_|  |__   ___________ 
 /  ___/  |  \\ __ \\/   \\  ___\\__  \\\\   __\\  |  \\_/ __ \\_  __ \\
 \\___ \\|  |  / \\_\\ \\    \\_\\  \\/ __ \\|  | |   Y  \\  ___/|  | \\/
/____  >____/|___  /\\______  (____  /__| |___|  /\\___  >__|   
     \\/          \\/        \\/     \\/          \\/     \\/       
${reset}"
echo -e "\t\t\t\t\t${yellow}Created by @brunosgio${reset}\n\n"
}

function subgather(){
     gather
     probe
     screenshots
     echo
}

function gather(){
     echo "${green}[+] Gathering subdomains with Amass...${reset}"
     amass enum -passive -norecursive -d $domain >> $tmp

     echo "${green}[+] Gathering subdomains with AssetFinder...${reset}"
     assetfinder -subs-only $domain >> $tmp

     echo "${green}[+] Gathering subdomains with crt.sh...${reset}"
     curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' >> $tmp

     echo "${green}[+] Gathering subdomains with Findomain...${reset}"
     findomain -t $domain -q  >> $tmp

     echo "${green}[+] Gathering subdomains with SubFinder...${reset}"
     subfinder -d $domain -silent >> $tmp

     echo "${green}[+] Gathering subdomains with Sublist3r...${reset}"
     sublist3r -d $domain -n -t 10 2>/dev/null | grep $domain | grep -v "\[-\]" >> $tmp
}

function probe(){
     echo "${purple}[+] Probing for live hosts with httpx...${reset}"
     cat $tmp | anew | httpx -silent -threads 100 > $hosts
     rm -rf $tmp
}

function screenshots(){
     echo "${purple}[+] Taking screenshots with GoWitness...${reset}"
     gowitness file -f $hosts --disable-logging -P $screenshot
}

main(){
     todate=$(date +"%Y-%m-%d")
     folder=subGather-$todate

     if [ -d "./$domain" ]; then
          echo "${red}[!] This target already exists.${reset}"
          tput cnorm; exit 1
     else
          mkdir ./$domain
          mkdir ./$domain/$folder
          touch ./$domain/$folder/hosts.txt
          touch ./$domain/$folder/tmp.txt
          mkdir ./$domain/$folder/screenshots
     fi

     screenshot="./$domain/$folder/screenshots"
     hosts="./$domain/$folder/hosts.txt"
     tmp="./$domain/$folder/tmp.txt"

     subgather
     echo "[~] The process was done. A total of ${yellow}$(wc -l $hosts | awk '{print $1}')${reset} live subdomains were found."
     echo "[~] You can access the results at: ${yellow}$hosts${reset}"
     tput cnorm
     exit 0
}

banner
domain=$1
if [ $# -lt 1 ]; then
     echo -e "${red}[!] You need to enter a target domain.${reset}"
     echo "Usage: ./subGather.sh <domain>"
     tput cnorm; exit 1
else
     if [ $# -ge 2 ]; then
          echo -e "${red}[!] You supplied more than 2 arguments.${reset}"
          echo "Usage: ./subGather.sh <domain>"
          tput cnorm; exit 1
     fi
fi
main $domain
