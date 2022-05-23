#!/bin/bash
/etc/init.d/vpnagentd restart
nohup /usr/bin/telegraf &
FILE=./response.txt
logit()
{
    echo "[$(date +%d/%m/%Y-%T)] - ${*}"
}
while :
do
	if [ -z "$VPN_HOST" ]; then
      		logit "ENV VPN_HOST not found"
		continue
	fi
	if [ ! -f "$FILE" ]; then
  		logit "$FILE does not exists."
		continue
	fi
        state=$(vpn state | grep state | head -1 | awk '{print $4}')
	if [ $state = "Connected" ]; then
		logit "Connected to $VPN_HOST"
		sleep 30
	else
		logit "VPN not connected, try VPN connection"
		vpn disconnect > /dev/null
		vpn -s < response.txt connect $VPN_HOST 
		sleep 10
	fi
done
