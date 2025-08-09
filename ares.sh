#!/bin/bash

path=$(readlink $(which ares) | awk -F 'ares.sh' '{print $1}')
line="\n============================================================\n"
target=""

Help()
{
	cat <<EOF

Ares will interactively prompt you for input unless you provide the necessary arguments for the selected module.
	
[Options]
	-h: Show this help message
	-m <MODULE>: Specify the module you want to use

[Modules]
	upload: Bypass file upload defenses to get a backdoor on a Web App
	roast: ASREP Roasting & Kerberoasting
	xss: Setup for XSS cookie exfil
	mutate: Wordlist mutation
	bof: Buffer Overflow payload generator
	mssql: Bruteforce MSSQL in Active Directory environment

EOF
}

if [ $# -eq 0 ]
then
  echo -e "$line\nNo arguments provided. Defaulting to interactive mode.\n\n[!] Tip: Use the -h argument to view the help menu\n"
else
  while getopts ":hm:" option
  do
    case $option in
      h)
        Help
        exit
	;;

      m)
        mode=$OPTARG
	;;
		
      \?)
         echo -e "\nError: Invalid argument"
         exit
	 ;;
    esac
  done
fi

if [[ -z "$mode" ]]
then
  cat <<EOF
[Modules]
	[1] File Uploader
	[2] Active Directory Roasting
	[3] XSS
	[4] Wordlist Mutation
	[5] Buffer Overflow Payload Generator
	[6] MSSQL Brute Force

EOF
  read mode
fi

case "$mode" in

  upload|1)
    echo -e "$line\n[File Uploader]"
    bash "$path"uploader.sh
    ;;

  roast|2)
    echo -e "$line\n[Active Directory Roasting]"
    bash "$path"ad_roasting.sh
    ;;

  xss|3)
    echo -e "$line\n[XSS]"
    python3 "$path"xss_cookie_thief.py
    ;;

  mutate|4)
    echo -e "$line\n[Mutator]" 
    bash "$path"password_generator.sh
    ;;

  bof|5)
    echo -e "$line\n[Buffer Overflow]"
    python3 "$path"BoF_payload.py
    ;;

  mssql|6)
    echo -e "$line\n[Brute Force MSSQL]"
    bash "$path"mssql_Brute.sh
    ;;

  *)
    echo -e "\nYou did not select a valid option\n"
    ;;
esac
