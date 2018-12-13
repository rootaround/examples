#!/bin/bash

_ROOT="/tmp/mbr_boot"
_LOOP="loop0"
_MOUNT_DIR="${_ROOT}/mbr_hdd"
_KERNEL="vmlinuz-4.4.0-131-generic"
_INITRD_DIR="${_ROOT}/initrd"

cd /tmp
rm -rf $_ROOT
mkdir $_ROOT
cd $_ROOT

dd if=/dev/zero of=${_ROOT}/mbr_hdd.img bs=1048576 count=256

parted -s ./mbr_hdd.img mktable msdos

# 1mb offset нужен для grub
parted -s ./mbr_hdd.img mkpart primary ext4 1 256
parted -s mbr_hdd.img set 1 boot
parted -s ./mbr_hdd.img print

losetup -f -P $_ROOT/mbr_hdd.img
lsblk

mkfs.ext4 /dev/${_LOOP}p1

mkdir -p ${_MOUNT_DIR}
mount /dev/${_LOOP}p1 ${_MOUNT_DIR}

ls ${_MOUNT_DIR}

grub-install \
--root-directory=${_MOUNT_DIR} \
--modules="part_msdos ext2" \
/dev/${_LOOP}

cp /boot/${_KERNEL} $_MOUNT_DIR/boot/vmlinuz

mkdir ${_INITRD_DIR}
cd ${_INITRD_DIR}

mkdir bin sys dev proc

wget https://busybox.net/downloads/binaries/1.27.1-i686/busybox -O bin/busybox

chmod +x bin/busybox

ln -s busybox bin/echo 
ln -s busybox bin/ash 
ln -s busybox bin/ls
ln -s busybox bin/cat

cp -a /dev/console ./dev
cp -a /dev/null ./dev
cp -a /dev/tty1 ./dev
cp -a /dev/tty2 ./dev

cat >> ./init << EOF
#!/bin/ash
/bin/ash --login
EOF

chmod +x init

find . | cpio -o -H newc | gzip -9 > ../initrd.img

cd ${_ROOT}

cp ${_ROOT}/initrd.img ${_MOUNT_DIR}/boot/initrd

cat >> ${_MOUNT_DIR}/boot/grub/grub.cfg << EOF
set default=0
set timeout=5

menuentry 'linux' {
  linux /boot/vmlinuz
  initrd /boot/initrd
}
EOF

umount ${_MOUNT_DIR}

losetup -d /dev/${_LOOP}

echo "done"

echo "run: qemu-system-x86_64 -curses -m 128m -boot c -hda /tmp/mbr_boot/mbr_hdd.img"