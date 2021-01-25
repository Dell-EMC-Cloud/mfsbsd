#! /bin/sh

set -e
set -x

MYINSTALLTAR="/tmp/install.tar.gz"
fetch $1 --output ${MYINSTALLTAR}

BOOTDISK=`geom disk list | grep 16G -B 1 | head -1 | awk '{print $3}'`    
gpart create -s gpt ${BOOTDISK}
gpart add -i 1 -t freebsd-boot -s 64k -l boot -a 1M ${BOOTDISK}
gpart add -i 2 -t freebsd-ufs -s 2g -f isi-active -a 1M -l root0 ${BOOTDISK}
gpart add -i 3 -t freebsd-ufs -s 1g -l var0 -a 1M ${BOOTDISK}

gmirror label root0 ${BOOTDISK}p2
gmirror label var0 ${BOOTDISK}p3

gmirror load 

newfs -b 16k -f 2k /dev/mirror/root0
newfs -b 16k -f 2k /dev/mirror/var0

#newfs -b 16k -f 2k /dev/${BOOTDISK}p2
#newfs -b 16k -f 2k /dev/${BOOTDISK}p3

mkdir -p root0
mount /dev/mirror/root0 ./root0
#mount /dev/${BOOTDISK}p2 ./root0
install -d -m 755 ./root0/var
mount /dev/mirror/var0 ./root0/var
#mount /dev/${BOOTDISK}p3 ./root0/var

tar xpf "$MYINSTALLTAR" -C ./root0

gpart bootcode -b ./root0/boot/pmbr ${BOOTDISK}
gpart bootcode -p ./root0/boot/gptboot -i 1 ${BOOTDISK}

# Fixup ttys?  (Do we need this? / It doesn't seem to harm HV, but I haven't tried dropping it.)
sed -i "" -E -e 's,^(ttyu0[[:space:]]+[^[:space:]]+[[:space:]]+)3wire(.*),\1 std.115200\2,' ./root0/etc/ttys

fetch $2 --output /tmp/isilon_machine_id_fallback
cp /tmp/isilon_machine_id_fallback ./root0/etc/isilon_machine_id_fallback

echo 'ifconfig_em0="DHCP"' >> ./root0/etc/rc.conf

# Bump up msgbuf size, the memory is cheap.
echo 'kern.msgbufsize="512k"' | tee -a ./root0/boot/loader.conf >/dev/null

umount ./root0/var
umount ./root0

# Prevent mirror from bouncing back while we spin the thing down
sysctl kern.geom.notaste=1

gmirror stop root0
gmirror stop var0

sysctl kern.geom.notaste=0
