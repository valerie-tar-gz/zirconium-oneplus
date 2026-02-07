#!/bin/bash

set -uexo pipefail

dnf -y copr enable pocketblue/sdm845
dnf -y copr enable pocketblue/common
dnf -y copr enable pocketblue/extra

dnf repolist

# Files

#cp -arfT files/etc /etc
#cp -arfT files/usr /usr

# Qualcomm tools and libs

dnf -y install \
    hexagonrpc \
    bootmac \
    tqftpserv \
    qbootctl \
    rmtfs \
    qcom-firmware \
    sdm845-fwload \
    pd-mapper \
    libssc \
    qrtr

systemctl enable \
    hexagonrpcd-sdsp.service \
    bootmac-bluetooth.service \
    tqftpserv.service \
    qbootctl.service \
    rmtfs.service

# Audio

dnf -y install \
    alsa-utils \
    pipewire \
    pipewire-alsa \
    pipewire-pulseaudio \
    alsa-ucm-mobility-sdm845 \
    q6voiced

systemctl enable \
    q6voiced.service

systemctl mask \
    alsa-state.service \
    alsa-restore.service

# Other

dnf -y install \
    ath10k-shutdown \
    mobility-tweaks \
    buffyboard \
    dnsmasq

#systemctl enable \
#    msm-modem-uim-selection.service

# Kernel

mkdir /boot/dtb
dnf -y remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-headers
rm -rf /usr/lib/modules/*
dnf -y install kernel kernel-modules-extra
rm -rf /boot/dtb

dnf -y copr disable pocketblue/sdm845
dnf -y copr disable pocketblue/common
dnf -y copr disable pocketblue/extra

dnf -y remove gdm dms-greeter
dnf -y install gdm

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
depmod -a "$(ls -1 /lib/modules/ | tail -1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
