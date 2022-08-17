#!/bin/sh
disk=/dev/sda
cwd=$(dirname $0)
OFS=$IFS
IFS=$'\n'
mkdir /dev/shm/disk > /dev/null 2>&1
[[ $cwd == "." ]] && cwd=$(pwd)
if [ ! -f disk_layout ];then
  echo "disk_layout cannot be found"
  exit 1
fi

function create_disk_layout() {
  sgdisk -Z ${disk}
  sleep 3
  partprobe ${disk}
  sleep 3
  for raw in $(cat disk_layout|sort -n);do
    psize=$(echo $raw|awk '{print $4}')
    fstype=$(echo $raw|awk '{print $2}')
    uuid=$(echo $raw|awk '{print $3}')
    pid=$(echo $raw|awk '{print $1}')
    pcode=$(echo $raw|awk '{print $6}')
    if [ "${psize}" == "rest" ];then
      psize=""
    else
      psize="+${psize}MiB"
    fi
    case "${fstype}" in
      vfat)
          uuid=$(echo $uuid|sed "s/\-//g")
          sgdisk -n ${pid}::${psize} -t ${pid}:${pcode} ${disk} > /dev/null 2>&1
          [[ $? -ne 0 ]] && sgdisk -n ${pid}:: -t ${pid}:${pcode} ${disk}
          sleep 2
          partprobe ${disk}
          sleep 2
          pname=$(ls ${disk}*|grep -E "${pid}$")
          mkfs.vfat -i ${uuid} ${pname} > /dev/null 2>&1
          ;;
      xfs)
          sgdisk -n ${pid}::${psize} -t ${pid}:${pcode} ${disk} > /dev/null 2>&1
          [[ $? -ne 0 ]] && sgdisk -n ${pid}:: -t ${pid}:${pcode} ${disk}
          sleep 2
          partprobe ${disk}
          sleep 2
          pname=$(ls ${disk}*|grep -E "${pid}$")
          mkfs.xfs -f -m uuid=${uuid} ${pname} > /dev/null 2>&1
          ;;
      swap)
          sgdisk -n ${pid}::${psize} -t ${pid}:${pcode} ${disk} > /dev/null 2>&1
          [[ $? -ne 0 ]] && sgdisk -n ${pid}:: -t ${pid}:${pcode} ${disk}
          pname=$(ls ${disk}*|grep -E "${pid}$")
          mkswap -U ${uuid} ${pname}
          ;;
      *)
          echo "skip. unknown fs $fstype"
          ;;
    esac
  done
}

function restore_data() {
  for raw in $(cat disk_layout|sort -n);do
    fstype=$(echo $raw|awk '{print $2}')
    uuid=$(echo $raw|awk '{print $3}')
    pid=$(echo $raw|awk '{print $1}')
    fname=$(echo $raw|awk '{print $7}')
    case "${fstype}" in
      vfat)
          echo "restore vfat"
          mount /dev/disk/by-uuid/${uuid} /dev/shm/disk
          tar --selinux --acls --xattrs -Jxf ${fname} -C /dev/shm/disk 2>/dev/null
          umount /dev/shm/disk
          ;;
      xfs)
          echo "restore xfs"
          mount /dev/disk/by-uuid/${uuid} /dev/shm/disk
          tar --selinux --acls --xattrs -Jxf ${fname} -C /dev/shm/disk 2>/dev/null
          umount /dev/shm/disk
          ;;
      *)
          echo "skip. unknown fs $fstype"
          ;;
    esac
  done
}
create_disk_layout
restore_data
