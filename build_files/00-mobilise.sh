#!/bin/bash

set -uexo pipefail

dnf -y copr enable pocketblue/sdm845
dnf -y copr enable pocketblue/common
dnf -y copr enable pocketblue/extra

dnf repolist

# Files

#cp -arfT /files/fwload/usr /usr

#cp -arfT /files/usbnet/etc /etc
#cp -arfT /files/usbnet/usr /usr

# Qualcomm tools and libs

dnf -y install \
    hexagonrpc \
    bootmac \
    tqftpserv \
    qbootctl \
    rmtfs \
    qcom-firmware \
    pil-squasher \
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

for pkg in kernel kernel-core kernel-modules kernel-modules-core; do
  rpm --erase $pkg --nodeps
done

pushd /usr/lib/kernel/install.d
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

dnf -y install kernel kernel-modules-extra --repo copr:copr.fedorainfracloud.org:pocketblue:sdm845 --setopt=tsflags=noscripts

rm -rf /boot/dtb

dnf -y copr disable pocketblue/sdm845
dnf -y copr disable pocketblue/common
dnf -y copr disable pocketblue/extra

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
depmod -a "$(ls -1 /lib/modules/ | tail -1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
