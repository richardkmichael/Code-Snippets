# Auto-mount and unmount USB disks using udev rules

These scripts are based on [this StackOverflow
answer.](http://superuser.com/questions/53978/ubuntu-automatically-mount-external-drives-to-media-label-on-boot-without-a-u?lq=1)

The scripts have been found to be working on `Ubuntu 10.10` and `12.04.2
LTS`.  If they do not work for you, try to see if there are tips in the
original StackOverflow thread (above).  Contributions are welcome.

Scripts should be installed as:

  `/usr/local/sbin/udev-auto-mount.sh`
  `/usr/local/sbin/udev-auto-unmount.sh`

Udev rules should be installed as:

  `/etc/udev/rules.d/89-automount-usb-drives.rules`
