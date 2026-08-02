#!/bin/bash
set -e

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

apt-get update -y
apt-get install -y unzip jq curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

REGION="${region}"
PREFIX="${project_prefix}"

# Wait for token & server IP
while ! aws ssm get-parameter --region $REGION --name "/$PREFIX/k3s_token" --with-decryption &>/dev/null; do
  sleep 5
done
TOKEN=$(aws ssm get-parameter --region $REGION --name "/$PREFIX/k3s_token" --with-decryption --query "Parameter.Value" --output text)

while ! aws ssm get-parameter --region $REGION --name "/$PREFIX/k3s_server_ip" &>/dev/null; do
  sleep 5
done
SERVER_IP=$(aws ssm get-parameter --region $REGION --name "/$PREFIX/k3s_server_ip" --query "Parameter.Value" --output text)

export K3S_URL="https://$SERVER_IP:6443"
export K3S_TOKEN="$TOKEN"

curl -sfL https://get.k3s.io | sh -
