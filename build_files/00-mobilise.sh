#!/bin/bash

mkdir /boot/dtb
dnf -y remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core
rm -rf /usr/lib/modules/*
dnf -y copr enable pocketblue/sdm845
dnf -y copr disable pocketblue/sdm845
dnf -y --enablerepo copr:copr.fedorainfracloud.org:pocketblue:sdm845 install \
    kernel \
    kernel-modules-extra
rm -rf /boot/dtb

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
