# DynDNS
Small script allowing to update an OVH DynDNS entry with small logging capability

How to use this script ?

You simply copy the file named update_ip_var.sh to /etc/profile.d/ and complete the fields. This file should have 0600 rights to prevent your credentials from being read by any user on the system !

Then you create a simple crontab with crontab -e (or you create a timer using systemd, that's up to you). I've set mine to run every 6 hours.
