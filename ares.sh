#!/bin/bash

path=$(readlink $(which ares) | awk -F 'ares.sh' '{print $1}')
line="\n============================================================\n"
mode=""
module_args=()

detected_module=false
detected_help=false

Help()
{
	cat <<EOF

Ares will interactively prompt you for input unless you provide the necessary arguments for the selected module.
	
[Options]
	-h: Show this help message
	-m <MODULE>: Specify the module you want to use

[Modules]
	upload: Bypass file upload defenses to get a backdoor on a Web App. Currently, Uploader only supports PHP file types
	roast: ASREP Roasting & Kerberoasting
	xss: Setup for XSS cookie exfil
	mutate: Wordlist mutation
	bof: Buffer Overflow payload generator
	mssql: Bruteforce MSSQL in Active Directory environment

EOF
exit 0
}

for arg in "$@"
do
  [[ "$arg" == "-m" ]] && detected_module=true
  [[ "$arg" == "-h" ]] && detected_help=true
done

# If -h was used but -m wasn't, show Ares help menu
if $detected_help && ! $detected_module
then
  Help
fi

while [[ $# -gt 0 ]]
do
  case "$1" in
    -m)
      mode="$2"
      shift 2
      ;;

    -*)
      #Handle module args, using shift to process args regardless of order
      
      module_args+=("$1")
      if [[ -n "$2" && "$2" != -* ]]; then
        module_args+=("$2")
	shift
      fi
      shift
      ;;

    *)
      shift
      ;;
  esac
done

if [[ -z "$mode" ]]
then
  cat <<EOF
Select a Module

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
    bash "$path"uploader.sh "${module_args[@]}"
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
    Help
    ;;
esac
