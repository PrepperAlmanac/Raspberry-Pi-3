#! /bin/bash

sudo apt-get install tightvncserver
sudo apt-get install hostapd
sudo apt-get install isc-dhcp-server
sudo apt-get install git
sudo apt-get install calibre

sudo cp ./etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
sudo cp ./etc/default/isc-dhcp-server /etc/default/isc-dhcp-server

sudo ifdown wlan0

sudo cp ./etc/network/interfaces /etc/network/interfaces

sudo ifconfig wlan0 192.168.42.1

sudo cp ./etc/default/hostapd /etc/default/hostapd
sudo cp ./etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp ./etc/sysctl.conf /etc/sysctl.conf

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

sudo up iptables-restore < /etc/iptables.ipv4.nat

sudo service hostapd start sudo service isc-dhcp-server start
sudo service hostapd status sudo service isc-dhcp-server status
sudo update-rc.d hostapd enable sudo update-rc.d isc-dhcp-server enable
sudo reboot


