#!/bin/sh

# Enable non-free and install wifi firmware
echo "deb http://security.debian.org/debian-security stretch/updates main" \
  > /etc/apt/sources.list.d/debian-security.list
echo "deb http://httpredir.debian.org/debian/ stretch contrib non-free" \
  > /etc/apt/sources.list.d/debian-nonfree.list
apt update

apt install firmware-iwlwifi

