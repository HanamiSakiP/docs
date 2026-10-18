#!/bin/bash
set -e
rm -f /etc/apt/sources.list.d/*.bak.*
CODENAME=$(awk -F'=' '/^VERSION_CODENAME=/{gsub(/"/,"");print $2}' /etc/os-release)

if [ -f "/etc/apt/sources.list.d/debian.sources" ];then
cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.old
echo 'Types: deb' > /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://mirrors.tuna.tsinghua.edu.cn/debian' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME} ${CODENAME}-updates" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://mirrors.tuna.tsinghua.edu.cn/debian-security' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME}-security" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
else
cp /etc/apt/sources.list /etc/apt/sources.list.old
echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME} main contrib non-free non-free-firmware" > /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME}-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
fi

apt update
apt install -y ca-certificates

if [ -f "/etc/apt/sources.list.d/debian.sources" ];then
echo 'Types: deb' > /etc/apt/sources.list.d/debian.sources
echo 'URIs: https://mirrors.tuna.tsinghua.edu.cn/debian' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME} ${CODENAME}-updates" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: https://mirrors.tuna.tsinghua.edu.cn/debian-security' >> /etc/apt/sources.list.d/debian.sources
echo "Suites: ${CODENAME}-security" >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main contrib non-free non-free-firmware' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
else
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME} main contrib non-free non-free-firmware" > /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian ${CODENAME}-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security ${CODENAME}-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
fi

apt update
apt clean
rm -rf /var/lib/apt/lists/*