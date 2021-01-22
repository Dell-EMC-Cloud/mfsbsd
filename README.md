If you don't have a FreeBSD machine, you need to create a FreeBSD VM. The latest version should work just fine.

Check ci/ci.sh on how to download the FreeBSD kernel and base. Assuming that they are downloaded to the directory /tmp/freebsd:

To build a raw image:

```
make BASE=/tmp/freebsd
```

To build an iso:

```
make iso BASE=/tmp/freebsd
```


ORIGINAL Contents:

# mfsBSD

Copyright (c) 2019 Martin Matuska <mm at FreeBSD.org>

Version 2.3

## Description

This is a set of scripts that generates a bootable image, ISO file or boot 
files only, that create a working minimal installation of FreeBSD. This
minimal installation gets completely loaded into memory.

The image may be written directly using dd(1) onto any bootable block device,
e.g. a hard disk or a USB stick e.g. /dev/da0, or a bootable slice only, 
e.g. /dev/ada0s1

## Build-time requirements
 - FreeBSD 11 or higher installed, tested on i386 or amd64
 - base.txz and kernel.txz from a FreeBSD 11 or higher distribution

## Runtime requirements
 - a minimum of 512MB system memory

## Other information

See [BUILD](./BUILD.md) and [INSTALL](./INSTALL.md) for building and installation instructions.

Project homepage: http://mfsbsd.vx.sk

This project is based on the ideas of the depenguinator project:
http://www.daemonology.net/depenguinator/
