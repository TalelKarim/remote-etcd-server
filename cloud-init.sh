#!/usr/bin/env bash

set -e  # Exit script immediately on first error.
set -u  # Treat unset variables as an error and exit immediately.
set -o pipefail  # Prevent errors in a pipeline from being masked.


# Update package list and install dependencies
sudo apt-get update -y 
sudo apt-get install -y wget tar

# Define etcd version and download URL
ETCD_VERSION="v3.5.5"
DOWNLOAD_URL="https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz"

# Download and extract etcd
wget ${DOWNLOAD_URL}
tar -xvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz

# Move etcd binaries to /usr/local/bin
sudo mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin/

# Create etcd directories
sudo mkdir -p /etc/etcd /var/lib/etcd

# Create etcd user
sudo useradd -r -s /sbin/nologin -d /var/lib/etcd -m -c "etcd user" etcd

# Set ownership
sudo chown -R etcd:etcd /etc/etcd /var/lib/etcd

# Create etcd systemd service file
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
User=etcd
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name etcd-server \\
  --data-dir /var/lib/etcd \\
  --listen-client-urls http://0.0.0.0:2379 \\
  --advertise-client-urls http://0.0.0.0:2379 \\
  --listen-peer-urls http://0.0.0.0:2380 \\
  --initial-advertise-peer-urls http://0.0.0.0:2380 \\
  --initial-cluster-token etcd-cluster-1 \\
  --initial-cluster etcd-server=http://0.0.0.0:2380 \\
  --initial-cluster-state new
Restart=always
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start etcd service
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
