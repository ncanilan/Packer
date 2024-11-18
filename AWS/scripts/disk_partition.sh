#!/bin/bash
#

HOST_TYPE=$1
VOLUME_SIZE=$2
OPT_PARTITION=$3
VAR_OPT_PARTITION=$4
NSCLOGSERVER_PARTITION=$5
PG_PARTITION=$6

VOLUME_SIZE_G="${VOLUME_SIZE}G"

sudo yum install -y lvm2 cloud-utils-growpart

DEVICE=$(lsblk | grep "${VOLUME_SIZE}G" | awk '{print $1}')
if [ -z "$DEVICE" ]; then
  echo "Device with size $VOLUME_SIZE_G not found."
  exit 1
fi

sudo pvcreate /dev/$DEVICE
sudo vgcreate alvaria /dev/$DEVICE
sudo lvcreate -L ${OPT_PARTITION}G -n opt alvaria
sudo lvcreate -L ${VAR_OPT_PARTITION}G -n var_opt alvaria
if [[ "$PG_PARTITION" == "+100%FREE" ]]; then
  sudo lvcreate -l +100%FREE -n var_lib_pgsql alvaria
else
  sudo lvcreate -L ${PG_PARTITION}G  -n var_lib_pgsql alvaria
fi
sudo mkfs.xfs /dev/alvaria/opt
sudo mkfs.xfs /dev/alvaria/var_opt
sudo mkfs.xfs /dev/alvaria/var_lib_pgsql
sudo mount /dev/alvaria/opt /opt
sudo mount /dev/alvaria/var_opt /var/opt
sudo mkdir -p /var/lib/pgsql
sudo mount /dev/alvaria/var_lib_pgsql /var/lib/pgsql
echo '/dev/alvaria/opt /opt xfs defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/alvaria/var_opt /var/opt xfs defaults 0 0' | sudo tee -a /etc/fstab
echo '/dev/alvaria/var_lib_pgsql /var/lib/pgsql xfs defaults 0 0' | sudo tee -a /etc/fstab

sudo mount -a
