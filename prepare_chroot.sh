#!/bin/sh

# Bootstrap ourself into the chroot and run the rest
ischroot
if [ $? -eq 1 ]; then
  echo "Bootstrapping into chroot"
  cp $0 chroot/
  cp config.sh chroot/
  cp -r install.d/ chroot/
  chroot chroot/ /prepare_chroot.sh
  rm chroot/prepare_chroot.sh
  rm chroot/config.sh
  rm -rf chroot/install.d
  exit 0
fi

# Setup chroot enviorment
. /config.sh
export PATH="$PATH:/usr/sbin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

# Basic requirements to make image bootable
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "$HOSTNAME" > /etc/hostname
apt update
apt upgrade -y
apt install linux-image-amd64 live-boot systemd-sysv -y --no-install-recommends

# Add a new user with an unset password and require it be set on first login
useradd $USER_NAME -s /bin/bash -m -c "$USER_FULLNAME" -G sudo
passwd -d $USER_NAME
passwd -e $USER_NAME

# Setup localization
echo "$TIMEZONE" > /etc/timezone
apt install locales -y --no-install-recommends

echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen en_US.UTF-8
echo 'LANG=en_US.UTF-8' > /etc/default/locale

############## Barebones setup complete, install user information
# Run all scripts in /install.d
for f in install.d/*.sh; do
  echo "Running $f..."
  sh "$f"
done

