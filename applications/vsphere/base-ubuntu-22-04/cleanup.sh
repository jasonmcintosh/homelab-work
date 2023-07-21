#!/bin/bash

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

set -v


apt update -y
apt dist-upgrade -y

apt install openssh-server net-tools perl open-iscsi ntp curl dnsutils traceroute vim ifupdown dos2unix zip unzip gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release python3-pip jq -y
apt install -y open-vm-tools
apt install -y iptables-persistent
apt install -y docker.io

apt autoremove -y
apt clean


## Disabling ipv6
echo net.ipv6.conf.all.disable_ipv6=1 | tee -a /etc/sysctl.conf
echo net.ipv6.conf.default.disable_ipv6=1 | tee -a /etc/sysctl.conf
echo net.ipv6.conf.l0.disable_ipv6=1 | tee -a /etc/sysctl.conf
sysctl -p



echo '> Cleaning all audit logs ...'
service rsyslog stop
if [ -f /var/log/wtmp ]; then
    truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    truncate -s0 /var/log/lastlog
fi

# cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

# Cleans SSH keys.
echo '> Cleaning SSH keys ...'
rm -f /etc/ssh/ssh_host_*

# add check for ssh keys on reboot...regenerate if neccessary
cat << 'EOL' | tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# dynamically create hostname (optional)
if hostname | grep localhost; then
    hostnamectl set-hostname "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')"
fi

test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

cat << 'EOL' | tee /var/lib/cloud/scripts/per-once/resizefs
#!/bin/sh
/usr/bin/growpart /dev/sda 3
/usr/sbin/pvresize -y -q /dev/sda3
/usr/sbin/lvresize -y -q -r -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
/usr/sbin/resize2fs -fF /dev/mapper/ubuntu--vg-ubuntu--lv
EOL
chmod 755 /var/lib/cloud/scripts/per-once/resizefs

# make sure the script is executable
chmod +x /etc/rc.local


## Cloud config hostname handling
# prevent cloudconfig from preserving the original hostname
echo '> Setting hostname to localhost ...'
sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost


# disable swap
swapoff --all
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab


# make machine-id unique and symlink it - ubuntu 20.04 uses machine id in the dhcp identifier and not mac addresses
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id


# Cleans apt-get.
echo '> Cleaning apt-get ...'
apt-get clean


# Cleans the machine-id.
echo '> Cleaning the machine-id ...'
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# optional: cleaning cloud-init
cloud-init clean --logs
rm /etc/netplan/*.yaml
cat /dev/null > ~/.bash_history && history -c

echo "run 'sudo shutdown -h now'"
