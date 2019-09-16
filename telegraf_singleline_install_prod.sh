#!/bin/bash
# Telegraf install script

osrelease=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
echo $osrelease

if [ $osrelease = '"Ubuntu"' ]
then  
  echo "It'sa me, Ubuntu"
  curl -L -O https://dl.influxdata.com/telegraf/releases/telegraf_1.10.3-1_amd64.deb
  dpkg -i telegraf_1.10.3-1_amd64.deb
elif [ $osrelease = '"CentOS Linux"' ]
then
  echo "It's CentOS"
  curl -L -O https://dl.influxdata.com/telegraf/releases/telegraf-1.10.3-1.x86_64.rpm
  yum localinstall telegraf-1.10.3-1.x86_64.rpm -y
else
  echo "Not ubuntu or CentOS, likely Red Hat"
  curl -L -O https://dl.influxdata.com/telegraf/releases/telegraf-1.10.3-1.x86_64.rpm
  yum localinstall telegraf-1.10.3-1.x86_64.rpm -y
fi
curl -L -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
mv jq /usr/bin
echo "serverid=$(sudo curl GET  -s 'http://169.254.169.254/openstack/latest/meta_data.json' |jq -r '.uuid' )" >> /etc/default/telegraf
mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf-orig.conf
curl -o /etc/telegraf/telegraf.conf https://raw.githubusercontent.com/mayankkapoor/statuscheck/master/telegraf_prod.conf
curl -o /etc/telegraf/longrunning.sh https://raw.githubusercontent.com/mayankkapoor/statuscheck/master/longrunning.sh
curl -o /etc/telegraf/commands.sh https://raw.githubusercontent.com/mayankkapoor/statuscheck/master/commands.sh
service telegraf restart
