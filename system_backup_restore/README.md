Use corresponding script for system backup and restore.
It is recommended to use tar-series scripts for better compatibility. 
When xfs-series scripts are used, please make sure the kernel version of source and target system are idential. Otherwise, it will fail to restore due to xfs driver issue. 

How to create a backup?
1: Boot the system to rescue mode using installation media(ISO/USB).
2: Modify the create_backup-<tar|xfs>.sh to specify disk for backup. 

How to restore the backup files to different disk?

Backup/Restore system uses tar-series script
create_backup-tar.sh  restore-tar.sh
After creating backup using create_backup-tar.sh, couple files will be generated. Script will create backup files for vfat and xfs partitions. The disk_layout file is used for restoration. 
content of disk_layout
1 vfat 5FC0-DB81 600    6 EF00 p1.tar.xz
2 xfs c713fc18-ca16-44da-90fa-8cddbf793266 1024  170 8300 p2.xz
3 swap 81147c6f-1a68-4e6b-b203-a697f90e812d 2048 0 8300 undefined
4 xfs 49848d7d-94d6-40f5-8d53-2d31caa58eaa 16806 1586 8300 p4.xz

create_backup-xfs.sh  restore-xfs.sh
After creating backup using create_backup-tar.sh, couple files will be generated. Script will create backup files for vfat and xfs partitions. The disk_layout file is used for restoration.
content of disk_layout 
1 vfat 5FC0-DB81 600    6 EF00 p1.tar.xz
2 xfs c713fc18-ca16-44da-90fa-8cddbf793266 1024  170 8300 p2.tar.xz
3 swap 81147c6f-1a68-4e6b-b203-a697f90e812d 2048 0 8300 undefined
4 xfs 49848d7d-94d6-40f5-8d53-2d31caa58eaa 16806 1586 8300 p4.tar.xz

