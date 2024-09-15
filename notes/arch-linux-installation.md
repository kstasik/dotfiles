
### Arch 

Download: https://archlinux.org/download/
Mac flash iso: https://wiki.archlinux.org/title/USB_flash_installation_medium
Installation: https://wiki.archlinux.org/title/Installation_guide#Acquire_an_installation_image

Pacstrap:

```
pacstrap /mnt base base-devel linux linux-firmware amd-ucode iwd networkmanager reflector vim openssh git
```

Iwd docs: https://wiki.archlinux.org/title/Iwd


Next steps (create user): 

```
https://wiki.archlinux.org/title/General_recommendations
```

### Arch next steps

Enable DHCP + DNS in iwd: https://wiki.archlinux.org/title/Iwd#Enable_built-in_network_configuration

sudo systemctl restart systemd-resolved
sudo systemctl restart iwd

pacman -S nvidia nvidia-settings nvidia-utils

kde + kde-applications

https://wiki.archlinux.org/title/SDDM


## Bootloader

### Extending EFI partition :(

`cfdisk` may be used to resize

Moving partition:

```
echo '+100M,' | sfdisk --move-data /dev/sdc -N 1
```

https://superuser.com/questions/541067/how-to-move-a-partition-in-gnu-linux

`ntfsfix` may be useful

To extends partition to filesystem it has to be recrated:

https://superuser.com/questions/1230741/how-to-resize-the-efi-system-partition


### Limine

Limine: https://wiki.archlinux.org/title/Limine
Add limine to nvram: https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface#efibootmgr
Limine config: https://github.com/limine-bootloader/limine/blob/v8.x/CONFIG.md

Get uuid of root filesystem: `blkid >> limine.conf`



