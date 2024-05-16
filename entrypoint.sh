#!/bin/bash
set -eu

# Function to check if OpenVPN connection is established
check_vpn_connection() {
    # Check the status file for successful connection message
    if grep -q "CLIENT_LIST,Connected" /etc/openvpn/openvpn-status.log; then
        return 0  # Connection is established
    else
        return 1  # Connection is not yet established
    fi
}

# Ensure OpenVPN configuration is provided
if [ -z "${VPN_CONFIG:-}" ]; then
  echo "Error: VPN_CONFIG environment variable is not set."
  exit 1
fi

# Ensure OpenVPN username and password are provided
if [ -z "${VPN_USERNAME:-}" ] || [ -z "${VPN_PASSWORD:-}" ]; then
  echo "Error: VPN_USERNAME and VPN_PASSWORD environment variables are not set."
  exit 1
fi

# Create OpenVPN configuration file
echo "$VPN_CONFIG" > /etc/openvpn/config.ovpn

# Create OpenVPN auth file
echo -e "$VPN_USERNAME\n$VPN_PASSWORD" > /etc/openvpn/auth.txt
chmod 600 /etc/openvpn/auth.txt

# Start OpenVPN in the background
openvpn --config /etc/openvpn/config.ovpn --auth-user-pass /etc/openvpn/auth.txt --daemon

# Wait for the VPN to establish
echo "Waiting for VPN connection..."
while ! check_vpn_connection; do
  sleep 1
done

echo "VPN connection established."

# Prepare SSH keys and rsync
SSHPATH="$HOME/.ssh"
if [ ! -d "$SSHPATH" ]; then
  mkdir -p "$SSHPATH"
fi

echo "$DEPLOY_KEY" > "$SSHPATH/key"
chmod 600 "$SSHPATH/key"

SERVER_DEPLOY_STRING="$USERNAME@$SERVER_IP:$SERVER_DESTINATION"

# Sync files using rsync
sh -c "rsync $ARGS -e 'ssh -i $SSHPATH/key -o StrictHostKeyChecking=no -p $SERVER_PORT' $GITHUB_WORKSPACE/$FOLDER $SERVER_DEPLOY_STRING"
