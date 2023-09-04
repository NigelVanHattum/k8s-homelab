# NFS

## Setup
```bash
# Show disks
$ fdisk -l

# Make FS on disk, use the desired disk path, in this case, /dev/sda
$ mkfs.ext4 /dev/sda 

# Mount the created FS
$ mkdir /mnt/hdd-0
$ mount /dev/sda /mnt/hdd-0

# Adjust /etc/fstab to include the following line
/dev/sda /mnt/hdd-0 ext4 defaults 0 0
```