#!/bin/sh
OFS=$IFS
IFS=$'\n'
source_disk=/dev/sda
mkdir /dev/shm/disk 2>/dev/null
mkdir /dev/shm/p 2>/dev/null
cwd=$(dirname $0)
[[ $cwd == "." ]] && cwd=$(pwd)

function get_disk_layout() {
  cat /dev/null > disk_layout
  for raw in $(lsblk -b -o fstype,uuid,name,size ${source_disk}|grep -v "^\ "|sed "1d");do
    fstype=$(echo $raw|awk '{print $1}')
    uuid=$(echo $raw|awk '{print $2}')
    pid=$(echo $raw|awk '{print $3}'|grep -E -o "$(basename ${source_disk}).*[0-9]{1,3}$"|tail -n 1|grep -E -o "[0-9]{1,3}$")
    psize=$(echo $raw|awk '{print $4}')
    psize=$(($psize/1024/1024))
    pname=$(ls ${source_disk}*|grep -E "${pid}$")
    case "${fstype}" in
      xfs|vfat)
        fname="p${pid}.tar.xz"
        mount $pname /dev/shm/disk
        used=$(df -BM --output=used /dev/shm/disk|sed "1d;s/M//g" 2>/dev/null)
        pcode=$(sgdisk -p ${source_disk} |awk '($1 == '${pid}'){print $6}')
        [[ $? -ne 0 ]] && used=0
        umount /dev/shm/disk
       ;;
      *)
        fname="undefined"
        used=0
        ;;
    esac
    echo ${pid} $fstype $uuid $psize $used $pcode $fname >> disk_layout
  done
}
function backup() {
  for raw in $(cat disk_layout|sort -n);do
    fstype=$(echo $raw|awk '{print $2}')
    uuid=$(echo $raw|awk '{print $3}')
    pid=$(echo $raw|awk '{print $1}')
    fname=$(echo $raw|awk '{print $7}')
    case "${fstype}" in
      xfs|vfat)
        echo "backup xfs"
        mount /dev/disk/by-uuid/${uuid} /dev/shm/disk
        cd /dev/shm/disk
        tar --selinux --acls --xattrs -cf - . |xz -T0 -e -9 > ${cwd}/${fname}
        cd $cwd
        umount /dev/shm/disk
        ;;
      swap)
        echo "skip swap backup"
        ;;
      *)
        echo skip;
        ;;
    esac
  done
}

get_disk_layout
backup
