# ares-attack
Too lazy to keep typing the same commands, or to write a simple shell script to run them for you?

Well then this is the tool suite for you!

Ares helps Pentesters prepare for war by performing simple attacks against Web Apps and Windows targets.

## Functionality
Ares is a collection of scripts which perform different kinds of attacks for Penetration Testing.

Each of these scripts can be run independently, or they can be launched from the main `ares.sh` script.

For the most part, this is a series of wrappers which utilize common Pentesting tools; why reinvent the wheel?

### Modules
So far there are modules for: XSS (Stealing Cookies), Active Directory Roasting, & Bruteforcing MSSQL in an AD environment (Since tools like `hydra` currently throw false negatives)

In subsequent versions, each of these will be expanded upon, and more modules will be added.

## Setup
After installing the dependencies, give `ares.sh` permission to execute & create a symbolic link in your PATH.

For example, run the following in this Repo's directory:

`chmod +x ares.sh`

`ln -s $(pwd)/ares.sh /home/user/.local/bin/ares`

### Dependencies
GetNPUsers.py

GetUserSPNs.py

#### Note
Ensure all aforementioned dependencies are in your PATH and are named appropriately.

Depending on how they are installed, Impacket's tools may have another name (e.g. impacket-GetNPUsers).
