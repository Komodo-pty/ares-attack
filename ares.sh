#!/bin/bash

path=$(readlink $(which ares) | awk -F 'ares.sh' '{print $1}')
while true;
do
	echo -e "\nSelect an operation:\n[0] Exit\n[1] XSS\n[2] MSSQL Brute Force\n"
	read mode

	if [ $mode == 0 ]
	then
		break

	elif [ $mode == 1 ]
	then
		source $path/

	elif [ $mode == 2 ]
	then
		source $path/

	elif [ $mode == 3 ]
	then
		break

	else
		echo -e "\nYou did not select a valid option\n"
	fi

done
