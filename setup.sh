#!/usr/bin/env bash
# YO Network Validator Node - Quick Setup Script
# Usage: curl -fsSL https://raw.githubusercontent.com/.../setup.sh | bash
# Or: bash <(curl -fsSL https://raw.githubusercontent.com/.../setup.sh)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CHAIN_ID="evmos_100892-1"
MONIKER="${MONIKER:-yo-validator-$(hostname)}"
EVMOS_VERSION="v20.0.0"
GENESIS_URL="https://rpc.yonetwork.io/genesis"
SEEDS="65ed28f1cd9405b613718c4930bf7e506de1e2b6@84.32.188.123:26656"
RPC_ENDPOINT="https://rpc.yonetwork.io:443"
HOME_DIR="${HOME}/.evmosd"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   YO Network Validator Node Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Node Type:${NC} Validator Node (Full Blockchain Node)"
echo -e "${YELLOW}Chain ID:${NC} $CHAIN_ID"
echo -e "${YELLOW}Moniker:${NC} $MONIKER"
echo -e "${YELLOW}Version:${NC} $EVMOS_VERSION"
echo ""
echo -e "${GREEN}This node creates validator keys for network participation.${NC}"
echo -e "${GREEN}It syncs blockchain data, validates blocks, and can earn rewards.${NC}"
echo ""

# Detect platform
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    arm64)   ARCH="arm64" ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

case "$OS" in
    linux)   PLATFORM="Linux" ;;
    darwin)  PLATFORM="Darwin" ;;
    *)
        echo -e "${RED}Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}[1/8]${NC} Detected platform: ${PLATFORM}_${ARCH}"

# Download Evmos binary
DOWNLOAD_URL="https://github.com/evmos/evmos/releases/download/${EVMOS_VERSION}/evmos_${EVMOS_VERSION#v}_${PLATFORM}_${ARCH}.tar.gz"
TEMP_DIR=$(mktemp -d)

echo -e "${GREEN}[2/8]${NC} Downloading Evmos ${EVMOS_VERSION}..."
curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/evmos.tar.gz" --progress-bar

echo -e "${GREEN}[3/8]${NC} Extracting binary..."
tar -xzf "$TEMP_DIR/evmos.tar.gz" -C "$TEMP_DIR"

# Install binary
INSTALL_DIR="/usr/local/bin"
if [ -w "$INSTALL_DIR" ]; then
    sudo=""
else
    sudo="sudo"
    echo -e "${YELLOW}Requesting sudo access to install binary...${NC}"
fi

$sudo mv "$TEMP_DIR/bin/evmosd" "$INSTALL_DIR/evmosd"
$sudo chmod +x "$INSTALL_DIR/evmosd"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}[4/8]${NC} Verifying installation..."
evmosd version

# Initialize node
echo -e "${GREEN}[5/8]${NC} Initializing node..."
if [ -d "$HOME_DIR" ]; then
    echo -e "${YELLOW}Warning: $HOME_DIR already exists. Backing up...${NC}"
    mv "$HOME_DIR" "${HOME_DIR}.backup.$(date +%s)"
fi

evmosd init "$MONIKER" --chain-id "$CHAIN_ID" --home "$HOME_DIR"

# Download genesis
echo -e "${GREEN}[6/8]${NC} Downloading genesis file..."
curl -L "$GENESIS_URL" -o "$HOME_DIR/config/genesis.json" --progress-bar

# Configure node
echo -e "${GREEN}[7/8]${NC} Configuring node..."
CONFIG_FILE="$HOME_DIR/config/config.toml"
APP_FILE="$HOME_DIR/config/app.toml"

# Important: This is a non-validating validator node
# No validator keys needed - node will sync and relay transactions only
echo -e "${YELLOW}Note: Validator node - will sync from validator network${NC}"

# Set seeds and persistent peers for guaranteed connection
sed -i.bak "s/^seeds = .*/seeds = \"$SEEDS\"/" "$CONFIG_FILE"
sed -i.bak "s/^persistent_peers = .*/persistent_peers = \"$SEEDS\"/" "$CONFIG_FILE"

# Enable state sync
LATEST_HEIGHT=$(curl -s "$RPC_ENDPOINT/block" | jq -r .result.block.header.height)
TRUST_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$RPC_ENDPOINT/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)

cat >> "$CONFIG_FILE" <<EOF

# State Sync Configuration
[statesync]
enable = true
rpc_servers = "$RPC_ENDPOINT,$RPC_ENDPOINT"
trust_height = $TRUST_HEIGHT
trust_hash = "$TRUST_HASH"
trust_period = "168h0m0s"
EOF

# Optimize settings
sed -i.bak 's/^pruning = .*/pruning = "custom"/' "$APP_FILE"
sed -i.bak 's/^pruning-keep-recent = .*/pruning-keep-recent = "100"/' "$APP_FILE"
sed -i.bak 's/^pruning-keep-every = .*/pruning-keep-every = "0"/' "$APP_FILE"
sed -i.bak 's/^pruning-interval = .*/pruning-interval = "10"/' "$APP_FILE"
sed -i.bak 's/^minimum-gas-prices = .*/minimum-gas-prices = "0aevmos"/' "$APP_FILE"

# Set chain-id in client.toml
CLIENT_FILE="$HOME_DIR/config/client.toml"
sed -i.bak "s/^chain-id = .*/chain-id = \"$CHAIN_ID\"/" "$CLIENT_FILE"

# Create systemd service (Linux only)
if [ "$PLATFORM" = "Linux" ] && command -v systemctl >/dev/null 2>&1; then
    echo -e "${GREEN}[8/8]${NC} Creating systemd service..."
    
    $sudo tee /etc/systemd/system/yonetwork.service > /dev/null <<EOF
[Unit]
Description=YO Network Validator Node
After=network-online.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=/usr/local/bin/evmosd start --home $HOME_DIR
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
StandardOutput=journal
StandardError=journal
SyslogIdentifier=yonetwork

[Install]
WantedBy=multi-user.target
EOF

    $sudo systemctl daemon-reload
    $sudo systemctl enable yonetwork
    
    echo ""
    echo -e "${GREEN}✓ Setup complete!${NC}"
    echo ""
    echo -e "${YELLOW}To start the node:${NC}"
    echo "  sudo systemctl start yonetwork"
    echo ""
    echo -e "${YELLOW}To check status:${NC}"
    echo "  sudo systemctl status yonetwork"
    echo ""
    echo -e "${YELLOW}To view logs:${NC}"
    echo "  sudo journalctl -u yonetwork -f"
    echo ""
    echo -e "${YELLOW}To check sync status:${NC}"
    echo "  evmosd status --home $HOME_DIR | jq .SyncInfo"
    
else
    echo -e "${GREEN}[8/8]${NC} Setup complete!"
    echo ""
    echo -e "${YELLOW}To start the node manually:${NC}"
    echo "  evmosd start --home $HOME_DIR"
    echo ""
    echo -e "${YELLOW}To check sync status:${NC}"
    echo "  evmosd status --home $HOME_DIR | jq .SyncInfo"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   YO Network Node Information${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}RPC:${NC} http://localhost:26657"
echo -e "${YELLOW}gRPC:${NC} localhost:9090"
echo -e "${YELLOW}Chain ID:${NC} $CHAIN_ID"
echo -e "${YELLOW}Home:${NC} $HOME_DIR"
echo -e "${GREEN}========================================${NC}"
