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
