Enabling Wayland on NVidia binary driver in Fedora 31
=====================================================

In file `/usr/lib/udev/rules.d/61-gdm.rules`, comment out the following line:

```
DRIVER=="nvidia", RUN+="/usr/libexec/gdm-disable-wayland"
```

The rpmfusion nvidia driver package also disables Wayland separately. In file
`/etc/gdm/custom.conf`, comment out the following line:

```
WaylandEnable=false
```

Mount NTFS partitions in Fedora automatically
=============================================

Identify the partitions using `sudo blkid` - specifically their UUIDs.

Identify your UID and GID with `id -u` and `id -g` respectively.

Add an entry to `/etc/fstab` per partition, of the form:

```
# Mount NTFS partitions owned by user `titz`, group `titz`.
# Directory permissions: 750 / drxwr-x---.
# File permissions: 640 / rw-r-----.
UUID=0123456789ABCDEF   /media/windows          ntfs    defaults,windows_names,uid=1000,gid=1000,umask=000,dmask=027,fmask=137  0 0
```
