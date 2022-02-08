#!/bin/bash

### Create Raid-5
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
echo "==============================================================================================="
echo $(cat /proc/mdstat | grep "md*" ) | awk '{print "raid status - ", $1, $2, $3, $4}' | tr a-z A-Z
echo "==============================================================================================="
mkdir /etc/mdadm && touch /etc/mdadm/mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# Create Partitions
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

# Make file systems on Partitions
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

# Create folders for each Partitions
mkdir -p /raid/part{1,2,3,4,5}

# Mount Partitions
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done

# Make partition mounting permanent
for i in $(seq 1 5); do sudo echo "/dev/md0p$i     /raid/part$i     ext4     defaults     0 0" >> /etc/fstab; done