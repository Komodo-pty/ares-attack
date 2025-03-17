#!/bin/bash

echo -e "Enter the path to the wordlist you want to modify:\n"
read list

if [[ ! -f "$list" ]]; then
    echo "Error: File '$list' does not exist."
    exit 1
fi

echo -e "\nWhat operations do you want to perform?\n[1] Mutate Wordlist\n[2] Convert Entry Format\n[3] Both"
read ops

if [[ "$ops" == 1 || "$ops" == 3 ]]; then
    echo -e "\nSelect any number of the following characters you want to append to each word\n"
    echo -e "For example, to add a lowercase letter, uppercase letter, two numbers and two symbols, Enter: @,%%^^\n"
    echo -e "[@] Lowercase Letter\n[,] Uppercase Letter\n[%] Number\n[^] Symbol\n"
    read mods
    mod_num=$(echo -n "$mods" | wc -m)
    product="mutated_list.txt"
else
    product="$list"
fi

if [[ "$ops" == 2 || "$ops" == 3 ]]; then
    echo -e "\nWhich format do you want the results to be saved as?\n[1] Base64\n[2] MD5\n[3] SHA256"
    read method
    if [[ ! "$method" =~ ^[1-3]$ ]]; then
        echo "Error: Invalid method '$method'. Must be 1, 2, or 3."
        exit 1
    fi
    echo -e "\n[!] Tip: If you successfully brute force an account using hashes, you can determine the plain-text password as follows."
    echo "Use vim to search the list of hashes for the line containing the target hash & check the line number (e.g. line 1337)"
    echo -e "Open mutated_list.txt with vim & skip to that line (e.g. Press Esc & enter :1337)\n"
else
    echo -e "\nNo conversion will be performed & the results will be saved as plain-text\n"
fi

if [[ "$ops" == 1 || "$ops" == 3 ]]; then
    > mutated_list.txt # Clear file before starting
    for i in $(cat "$list"); do
        echo "Processing: $i"
        base_num=$(echo -n "$i" | wc -m)
        length=$(( "$base_num" + "$mod_num" ))
        crunch "$length" "$length" -t "$i""$mods" | grep -v Crunch >> mutated_list.txt
    done
    if [[ ! -s mutated_list.txt ]]; then
        echo "Error: mutated_list.txt is empty or was not created."
        exit 1
    fi
fi

if [[ "$ops" == 2 || "$ops" == 3 ]]; then
    if [[ ! -f "$product" ]]; then
        echo "Error: Input file '$product' does not exist."
        exit 1
    fi
    > base64_list.txt  # Clear files before writing
    > md5_list.txt
    > sha256_list.txt
    while IFS= read -r i; do
        if [ "$method" == 1 ]; then
            echo -n "$i" | base64 >> base64_list.txt
        elif [ "$method" == 2 ]; then
            echo -n "$i" | md5sum | awk -F " " '{print $1}' >> md5_list.txt
        elif [ "$method" == 3 ]; then
            echo -n "$i" | sha256sum | awk -F " " '{print $1}' >> sha256_list.txt
        fi
    done < "$product"
    echo "Conversion complete. Check the output file (e.g., base64_list.txt, md5_list.txt, or sha256_list.txt)."
fi
