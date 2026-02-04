#!/bin/bash
set -e

export RUST_LOG=info

# Ensure UTF-8 locale is set
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "Starting phirepass agent addon..."

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
# Reference: https://github.com/hassio-addons/addon-ssh/blob/v22.0.3/ssh/rootfs/etc/ssh/sshd_config
echo "Configuring SSH for passwordless root access..."

sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
sed -i 's/^PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
sed -i 's/^#UsePAM.*/UsePAM no/' /etc/ssh/sshd_config
sed -i 's/^UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

# Set root password to empty
passwd -d root 2>/dev/null || true

# Note: authorized_keys setup is not required for passwordless login

# Start SSH server in background
echo "Starting SSH server on ${SSH_HOST}:${SSH_PORT}..."
/usr/sbin/sshd -D &

echo "Running phirepass agent..."

exec echo $PAT_TOKEN | /app/agent login --from-stdin

exec /app/agent start
