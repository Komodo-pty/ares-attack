#!/bin/bash

# 2 Outfiles? 1 for mutations + another for formatting? or just use same file for both?

line="============================================================"
outfile="mutated_list.txt"
wordlist=""
mode=""
conversion=""
mutation=""

Help()
{
  cat <<EOF
$line
[Options]
	-h: Display this help menu
	-w <WORDLIST>: File path for the wordlist to mutate
	-x <MODE>: The operation to perform

	-c <FORMAT>: The format to convert wordlist entries into
	-m <MUTATIONS>: The mutations to apply to each wordlist entry

	-o <OUTPUT_FILE>: Save mutated wordlist to specified path (default ./mutated_list.txt)

[Modes]
	mutate: Mutate each wordlist entry
	convert: Encode / hash each wordlist entry into specified format
	all: Mutate & convert each wordlist entry

[Formats]
	md5
	sha256
	b64: Base64 Encoding

[Mutations]
	@: Lowercase letter
	,: Uppercase letter
	%: Number
	^: Symbol

[!] Tip: Mutator uses standard Crunch syntax. For example, to append: a lowercase letter, an uppercase letter, 2 numbers, & a symbol, use @,%%^

[Usage]
	ares -m mutate -w /tmp/passwords.txt -c md5 -m @,%%^
	ares -m mutate -w /tmp/passwords.txt -m %%% -o output.txt
	ares -m mutate -w /tmp/passwords.txt -c sha256

$line
EOF
  exit 0
}

Mutate()
{
  > "$outfile"

  if [[ -z "$mutation" ]]; then
    cat <<EOF
$line
Specify mutations using standard Crunch syntax.  For example, to append: a lowercase letter, an uppercase letter, 2 numbers, & a symbol, use @,%%^

[Mutations]
	@: Lowercase letter
	,: Uppercase letter
	%: Number
	^: Symbol

EOF
    read mutation
  fi

  mod_size=$(echo -n "$mutation" | wc -m)

  if [[ ! -s "$outfile" ]]; then
    echo -e "\nError: $outfile is empty or was not created"
    exit 1
  fi

  while IFS= read -r word; do
    base_size=$(echo -n "$word" | wc -m)
    length=$(( "$base_size" + "$mod_size" ))
    crunch "$length" "$length" -t "${word}${mutation}" | grep -v Crunch >> "$outfile"
  done < "$wordlist"

  cat <<EOF
$line
[!] Mutations complete

[+] Output file: $outfile

EOF
}

Convert()
{
  cat <<EOF
$line
[!] Tip: If you successfully brute force an account using hashes, you can determine the plain-text password as follows:

  1) Use vim to search the list of hashes for the line containing the target hash & check the line number (e.g., line 1337)
  2) Open mutated_list.txt with vim & skip to that line (e.g., Press Esc & enter :1337)
$line
EOF

  if [[ -z "$conversion" ]]; then
    cat <<EOF
$line
Specify the format to convert wordlist entries into

[Formats]
	md5
	sha256
	b64: Base64 Encoding


EOF
    read conversion
  fi

    case "$conversion" in
      md5|sha256|b64)
        echo -e "\n[+] Format: $conversion\n"
        ;;
      *)
        echo -e "\nError: Invalid format selected\n"
	exit 1
      ;;
    esac


# Read from $wordlist or $outfile depending on mode

  case "$mode" in
    convert)
      converted_list="${conversion}_wordlist.txt"
      > "$converted_list"

      while IFS= read -r word; do
        case "$conversion" in
	  md5)
	    echo -n "$word" | md5sum | awk -F " " '{print $1}' >> "$converted_list"
            ;;
          sha256)
	    echo -n "$word" | sha256sum | awk -F " " '{print $1}' >> "$converted_list"
            ;;
          b64)
	    echo -n "$word" | base64 >> "$converted_list"
	    ;;
        esac
      done < "$wordlist"
      cat <<EOF
$line
[!] Conversion complete

[+] Output file: $converted_list

EOF
      ;;

    all)
      converted_list="${conversion}_${outfile}"
      > "$converted_list"

      while IFS= read -r word; do
        case "$conversion" in
	  md5)
	    echo -n "$word" | md5sum | awk -F " " '{print $1}' >> "$converted_list"
            ;;
          sha256)
	    echo -n "$word" | sha256sum | awk -F " " '{print $1}' >> "$converted_list"
            ;;
          b64)
	    echo -n "$word" | base64 >> "$converted_list"
	    ;;
        esac
      done < "$outfile"
      cat <<EOF
$line
[!] Conversion complete

[+] Output file: $converted_list

EOF
      ;;
  esac
}

while getopts ":hw:x:o:c:m:" option; do
  case "$option" in
    h)
      Help
      ;;
    w)
      wordlist=$OPTARG
      ;;
    x)
      mode="$OPTARG"
      ;;
    o)
      outfile="$OPTARG"
      ;;
    c)
      conversion="$OPTARG"
      ;;
    m)
      mutation="$OPTARG"
      ;;
  \?)
    echo -e "\nError: Invalid argument"
    exit 1
  esac
done

if [[ -z "$wordlist" ]]; then
  echo -e "\nEnter the file path for the wordlist you want to mutate"
  read wordlist
fi

if [[ ! -f "$wordlist" ]]; then
  echo -e "\nError: File '$wordlist' does not exist"
  exit 1
fi

if [[ -z "$mode" ]]; then
  if [[ -n "$conversion" && -z "$mutation" ]]; then
    mode="convert"
  elif [[ -n "$mutation" && -z "$conversion" ]]; then
    mode="mutate"
  elif [[ -n "$conversion" && -n "$mutation" ]]; then
    mode="all"
  else
    cat <<EOF
$line
Select an operation to perform

[Mode]
	mutate: Mutate each wordlist entry
	convert: Encode / hash each wordlist entry into specified format
	all: Mutate & convert each wordlist entry

EOF
  read mode
  fi
fi

case "$mode" in
  mutate)
    Mutate
    ;;
  convert)
    Convert
    ;;
  all)
    Mutate
    Convert
    ;;
  \?)
    echo -e "\nError: Invalid mode selected"
    exit 1
    ;;
esac
