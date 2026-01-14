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
