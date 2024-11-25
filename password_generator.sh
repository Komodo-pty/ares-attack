#!/bin/bash

line="\n============================================================\n"
echo -e "Enter the path to the wordlist you want to modify:\n"
read list

echo -e "\nSpecify the number of characters you want to add to each word:\n"
read num

echo -e "\nSelect any number of the following characters you want to append to each word\n"
echo -e "For example, to add a lowercase letter, uppercase letter, two numbers and two symbols, Enter the following:  @,%%^^\n\n"
echo -e "[@] Lowercase Letter\n[,] Uppercase Letter\n[%] Number\n[^] Symbol\n\n"
read mods

mod_num=$(echo -n "$mods" | wc -m)

echo -e "\nDo you want to convert the each entry into another form (e.g. Convert into a hash or Encode in Base64)?\n[1] Yes\n[2] No\n"
read conversion

if [ $conversion == 1 ]
then
	echo -e "\nWhich format do you want the results to be saved as?\n[1] Base64\n[2] MD5\n[3] SHA256\n"
	read method

	echo -e "\n[!] Tip: If you successfully brute force an account using hashes, you can determine the plain-text password as follows."
	echo "Use vim to search the list of hashes for the line containing the target hash & check the line number (e.g. line 1337)"
	echo -e "Open mutated_list.txt with vim & skip to that line (e.g.Press Esc & enter :1337)\n"

	if [ $method == 1 ]
	then
		format='for i in $(cat mutated_list.txt); do echo -n $i | base64 >> base64_list.txt; done'
	elif [ $method == 2 ]
	then
		format='for i in $(cat mutated_list.txt); do echo -n $i | md5sum | awk -F " " '\''{print $1}'\'' >> md5_list.txt; done'
	elif [ $method == 3 ]
	then
		format='for i in $(cat mutated_list.txt); do echo -n $i | sha256sum | awk -F " " '\''{print $1}'\'' >> sha256_list.txt; done'
	else
		echo -e "\nYou did not select a valid option. I'll just pretend that you wanted the results in plain-text."
		format=""
	fi
else
	echo -e "\nNo conversion will be performed & the results will be saved as plain-text\n"
	format=""
fi

for i in $(cat "$list")
do
	echo -e "\nGenerating a plain-text wordlist, & a list in the specified format (if that option was selected)\n"
	base_num=$(echo -n "$i" | wc -m)
	length=$(( "$base_num" + "$mod_num" ))
	crunch "$length" "$length" -t "$i""$mods" | grep -v Crunch | grep -v 0 >> mutated_list.txt
	eval "$format"
done
