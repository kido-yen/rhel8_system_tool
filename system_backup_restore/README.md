# The scripts
    Use corresponding script for system backup and restore.
    It can be used for system backup and restore between different size of disks and different type of disks.
    It is recommended to use tar-series scripts for better compatibility. 
    When xfs-series scripts are used, please make sure the kernel version of source and target system are idential. Otherwise, it will fail to restore due to xfs driver issue. 
Caution: Do not perform backup and restore on the same system unless the source disk is removed from system prior to running restore process.

# How to create a backup?
1. Boot the system to rescue mode using installation media(ISO/USB).
2. Mount formatted disk/partition to the system. (Optional. Only needed when your system memory is not large enough for storing the backup file.)
3. Modify the create_backup-<tar|xfs>.sh to specify disk for backup. Variable source_disk is used to define the source disk for backup.
4. Run the create_backup-<tar|xfs>.sh script to backup the system. (Please note, files will be created at the same directory as the scripts.)

# How to restore the backup files to different disk?
1. Boot the system to rescue mode using installation media(ISO/USB).
2. Place the backup files and scripts to the same directory. 
3. Modify the disk_layout file per your reference. (Optional. Detailed information of the file is listed below.)
4. Modify the restore-<tar|xfs>.sh to specify disk for backup. Variable disk is used to define the target disk for restore.
5. Run the restore-<tar|xfs>.sh script to start restoration process.

# The disk_layout file (generated by create_backup-<tar|xfs>.sh script automatically. )
<table border=1>
<tr><td>part_id</td><td>part_type</td><td>fs_uuid</td><td>part_size</td><td>used</td><td>part_code</td><td>part_backup</td></tr>
<tr><td>1</td><td>vfat</td><td>5FC0-DB81</td><td>600</td><td>6</td><td>EF00</td><td>EF00 p1.tar.xz</td></tr>
</table>
    The part_size and used are in MegaByte. part_size should be greater than used. If the target disk is smaller than the source one, the part_size can be reduced to fit disk size.

# content of disk_layout for tar-series backup
    1 vfat 5FC0-DB81 600    6 EF00 p1.tar.xz
    2 xfs c713fc18-ca16-44da-90fa-8cddbf793266 1024  170 8300 p2.xz
    3 swap 81147c6f-1a68-4e6b-b203-a697f90e812d 2048 0 8300 undefined
    4 xfs 49848d7d-94d6-40f5-8d53-2d31caa58eaa 16806 1586 8300 p4.xz

# content of disk_layout for xfs-series backup
    1 vfat 5FC0-DB81 600    6 EF00 p1.tar.xz
    2 xfs c713fc18-ca16-44da-90fa-8cddbf793266 1024  170 8300 p2.tar.xz
    3 swap 81147c6f-1a68-4e6b-b203-a697f90e812d 2048 0 8300 undefined
    4 xfs 49848d7d-94d6-40f5-8d53-2d31caa58eaa 16806 1586 8300 p4.tar.xz
