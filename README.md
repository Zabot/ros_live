# ROS Live Environment
A build system for a live Debian stretch environment with
`ros-desktop-full` preinstalled and support for persistence.

## Usage
- Configure the settings in `config.sh` to your liking (Probably just the timezone)
- Add or removing any scripts in `install.d`. All of the scripts in `install.d` will
  be run as root in the chroot before the iso is built.
- Run `sudo make`. Make needs to be run as root in order to create and
  use the chroot that will become the live environment.

The resulting iso will be bootable via BIOS or EFI and is ready to be `dd`'d onto
a flash drive. As always with dd, make sure to check of is the correct drive

```
sudo dd bs=4M if=arc_live.iso of=/dev/sdb status=progress oflag=sync
```

