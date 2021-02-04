#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    sudo $0
    exit
fi

apt install -y bluez-tools

cat <<EOM > /etc/systemd/network/pan0.netdev
[NetDev]
Name=pan0
Kind=bridge
EOM

cat <<EOM >/etc/systemd/network/pan0.network
[Match]
Name=pan0

[Network]
Address=172.20.1.1/24
DHCPServer=yes
EOM

cat <<EOM >/etc/systemd/system/bt-agent.service
[Unit]
Description=Bluetooth Auth Agent

[Service]
ExecStart=/usr/bin/bt-agent -c NoInputNoOutput
Type=simple

[Install]
WantedBy=multi-user.target
EOM

cat <<EOM >/etc/systemd/system/bt-network.service
[Unit]
Description=Bluetooth NEP PAN
After=pan0.network

[Service]
ExecStart=/usr/bin/bt-network -s nap pan0
Type=simple

[Install]
WantedBy=multi-user.target
EOM

systemctl enable systemd-networkd
systemctl enable bt-agent
systemctl enable bt-network
systemctl start systemd-networkd
systemctl start bt-agent
systemctl start bt-network

bt-adapter --set Discoverable 1
