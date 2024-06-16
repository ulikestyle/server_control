#!/bin/bash

sudo su - root

cat << "EOF"

                    QQQQQQQQQ       1111111   
                  QQ:::::::::QQ    1::::::1   
                QQ:::::::::::::QQ 1:::::::1   
               Q:::::::QQQ:::::::Q111:::::1   
               Q::::::O   Q::::::Q   1::::1   
               Q:::::O     Q:::::Q   1::::1   
               Q:::::O     Q:::::Q   1::::1   
               Q:::::O     Q:::::Q   1::::l   
               Q:::::O     Q:::::Q   1::::l   
               Q:::::O     Q:::::Q   1::::l   
               Q:::::O  QQQQ:::::Q   1::::l   
               Q::::::O Q::::::::Q   1::::l   
               Q:::::::QQ::::::::Q111::::::111
                QQ::::::::::::::Q 1::::::::::1
                  QQ:::::::::::Q  1::::::::::1
                    QQQQQQQQ::::QQ111111111111
                            Q:::::Q           
                             QQQQQQ  QUILIBRIUM.ONE                                                                                                                                

                              
===========================================================================
                       ✨ QNODE SERVICE UPDATER ✨
===========================================================================
This script will update your Quilibrium node when running it as a service.
It will run your node from the release_autostart.sh file.

Follow the guide at https://docs.quilibrium.one

Made with 🔥 by LaMat - https://quilibrium.one
===========================================================================

Processing... ⏳

EOF

sleep 7  # Add a 7-second delay

VERSION="1.4.19.1"

#==========================
# GO UPGRADE
#==========================

# Check the currently installed Go version
if go version &>/dev/null; then
    INSTALLED_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
else
    INSTALLED_VERSION="none"
fi

# If the installed version is not 1.22.4, proceed with the installation
if [ "$INSTALLED_VERSION" != "1.22.4" ]; then
    echo "Current Go version is $INSTALLED_VERSION. Proceeding with installation of Go 1.22.4..."

    # Determine the architecture and OS only if installing a new version
    ARCH=$(uname -m)
    OS=$(uname -s)

    # Determine the Go binary name based on the architecture and OS
    if [ "$ARCH" = "x86_64" ]; then
        if [ "$OS" = "Linux" ]; then
            GO_BINARY="go1.22.4.linux-amd64.tar.gz"
        elif [ "$OS" = "Darwin" ]; then
            GO_BINARY="go1.22.4.darwin-amd64.tar.gz"
        fi
    elif [ "$ARCH" = "aarch64" ]; then
        if [ "$OS" = "Linux" ]; then
            GO_BINARY="go1.22.4.linux-arm64.tar.gz"
        elif [ "$OS" = "Darwin" ]; then
            GO_BINARY="go1.22.4.darwin-arm64.tar.gz"
        fi
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi

    # Download and install Go
    wget https://go.dev/dl/$GO_BINARY > /dev/null 2>&1 || echo "Failed to download Go!"
    sudo tar -xvf $GO_BINARY > /dev/null 2>&1 || echo "Failed to extract Go!"
    sudo rm -rf /usr/local/go || echo "Failed to remove existing Go!"
    sudo mv go /usr/local || echo "Failed to move Go!"
    sudo rm $GO_BINARY || echo "Failed to remove downloaded archive!"
    
    echo "Go 1.22.4 has been installed successfully."
else
    echo "Go version 1.22.4 is already installed. No action needed."
fi

#==========================
# NODE UPDATE
#==========================

# Step 1: Stop the ceremonyclient service if it exists
echo "⏳ Stopping the ceremonyclient service if it exists..."
if systemctl is-active --quiet ceremonyclient && service ceremonyclient stop; then
    echo "🔴 Service stopped successfully."
else
    echo "❌ Ceremonyclient service either does not exist or could not be stopped." >&2
fi
sleep 1

# Step 2: Move to the ceremonyclient directory
echo "Step 2: Moving to the ceremonyclient directory..."
cd ~/ceremonyclient || { echo "❌ Error: Directory ~/ceremonyclient does not exist."; exit 1; }

# Step 3: Discard local changes in release_autorun.sh
echo "✅ Discarding local changes in release_autorun.sh..."
git checkout -- node/release_autorun.sh

# Step 4: Download Binary
echo "⏳ Downloading new release v$VERSION"

# Set the remote URL and download
cd  ~/ceremonyclient
git remote set-url origin https://github.com/QuilibriumNetwork/ceremonyclient.git
#git remote set-url origin https://source.quilibrium.com/quilibrium/ceremonyclient.git || git remote set-url origin https://git.quilibrium-mirror.ch/agostbiro/ceremonyclient.git
git checkout main
git branch -D release
git pull
git checkout release


echo "✅ Downloaded the latest changes successfully."

# Get the current user's home directory
HOME=$(eval echo ~$HOME_DIR)

# Use the home directory in the path
NODE_PATH="$HOME/ceremonyclient/node"
EXEC_START="$NODE_PATH/release_autorun.sh"

#==========================
# SERVICE UPDATE
#==========================

# Step 5: Re-Create or Update Ceremonyclient Service
echo "🔧 Rebuilding Ceremonyclient Service..."
sleep 2  # Add a 2-second delay
SERVICE_FILE="/lib/systemd/system/ceremonyclient.service"
if [ ! -f "$SERVICE_FILE" ]; then
    echo "📝 Creating new ceremonyclient service file..."
    if ! sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Ceremony Client Go App Service

[Service]
Type=simple
Restart=always
RestartSec=5s
WorkingDirectory=$NODE_PATH
ExecStart=$EXEC_START

[Install]
WantedBy=multi-user.target
EOF
    then
        echo "❌ Error: Failed to create ceremonyclient service file." >&2
        exit 1
    fi
else
    echo "🔍 Checking existing ceremonyclient service file..."
    
    # Check if the required lines exist or if CPUQuota exists
    if ! grep -q "WorkingDirectory=$NODE_PATH" "$SERVICE_FILE" || ! grep -q "ExecStart=$EXEC_START" "$SERVICE_FILE"; then
        echo "🔄 Updating existing ceremonyclient service file..."
        # Replace the existing lines with new values
        sudo sed -i "s|WorkingDirectory=.*|WorkingDirectory=$NODE_PATH|" "$SERVICE_FILE"
        sudo sed -i "s|ExecStart=.*|ExecStart=$EXEC_START|" "$SERVICE_FILE"
    else
        echo "✅ No changes needed."
    fi
fi


# Step 6: Start the ceremonyclient service
echo "✅ Starting Ceremonyclient Service"
sleep 2  # Add a 2-second delay
systemctl daemon-reload
systemctl enable ceremonyclient
service ceremonyclient start

# Showing the node version and logs
echo "🌟Your Qnode is now updated to V$VERSION !"
echo ""
echo "⏳ Showing the node log... (CTRL+C to exit)"
echo ""
echo ""
sleep 3  # Add a 5-second delay
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
