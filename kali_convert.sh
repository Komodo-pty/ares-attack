#!/bin/bash

echo -e "What format do you want the impacket dependencies?\n"
echo -e "[1] Kali (e.g. impacket-lookupsid)\n[2] Standalone installation (e.g. lookupsid.py)\n"
read choice

if [ $choice == 1 ]
then
	sed -i 's/mssqlclient.py/impacket-mssqlclient/g' mssql_Brute.sh
	sed -i 's/GetUserSPNs.py/impacket-GetUserSPNs/g' ad_roasting.sh
	sed -i 's/GetNPUsers.py/impacket-GetNPUsers/g' ad_roasting.sh
elif [ $choice == 2 ]
then
	sed -i 's/impacket-mssqlclient/mssqlclient.py/g' mssql_Brute.sh
	sed -i 's/impacket-GetUserSPNs/GetUserSPNs.py/g' ad_roasting.sh
	sed -i 's/impacket-GetNPUsers/GetNPUsers.py/g' ad_roasting.sh
else
        echo "Invalid selection. When prompted, enter either 1 or 2"
fi
