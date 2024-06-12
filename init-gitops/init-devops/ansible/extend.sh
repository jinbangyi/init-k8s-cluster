#!/bin/bash

umount /mnt/data || echo "not exists"

echo '
label: gpt
unit: sectors
sector-size: 512

/dev/vdb1 : start=2048' > mount.txt

sfdisk /dev/vdb < mount.txt

mount /dev/vdb1 /mnt/data

df -h | grep /mnt/data

partprobe && xfs_growfs /dev/vdb1

exit 0
