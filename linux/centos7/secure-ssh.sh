#secure.ssh.sh
#author Nicholas
#creates a new ssh user using 1 parameter
#adds a public key from the local repo or curled from the remote repo
#removes roots ability to ssh in

#!/bin/bash

USERNAME="$1"
LOCAL_KEY_PATH="./public_keys/${USERNAME}.pub"
REMOTE_KEY_URL="https://github.com/Skirmigle/SYS-265-Tech-Journal/public_keys/$USERNAME.pub"
SSHD_CONFIG="/etc/ssh/sshd_config"

#validation

if [[ $# -ne 1]]; then
	echo "no username"
	exit 1
fi

if [[ $EUID -ne 0 ]]; then
	echo "must be run as root"
	exit 1

# creates new user

if id "$USERNAME" &>/dev/null; then 
	echo "User already exists, user creation failed"
else
	useradd -m -s /bin/bash "$USERNAME"
	echo "User created Successfully"
fi

#Create ssh directory

USER_HOME=$(eval echo "~$USERNAME")
SSH_DIR="$USER_HOME/.ssh"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USERNAME:$USERNAME" "$SSH_DIR"

# adds new public key

PUBLIC_KEYS=$SSH_DIR/authorized_keys

if [[ -f "$LOCAL_KEY_PATH" ]] then
	cat "$LOCAL_KEY_PATH" >> "$PUBLIC_KEYS"
	echo "Public key added from local repo."
else
	echo "Local key not found. curling..."
	curl -fsSL "{REMOTE_KEY_URL}"" >> "$PUBLIC_KEYS
	echo "Public key added from remote repo."
fi

chmod 600 "$PUBLIC_KEYS"
chown "$USERNAME:$USERNAME" "$PUBLIC_KEYS"


# changes ssh permissions

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
	sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
else 
	echo "PermitRootLogin no" >> "$SSHD_CONFIG"
fi

# restart sshd and finish
systemctl restart sshd
echo "Task Completed"
