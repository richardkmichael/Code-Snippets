#!/bin/sh
#
# USAGE: udev-auto-unmount.sh DEVICE
#   DEVICE   is the name of the block device node at /dev/DEVICE

DEVICE=$1

# Ensure we received input.
if [ -z "${DEVICE}" ]; then
  echo "Error: Must be called with a device name."
  exit 1
fi

# Exit if the device is not mounted.
MOUNTPT=`mount | grep ${DEVICE} | cut -d ' ' -f 3`
if [ ! -n "${MOUNTPT}" ]; then
	echo "Error: ${DEVICE} is not mounted."
	exit 1
fi

# Ensure the mount point exists.
if [ -e "${MOUNTPT}" ]; then

  # Naive: lazy unmount (the device is already gone), then rm the mount point.
  umount -l "${MOUNTPT}" && rmdir "${MOUNTPT}" && exit 0

	echo "Error: ${MOUNTPT} failed to unmount."
	exit 1
fi

echo "Error: ${MOUNTPT} does not exist"
exit 1
