#!/bin/sh
#
# USAGE: udev-auto-mount.sh DEVICE
#   DEVICE   is the name of the block device node at /dev/DEVICE
 
# This script takes a device name, looks up the partition label and
# type, creates /media/LABEL and mounts the partition.  Mount options
# based on filesystem type are hard-coded below.

DEVICE=$1

# Ensure we received input.
if [ -z "$DEVICE" ]; then
   echo "Error: Must be called with a device name."
   exit 1
fi

# Exit if the device is already mounted.
device_is_mounted=`mount | grep ${DEVICE}`
if [ -n "$device_is_mounted" ]; then
   echo "Error: /dev/${DEVICE} is already mounted."
   exit 1
fi

# If there's a problem at boot-time, this is where we'd put some test to
# check that we're booting, and then run
#     sleep 60
# so the system is ready for the mount below.
#
# An example to experiment with: Assume the system is "booted enough" if
# the HTTPD server is running.  If it isn't, sleep for half a minute
# before checking again.
#
# The risk: if the server fails for some reason, this mount script will
# just keep waiting for it to show up.  A better solution would be to
# check for some file that exists after the boot process is complete.
#
# HTTPD_UP=`ps -ax | grep httpd | grep -v grep` while [ -z "$HTTPD_UP"
# ]; do sleep 30 HTTPD_UP=`ps -ax | grep httpd | grep -v grep` done


# Use blkid to pull in useful variables.
eval `blkid -o udev /dev/${DEVICE}`

if [ -z "$ID_FS_LABEL" ] || [ -z "$ID_FS_TYPE" ]; then
   echo "Error: Neither ID_FS_LABEL nor ID_FS_TYPE are useful."
   echo "       (Check 'blkid -o /dev/${DEVICE}'.)"
   exit 1
fi


# Ensure the mountpoint does not exist.
MOUNTPT="${MOUNTPT}"
if [ ! -e "${MOUNTPT}" ]; then

  echo "Making mount point: ${MOUNTPT}"
  mkdir "${MOUNTPT}"

  # If expecting thumbdrives, you probably want:
  #    mount -t auto -o sync,noatime [...]
  # 
  # If drive is VFAT/NFTS, this mounts the filesystem such that all
  # files are owned by a normal user instead of by root.  Change to your
  # UID (run `id`).
  #
  # You may also want "gid=1000" and/or "umask=022":
  #    mount -t auto -o uid=1000,gid=1000 [...]
  # 
  # 
  case "$ID_FS_TYPE" in
    vfat)  mount -t vfat -o sync,noatime,uid=1000 /dev/${DEVICE} "${MOUNTPT}"
           ;;

           # The locale setting is helpful for NTFS.
    ntfs)  mount -t auto -o sync,noatime,uid=1000,locale=en_US.UTF-8 /dev/${DEVICE} "${MOUNTPT}"
           ;;

           # EXT2/3/4 don't like the "uid" option.
    ext*)  mount -t auto -o sync,noatime /dev/${DEVICE} "${MOUNTPT}"
           ;;

    *)     echo "Error: Unknown filesystem type on /dev/${DEVICE}.  Consult /usr/local/sbin/udev-auto-mount.sh"
           exit 1
           ;;
  esac

  # Mount was ok, return successful.
  exit 0

else
  echo "Error: ${MOUNTPT} unexpectedly already exists."
fi

echo "Error: Auto-mounting ${DEVICE} on ${MOUNTPT} failed."
exit 1
