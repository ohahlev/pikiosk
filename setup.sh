#!/bin/sh
now=$(date +"%Y%m%d%H")
log_file="log_"$now".txt"

log="$now: start transforming"
echo $log >> $log_file

# auto login
log="$now: setting auto login for user $USER"
echo $log >> $log_file
sudo sed -i "s/#autologin-user=/autologin-user=$USER/g" /etc/lightdm/lightdm.conf

# enable ssh service
log="$now: enable and start ssh service"
sudo systemctl restart ssh.service >> $log_file
echo $log >> $log_file

# timezone to HK
log="$now: timezone to HK"
echo $log >> $log_file
sudo timedatectl set-timezone Asia/Hong_Kong >> $log_file

# install nginx server
log="$now: install nginx web server"
echo $log >> $log_file
sudo apt update
sudo apt install nginx

# point localhost to a directory where web app is stored
log="$now: point document root to /home/pi/Documents/www"
echo $log >> $log_file
sudo sed -i "s/root\ \/var\/www\/html/root\ \/home\/pi\/Documents\/www/g" /etc/nginx/sites-enabled/default
sudo systemctl restart nginx.service >> $log_file

# setting to launch chromium in kiosk mode at start up
log="$log: configure chromium to launch at start up"
echo $log >> $log_file
grep -q "@sh /home/pi/Documents/start_chromium.sh" /etc/xdg/lxsession/LXDE-pi/autostart
if [ $? -eq 1 ]; then
  echo "@sh /home/pi/Documents/start_chromium.sh" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
fi

# restart lightdm service because autologin change
log="$log: restart lightdm service"
echo $log >> $log_file
sudo systemctl restart lightdm.service >> $log_file
