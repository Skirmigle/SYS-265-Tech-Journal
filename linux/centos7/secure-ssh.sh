#secure.ssh.sh
#author Nicholas
#creates a new ssh user using 1 parameter
#adds a public key from the local repo or curled from the remote repo
#removes roots ability to ssh in

#!/bin/bash

set -euo pipefail

USERNAME="$1"
USERHOME="/home/$USERNAME"
SSH_DIR="$USERHOME/.ssh"
PUB_KEY_SOURCE="linux/public-keys/id_rsa.pub"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# create user
useradd -m -d "$USERHOME" -s /bin/bash "$USERNAME"

# Create .ssh directory
mkdir "SSH_DIR"

# Copy public key to authorized_keys
cp "$PUB_KEY_SOURCE" "$AUTHORIZED_KEYS"

# Set permissions
chmod 700 "$SSH_DIR"
chmod 600 "$AUTHORIZED_KEYS"

#set ownership
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

# restart sshd and finish
systemctl restart sshd
echo "Task Completed, $USERNAME has been setup"
