#!/bin/bash

# Configuring some variables first ...

. /etc/profile.d/update_ip_var.sh

TIME=$(date +"%Y-%m-%d - %T")
CHECK_COMMAND="/usr/bin/ping -c 4 1.1"
echo -e "==========================================\n\n$TIME" >> $LOGFILE
PREVIOUS_IP=$(dig +short $HOSTNAME)

# Checks for network connectivity first ...
$CHECK_COMMAND > /dev/null 2>&1

connectivity=$?

if [ $connectivity -eq 0 ]; then
	myip=$(/usr/bin/dig +short myip.opendns.com @resolver1.opendns.com)
	result=$?
	if [ $? -eq 0 ]; then
		ANSWER=$(/usr/bin/curl "https://$USER:$PASS@www.ovh.com/nic/update?system=dyndns&hostname=$HOSTNAME&myip=$myip" --head)
		TEMP=$(/usr/bin/echo $ANSWER | /usr/bin/grep "200 OK")
		RESP=$?
		if [ $RESP -ne 0 ]; then
			/usr/bin/echo "An issue occured while performing the update..." >> $LOGFILE
			/usr/bin/echo -e "See response header from the server :\n" >> $LOGFILE
			/usr/bin/echo "$ANSWER" >> $LOGFILE
			/usr/bin/echo -e "\n\n" >> $LOGFILE
			exit $RESP
		else
			if [ ! "$PREVIOUS_IP" == "$myip" ]; then
				/usr/bin/echo "Request for IP address change successful ! Now changed to :" >> $LOGFILE
				/usr/bin/echo "    $HOSTNAME = $myip" >> $LOGFILE
			else
				/usr/bin/echo "Request for IP address successful, but IP was unchanged since last update." >> $LOGFILE
			fi
		fi
	else
		echo "An issue occured while requesting the public IP, please check network connectivity" >> $LOGFILE
		exit $result
	fi
else
	echo "An issue occured while testing network connectivity, please check it before trying again." >> $LOGFILE
	echo "For further debugging information, testing command used was :" >> $LOGFILE
	echo "        $CHECK_COMMAND" >> $LOGFILE
fi

exit 0
