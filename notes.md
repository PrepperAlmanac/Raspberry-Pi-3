# Raspberry-Pi-3
OS Configurations

# Stolen from
[here](https://medium.com/@edoardo849/turn-a-raspberrypi-3-into-a-wifi-router-hotspot-41b03500080e)


---

#install tightvncserver
``` bash
sudo apt-get install tightvncserver
```
---

#Install hostapd

``` bash
sudo apt-get install hostapd
```

---

#Install isc-dhcp-server
``` bash
sudo apt-get install isc-dhcp-server
```

---

#Install Git

---

#Edit /etc/dhcp/dhcpd.conf

#Comment

``` bash
#option domain-name "example.org";
#option domain-name-servers ns1.example.org, ns2.example.org;
```

#Uncomment
``` bash
authoritative;
```

#Add this subnet
``` bash
subnet 192.168.42.0 netmask 255.255.255.0 {
    range 192.168.42.10 192.168.42.50;
    option broadcast-address 192.168.42.255;
    option routers 192.168.42.1;
    default-lease-time 600;
    max-lease-time 7200;
    option domain-name "local";
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
```

---

#Edit /etc/default/isc-dhcp-server
#Change

``` bash
INTERFACES=""
```

#To
``` bash
INTERFACES="wlan0"
```

#Bring wlan0 down
``` bash
sudo ifdown wlan0
```

#Edit /etc/network/interfaces

``` bash
sudo nano /etc/network/interfaces
```

``` bash
auto lo
iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0

iface wlan0 inet static
  address 192.168.42.1
  netmask 255.255.255.0
  post-up iw dev $IFACE set power_save off

#iface wlan0 inet manual
#wpa-roam /ect/wpa_supplicant/wpa_supplicant.conf
#iface default inet dhcp
```

---

#Assign static IP

``` bash
sudo ifconfig wlan0 192.168.42.1
```

---

#Edit /etc/default/hostapd

``` bash
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

---

#Edit /etc/hostapd/hostapd.conf

``` bash
sudo nano /etc/hostapd/hostapd.conf
```

``` bash
# ...modify ssid with a name of your choice and wpa_passphrase to a WiFi authen
interface=wlan0
ssid=WiPi
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=xyz
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

---

#Configure network address translation

# Create a backup file
``` bash
sudo cp /etc/sysctl.conf /etc/sysctl.conf.backup
```


# ...edit the config file
``` bash
sudo nano /etc/sysctl.conf
```

# ...un-comment or add to the bottom:
``` bash
net.ipv4.ip_forward=1
```

# ...and activate it immediately:
``` bash
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
```

# ...modify the iptables to create a network translation between eth0 and the wifi port wlan0
``` bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

``` bash
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

``` bash
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
```

# ...make this happen on reboot by running

``` bash
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
``` bash

# ...and editing again

``` bash
sudo nano /etc/network/interfaces
```

# ...appending at then end:

``` bash
up iptables-restore < /etc/iptables.ipv4.nat
```

# Our /etc/network/interfaces file will now look like this:

``` bash
auto lo

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0

iface wlan0 inet static
  address 192.168.42.1
  netmask 255.255.255.0
```

---

# Let's clean everything:
``` bash
sudo service hostapd start
sudo service isc-dhcp-server start
```

# ...and make sure that we're up and running:
``` bash
sudo service hostapd status
sudo service isc-dhcp-server status
```

# ...let's configure our daemons to start at boot time:

``` bash
sudo update-rc.d hostapd enable
sudo update-rc.d isc-dhcp-server enable
```

# ...reboot the pi.

``` bash
sudo reboot
```

















