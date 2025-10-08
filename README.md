<div align="center">

# 🚀 YO Network Validator Node

**One-line installation for YO Network validator node with state sync**

[![GitHub Release](https://img.shields.io/github/v/release/YO-Corp/yonetwork-validator?style=for-the-badge&logo=github&color=blue)](https://github.com/YO-Corp/yonetwork-validator/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://github.com/YO-Corp/yonetwork-validator/blob/main/LICENSE)
[![YO Network](https://img.shields.io/badge/Network-YO%20Network-00D4AA?style=for-the-badge&logo=ethereum)](https://yonetwork.io)
[![Evmos v20.0.0](https://img.shields.io/badge/Evmos-v20.0.0-E74C3C?style=for-the-badge)](https://github.com/evmos/evmos/releases/tag/v20.0.0)

<h3>
  <a href="https://yonetwork.io">🌐 Website</a>
  <span> • </span>
  <a href="https://rpc.yonetwork.io">🔌 RPC</a>
  <span> • </span>
  <a href="https://explorer.yonetwork.io">🔍 Explorer</a>
  <span> • </span>
  <a href="#-quick-installation">📦 Install</a>
  <span> • </span>
  <a href="QUICKSTART.md">⚡ Quick Start</a>
</h3>

</div>

---

## 📖 What is a Validator Node?

A **validator node** is a **full blockchain node** that participates in network consensus and validation:

✅ **Validator Capabilities**:
- **Validates blocks** and participates in consensus
- **Signs transactions** and broadcasts to the network
- **Earns staking rewards** for securing the network
- Syncs complete blockchain data
- Provides RPC/gRPC endpoints
- Creates and manages validator keys
- Can be used as personal wallet node

✅ **Network Participation**:
- Proposes and votes on blocks
- Participates in governance
- Requires staking YO tokens
- Must maintain high uptime
- Secures the YO Network

✅ **Use Cases**:
- **Run a validator** - Earn rewards by securing the network
- **Personal RPC node** - Sign transactions with your own keys
- **Full node access** - Complete blockchain data and history
- **Network participation** - Vote on governance proposals
- **Development** - Test validator operations locally

🔒 **Security**: This node manages validator keys and stakes tokens. **Secure your keys properly** and ensure backup procedures are in place.

---

## 🚀 Quick Installation

### One-Line Install (Linux / macOS)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YO-Corp/yonetwork-validator/main/setup.sh)
```

### Alternative Installation Methods

<details>
<summary><b>📥 Download and Run</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/YO-Corp/yonetwork-validator/main/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```
</details>

<details>
<summary><b>🏷️ Custom Node Name</b></summary>

```bash
MONIKER="my-validator-name" bash <(curl -fsSL https://raw.githubusercontent.com/YO-Corp/yonetwork-validator/main/setup.sh)
```
</details>

## ⚙️ What the script does

1. **Detects platform** - Automatically detects OS (Linux/macOS) and architecture (amd64/arm64)
2. **Downloads binary** - Fetches Evmos v20.0.0 from official GitHub releases
3. **Installs binary** - Installs `evmosd` to `/usr/local/bin`
4. **Initializes node** - Creates config files in `~/.evmosd`
5. **Downloads genesis** - Fetches genesis.json from YO Network RPC
6. **Configures state sync** - Enables state sync for fast synchronization
7. **Sets up peers** - Connects to validator network
8. **Creates systemd service** - (Linux only) Sets up automatic startup

## 📋 Requirements

- **OS**: Linux or macOS
- **Architecture**: amd64 (x86_64) or arm64
- **Dependencies**: 
  - `curl`
  - `jq`
  - `tar`
  - `sudo` (for system-wide installation)

## 🔧 Node Management

### Start node (with systemd)
```bash
sudo systemctl start yonetwork
```

### Stop node
```bash
sudo systemctl stop yonetwork
```

### Restart node
```bash
sudo systemctl restart yonetwork
```

### View logs
```bash
sudo journalctl -u yonetwork -f
```

### Check sync status
```bash
evmosd status | jq .SyncInfo
```

### Check if node is catching up
```bash
evmosd status | jq -r '.SyncInfo.catching_up'
```

## 🌐 Network Information

- **Chain ID**: `evmos_100892-1`
- **RPC**: https://rpc.yonetwork.io
- **Explorer**: https://explorer.yonetwork.io
- **Currency**: YO
- **Decimals**: 18

## 🔗 Endpoints

After node is synced, it exposes:

- **Tendermint RPC**: http://localhost:26657
- **Cosmos gRPC**: localhost:9090
- **Cosmos REST**: http://localhost:1317

## 🛡️ Validator Setup

After node is synced, you can create a validator:

### 1. Create validator key (if not already created)
```bash
evmosd keys add validator --keyring-backend test
```

### 2. Get validator address
```bash
evmosd keys show validator -a --keyring-backend test
```

### 3. Fund your validator address
Send YO tokens to your validator address

### 4. Create validator
```bash
evmosd tx staking create-validator \
  --amount=1000000000000000000000aevmos \
  --pubkey=$(evmosd tendermint show-validator) \
  --moniker="YOUR_VALIDATOR_NAME" \
  --chain-id=evmos_100892-1 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --gas="auto" \
  --gas-adjustment=1.5 \
  --from=validator \
  --keyring-backend=test
```

## 📝 Configuration Files

All configuration is stored in `~/.evmosd/`:

- `config/config.toml` - Tendermint configuration (P2P, RPC settings)
- `config/app.toml` - Application configuration (pruning, gas prices)
- `config/genesis.json` - Genesis state (downloaded from validator)
- `config/priv_validator_key.json` - **CRITICAL** - Validator private key (BACKUP THIS!)
- `config/node_key.json` - P2P node private key
- `data/` - Blockchain data (synced from network)

## 🔐 Security Notes

⚠️ **CRITICAL - Validator Keys**:
- **BACKUP** your `priv_validator_key.json` file
- **NEVER** share your validator private keys
- **SECURE** your server with firewall and SSH keys
- **MONITOR** your validator uptime

✅ **Best Practices**:
- Use strong passwords
- Enable firewall (allow only necessary ports)
- Keep system updated
- Monitor disk space
- Set up alerting for downtime
- Consider using sentry nodes
- Regular backups of keys

## 🛠️ Troubleshooting

### Check if binary is installed
```bash
evmosd version
```

### Check if node is running
```bash
ps aux | grep evmosd
```

### Reset node (delete all data)
```bash
evmosd tendermint unsafe-reset-all --home ~/.evmosd
```

### Backup validator key
```bash
cp ~/.evmosd/config/priv_validator_key.json ~/priv_validator_key_backup.json
```

## 🌐 YO Network Links

<table>
  <tr>
    <td align="center">
      <a href="https://yonetwork.io">
        <img src="https://img.shields.io/badge/Website-yonetwork.io-00D4AA?style=for-the-badge&logo=safari" alt="Website"/>
      </a>
    </td>
    <td align="center">
      <a href="https://rpc.yonetwork.io">
        <img src="https://img.shields.io/badge/RPC-rpc.yonetwork.io-3498DB?style=for-the-badge&logo=ethereum" alt="RPC"/>
      </a>
    </td>
    <td align="center">
      <a href="https://explorer.yonetwork.io">
        <img src="https://img.shields.io/badge/Explorer-explorer.yonetwork.io-9B59B6?style=for-the-badge&logo=blockchaindotcom" alt="Explorer"/>
      </a>
    </td>
  </tr>
</table>

## 💬 Support & Community

<table>
  <tr>
    <td>
      <strong>🐛 Issues</strong><br/>
      Report bugs and feature requests
    </td>
    <td>
      <a href="https://github.com/YO-Corp/yonetwork-validator/issues">GitHub Issues</a>
    </td>
  </tr>
  <tr>
    <td>
      <strong>💡 Discussions</strong><br/>
      Ask questions and share ideas
    </td>
    <td>
      <a href="https://github.com/YO-Corp/yonetwork-validator/discussions">GitHub Discussions</a>
    </td>
  </tr>
  <tr>
    <td>
      <strong>🌐 Website</strong><br/>
      Official YO Network website
    </td>
    <td>
      <a href="https://yonetwork.io">yonetwork.io</a>
    </td>
  </tr>
</table>

## 📄 License

This project is licensed under the [MIT License](LICENSE).

<div align="center">

---

**Made with ❤️ for the YO Network community**

[Website](https://yonetwork.io) • [RPC](https://rpc.yonetwork.io) • [Explorer](https://explorer.yonetwork.io)

</div>
