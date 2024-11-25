# ares-attack
Ares helps Pentesters prepare for war by performing simple attacks against Web Apps and Windows targets (WAR files sold seperately).

## Functionality
Ares is a collection of scripts which perform different kinds of attacks for Penetration Testing.

Each of these scripts can be run independently, or they can be launched from the main `ares.sh` script.

For the most part, this is a series of wrappers which utilize common Pentesting tools; why reinvent the wheel?

### Modules
So far there are modules for: XSS (Stealing Cookies), Active Directory Roasting, Mutating a wordlist, & Bruteforcing MSSQL in an AD environment.

In subsequent versions, each of these will be expanded upon, and more modules will be added.

#### XSS
This module performs the following 3 actions:

1) Starts a Flask server that will recieve a target's cookies & save them to a file.

2) Creates an example XSS payload which will send the target's Cookies to the Flask server.

3) Redirects the target to a specified URL (i.e. an inconspicuous page on the website).

#### ASREP Roasting & Kerberoasting
A simple wrapper program to simplify Roasting by interactively prompting for input that'll Ares will use for impacket's GetNPUsers or GetUserSPNs.

#### Wordlist Mutation
Mutates each entry in a wordlist. The output will be saved in a clear-text wordlist, & optionally will also save them in a specified format (i.e. Base64 Encoded or as a hash).

Some Web Apps want credentials in B64 or want a password hash (e.g. MD5 or SHA256), so this prepares a wordlist that can be used with your favorite bruteforcing tool (e.g. hydra, patator, or ffuf).

I'll add support for more hashing algorithms & encoding methods as the need arises.

#### Bruteforce MSSQL in AD Environment
Outside of an AD environment, tools like `hydra` work well for Bruteforcing MSSQL Servers.

However, I've noticed that many tools like `hydra` currently throw false negatives when AD Authentication is in use.

impacket's mssqlclient tool can reliably connect to these servers, but doesn't come with any bruteforcing functionality.

Ares uses a simple wrapper program to add bruteforcing capabilities to mssqlclient.

I'll try to improve the speed of this program if conventional BF tools don't address this issue, but as it is, Ares is still a reliable solution.

## Setup
After installing the dependencies, give `ares.sh` permission to execute & create a symbolic link in your PATH.

For example, run the following in this Repo's directory:

`chmod +x ares.sh`

`ln -s $(pwd)/ares.sh /home/user/.local/bin/ares`

### Dependencies
GetNPUsers.py

GetUserSPNs.py

mssqlclient.py

crunch

#### Note
Ensure all aforementioned dependencies are in your PATH and are named appropriately.

Depending on how they are installed, Impacket's tools may have another name (e.g. impacket-GetNPUsers).

# Related Projects
Check out the rest of the Pentesting Pantheon:

Perform recon to see everything your target is hiding with Argus (https://github.com/Komodo-pty/argus-recon/)

Hunt for shells with Artemis (https://github.com/Komodo-pty/artemis-hunter)
