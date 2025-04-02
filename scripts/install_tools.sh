#!/bin/bash

# Установка kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo 'source <(kubectl completion bash)' >> /etc/bash.bashrc

# Установка talosctl
TALOS_VERSION=$(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -Lo /usr/local/bin/talosctl https://github.com/siderolabs/talos/releases/download/$TALOS_VERSION/talosctl-linux-amd64
chmod +x /usr/local/bin/talosctl
echo 'source <(talosctl completion bash)' >> /etc/bash.bashrc

# Создание директории для конфигурационных файлов
mkdir -p /home/ubuntu/.kube
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Установка дополнительных полезных инструментов
apt-get update
apt-get install -y jq vim tmux
