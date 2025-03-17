#!/bin/bash

path=$(readlink $(which ares) | awk -F 'ares.sh' '{print $1}')
while true;
do
	echo -e "\nSelect an operation:\n[0] Exit\n[1] Active Directory Roasting\n[2] XSS\n[3] Wordlist Mutation\n[4] MSSQL Brute Force\n"
	read mode

	if [ $mode == 0 ]
	then
		break

	elif [ $mode == 1 ]
	then
		source "$path"ad_roasting.sh

	elif [ $mode == 2 ]
	then
		python3 "$path"xss_cookie_thief.py

	elif [ $mode == 3 ]
	then
		source "$path"password_generator.sh

	elif [ $mode == 4 ]
	then
		source "$path"mssql_Brute.sh

	else
		echo -e "\nYou did not select a valid option\n"
	fi

done
