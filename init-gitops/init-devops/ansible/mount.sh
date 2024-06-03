#!/bin/bash

# init disk
umount /mnt/data || echo "not exists"

echo '
label: gpt
unit: sectors
sector-size: 512

/dev/vdb1 : start=2048' > mount.txt

parted /dev/vdb mklabel gpt

sfdisk /dev/vdb < mount.txt

mkfs.xfs /dev/vdb1

UUID=`blkid | grep '/dev/vdb1' | awk -F '"' '{ print $2 }'`
if [ -z "$UUID" ]; then
    echo "Failed to get UUID for /dev/vdb1"
    exit 1
fi

FSTAB_ENTRY="UUID=$UUID /mnt/data xfs rw,relatime,defaults 0 2"
# if /etc/fstab has same mount path, then overwrite it
grep "/mnt/data" /etc/fstab && sed -i "\|/mnt/data|c\\$FSTAB_ENTRY" /etc/fstab || echo "$FSTAB_ENTRY" >> /etc/fstab

mkdir -p /mnt/data && mount /dev/vdb1 /mnt/data

df -h | grep /mnt/data

partprobe && xfs_growfs /dev/vdb1

exit 0
