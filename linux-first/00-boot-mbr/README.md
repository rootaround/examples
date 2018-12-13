# 00. Linux First. Boot (MBR)

Скрипты к статье: [https://rootaround.github.io/linux-first-boot-mbr/](https://rootaround.github.io/linux-first-boot-mbr/)

- create_mbr_hdd.sh - скрипт для создания образа в (/tmp) 

## usage

```bash
./create_mbr_hdd.sh

qemu-system-x86_64 -curses -m 128m -boot c -hda /tmp/mbr_boot/mbr_hdd.img

```