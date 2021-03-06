# kvm修改逻辑卷的root目录大小
    > 此方式仅仅适用于kvm创建的虚拟机且用的自动分区为：lvm分区

```
$ df -h　　　　　　　　　　　　　　　　＃查看磁盘挂载情况
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/cl-root   50G   42G  8.8G  83% /
devtmpfs             3.9G     0  3.9G   0% /dev
tmpfs                3.9G     0  3.9G   0% /dev/shm
tmpfs                3.9G  8.4M  3.9G   1% /runumount
tmpfs                3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vda1           1014M  138M  877M  14% /boot
/dev/mapper/cl-home  142G   33M  142G   1% /home
tmpfs                783M     0  783M   0% /run/user/0
$ umount /home　　　　　　　　　　　　＃取消挂载不用的目录
$  df -h　　　　　　　　　　　　　　　　　＃再次查看
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/cl-root   50G   42G  8.8G  83% /
devtmpfs             3.9G     0  3.9G   0% /dev
tmpfs                3.9G     0  3.9G   0% /dev/shm
tmpfs                3.9G  8.4M  3.9G   1% /run
tmpfs                3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vda1           1014M  138M  877M  14% /boot
tmpfs                783M     0  783M   0% /run/user/0
$ lsblk　　　　　　　　　　　　　　　　＃再次查看不用的目录已经没挂载了
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sr0          11:0    1  1024M  0 rom
vda         252:0    0   200G  0 disk
├─vda1      252:1    0     1G  0 part /boot
└─vda2      252:2    0   199G  0 part
  ├─cl-root 253:0    0    50G  0 lvm  /
  ├─cl-swap 253:1    0   7.9G  0 lvm  [SWAP]
  └─cl-home 253:2    0 141.1G  0 lvm
$ pvdisplay　　　　　　　　　　　　　　＃查看物理卷的大小
  --- Physical volume ---
  PV Name               /dev/vda2
  VG Name               cl
  PV Size               199.00 GiB / not usable 3.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              50943
  Free PE               1
  Allocated PE          50942
  PV UUID               w5r2o1-8FbG-CzIZ-4pcM-JOwX-y2CQ-xwc9Ca

$ pvscan　　　　　　　　　　　　　　　
  PV /dev/vda2   VG cl              lvm2 [199.00 GiB / 4.00 MiB free]
  Total: 1 [199.00 GiB] / in use: 1 [199.00 GiB] / in no VG: 0 [0   ]
$ vgdisplay　　　　　　　　　　　　　　＃查看卷组详细信息，看卷组多大还有多少剩余
  --- Volume group ---
  VG Name               cl
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               199.00 GiB
  PE Size               4.00 MiB
  Total PE              50943
  Alloc PE / Size       50942 / 198.99 GiB
  Free  PE / Size       1 / 4.00 MiB
  VG UUID               lA2FFA-ilaR-Y9Ww-5kpm-OAKn-zVgl-IhB50f

$ lvdisplay　　　　　　　　　　　　　　查看所有的逻辑卷(里面就有我们要删除的部分)
  --- Logical volume ---
  LV Path                /dev/cl/swap
  LV Name                swap
  VG Name                cl
  LV UUID                tnt3vb-ulPD-IH35-htPw-X4lx-Mr4J-JxSu2Y
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2018-06-20 10:58:40 +0800
  LV Status              available
  # open                 2
  LV Size                7.88 GiB
  Current LE             2016
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/cl/home
  LV Name                home
  VG Name                cl
  LV UUID                yAxn2f-2bwy-Gawa-1pf6-qMCd-QBoy-FPsnLP
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2018-06-20 10:58:40 +0800
  LV Status              available
  # open                 0
  LV Size                141.12 GiB
  Current LE             36126
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/cl/root
  LV Name                root
  VG Name                cl
  LV UUID                lzYdIO-vz3n-Yjje-fnbG-nvyJ-df5g-gRsfup
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2018-06-20 10:58:41 +0800
  LV Status              available
  # open                 1
  LV Size                50.00 GiB
  Current LE             12800
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0

$ lv
lvchange     lvcreate     lvextend     lvmchange    lvmconfig    lvmdump      lvmpolld     lvmsar       lvremove     lvresize     lvscan
lvconvert    lvdisplay    lvm          lvmconf      lvmdiskscan  lvmetad      lvmsadc      lvreduce     lvrename     lvs
$ lvremove home　　　　　　　　　　　　　　　＃移除不要的逻辑卷，未成功
  Volume group "home" not found
  Cannot process volume group home
$ lvremove /dev/cl/home　　　　　　　　　　＃移除不要的逻辑卷，写具体路径，成功
Do you really want to remove active logical volume cl/home? [y/n]: y
  Logical volume "home" successfully removed
$ lvdisplay　　　　　　　　　　　　　　　　　＃再次查看，要删除的部分已经不在了
  --- Logical volume ---
  LV Path                /dev/cl/swap
  LV Name                swap
  VG Name                cl
  LV UUID                tnt3vb-ulPD-IH35-htPw-X4lx-Mr4J-JxSu2Y
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2018-06-20 10:58:40 +0800
  LV Status              available
  # open                 2
  LV Size                7.88 GiB
  Current LE             2016
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/cl/root
  LV Name                root
  VG Name                cl
  LV UUID                lzYdIO-vz3n-Yjje-fnbG-nvyJ-df5g-gRsfup
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2018-06-20 10:58:41 +0800
  LV Status              available
  # open                 1
  LV Size                50.00 GiB
  Current LE             12800
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0

$ vgdisplay　　　　　　　　　　　　　　　　　　　　　　＃看卷组是否回收了删除的逻辑卷
  --- Volume group ---
  VG Name               cl
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               199.00 GiB
  PE Size               4.00 MiB
  Total PE              50943
  Alloc PE / Size       14816 / 57.88 GiB
  Free  PE / Size       36127 / 141.12 GiB
  VG UUID               lA2FFA-ilaR-Y9Ww-5kpm-OAKn-zVgl-IhB50f

$ lvextend -L 120G /dev/c
cdrom            char/            cl/              console          core             cpu/             cpu_dma_latency  crash
$ lvextend -L 120G /dev/cl/
root  swap
$ lvextend -L 180G /dev/cl/root　　　　　　　　＃给逻辑卷增加到180Ｇ。(增加到、增加至，减少到、减少至的方法我写在最下面)
  Size of logical volume cl/root changed from 50.00 GiB (12800 extents) to 180.00 GiB (46080 extents).
  Logical volume cl/root successfully resized.
$ df -h
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/cl-root   50G   42G  8.8G  83% /
devtmpfs             3.9G     0  3.9G   0% /dev
tmpfs                3.9G     0  3.9G   0% /dev/shm
tmpfs                3.9G  8.4M  3.9G   1% /run
tmpfs                3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vda1           1014M  138M  877M  14% /boot
tmpfs                783M     0  783M   0% /run/user/0

$ lvdisplay　　　　　　　　　　　　　　　　　　　　＃查看逻辑卷确实增大了
  --- Logical volume ---
  LV Path                /dev/cl/swap
  LV Name                swap
  VG Name                cl
  LV UUID                tnt3vb-ulPD-IH35-htPw-X4lx-Mr4J-JxSu2Y
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2018-06-20 10:58:40 +0800
  LV Status              available
  # open                 2
  LV Size                7.88 GiB
  Current LE             2016
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/cl/root
  LV Name                root
  VG Name                cl
  LV UUID                lzYdIO-vz3n-Yjje-fnbG-nvyJ-df5g-gRsfup
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2018-06-20 10:58:41 +0800
  LV Status              available
  # open                 1
  LV Size                180.00 GiB
  Current LE             46080
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0

$ df -h　　　　　　　　　　　　　　　　＃然而实际没有增大。因为没有确认调整
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/cl-root   50G   42G  8.8G  83% /
devtmpfs             3.9G     0  3.9G   0% /dev
tmpfs                3.9G     0  3.9G   0% /dev/shm
tmpfs                3.9G  8.4M  3.9G   1% /run
tmpfs                3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vda1           1014M  138M  877M  14% /boot
tmpfs                783M     0  783M   0% /run/user/0
$ xfs_growfs /dev/mapper/cl-root　　　　　　　　　　　　　　　　＃确认调整
#centos6执行：resize2fs　　/dev/mapper/cl-root
meta-data=/dev/mapper/cl-root    isize=512    agcount=4, agsize=3276800 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=13107200, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=6400, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 13107200 to 47185920
$  df -h　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　＃调整成功
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/cl-root  180G   42G  139G  23% /
devtmpfs             3.9G     0  3.9G   0% /dev
tmpfs                3.9G     0  3.9G   0% /dev/shm
tmpfs                3.9G  8.4M  3.9G   1% /run
tmpfs                3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vda1           1014M  138M  877M  14% /boot
tmpfs                783M     0  783M   0% /run/user/0



注解：
lvextend -L 120G /dev/mapper/centos-home     //增大至120G
lvextend -L +20G /dev/mapper/centos-home     //增加20G
lvreduce -L 50G /dev/mapper/centos-home      //减小至50G
lvreduce -L -8G /dev/mapper/centos-home      //减小8G
resize2fs /dev/mapper/centos-home            //执行调整
```
