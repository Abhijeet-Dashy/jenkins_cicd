#!/bin/bash
set -e

# Add Swap Space
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Install AWS CLI and jq
apt-get update -y
apt-get install -y unzip jq curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

REGION="${region}"
PREFIX="${project_prefix}"
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Store Server IP
aws ssm put-parameter --region $REGION --name "/$PREFIX/k3s_server_ip" --value "$PRIVATE_IP" --type String --overwrite

# Generate & Store K3s Token
TOKEN=$(openssl rand -hex 16)
aws ssm put-parameter --region $REGION --name "/$PREFIX/k3s_token" --value "$TOKEN" --type SecureString --overwrite

# Install K3s Server
export K3S_TOKEN="$TOKEN"
curl -sfL https://get.k3s.io | sh -

# Wait for kubeconfig to be generated
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
  sleep 2
done

# Update kubeconfig to use private IP instead of localhost (so Jenkins can connect)
sed "s/127.0.0.1/$PRIVATE_IP/g" /etc/rancher/k3s/k3s.yaml > /tmp/kubeconfig.yaml
aws ssm put-parameter --region $REGION --name "/$PREFIX/kubeconfig" --value "$(cat /tmp/kubeconfig.yaml)" --type SecureString --overwrite
