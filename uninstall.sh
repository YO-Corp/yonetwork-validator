#!/usr/bin/env bash
# Quick uninstall script for YO Network node

echo "Stopping YO Network node..."
sudo systemctl stop yonetwork 2>/dev/null || true
sudo systemctl disable yonetwork 2>/dev/null || true

echo "Removing systemd service..."
sudo rm -f /etc/systemd/system/yonetwork.service
sudo systemctl daemon-reload 2>/dev/null || true

echo "Removing binary..."
sudo rm -f /usr/local/bin/evmosd

echo "Backing up data..."
if [ -d "$HOME/.evmosd" ]; then
    mv "$HOME/.evmosd" "$HOME/.evmosd.backup.$(date +%s)"
    echo "Data backed up to $HOME/.evmosd.backup.*"
fi

echo ""
echo "✓ YO Network node uninstalled successfully!"
echo ""
echo "To remove backups:"
echo "  rm -rf ~/.evmosd.backup.*"
