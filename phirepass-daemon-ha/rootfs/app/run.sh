#!/bin/bash
set -e

echo "Starting phirepass daemon addon..."

# Export all options from the JSON file as environment variables
if [ -f /data/options.json ]; then
    eval "$(jq -r 'to_entries | .[] | "export \(.key)=\(.value | @json)"' /data/options.json)"
fi

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -A
fi

# Configure SSH for passwordless login
echo "Configuring SSH for passwordless root access..."
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
sed -i 's/^PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Set root password to empty
passwd -d root 2>/dev/null || true

# Create authorized_keys directory for root
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Start SSH server in background
echo "Starting SSH server on ${SSH_HOST}:${SSH_PORT}..."
/usr/sbin/sshd -D &

echo "Running phirepass daemon..."

exec /app/daemon start
