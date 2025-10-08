# YO Network Validator - Quick Start

The fastest way to run a YO Network **validator node**.

⚡ **This is a VALIDATOR node** - it can participate in consensus, validate blocks, and earn rewards!

## Install & Run (One Command)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YO-Corp/yonetwork-validator/main/setup.sh)
```

## Post-Installation

### Check Node Status
```bash
evmosd status | jq .SyncInfo
```

### View Logs (Linux with systemd)
```bash
sudo journalctl -u yonetwork -f
```

### Create Validator

1. **Wait for sync to complete** (catching_up = false)
2. **Create validator key**:
```bash
evmosd keys add validator --keyring-backend test
```

3. **Get your address**:
```bash
evmosd keys show validator -a --keyring-backend test
```

4. **Fund your address** with YO tokens

5. **Create validator**:
```bash
evmosd tx staking create-validator \
  --amount=1000000000000000000000aevmos \
  --pubkey=$(evmosd tendermint show-validator) \
  --moniker="MY_VALIDATOR" \
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

## Important Commands

### Check Validator Status
```bash
evmosd query staking validator $(evmosd keys show validator --bech val -a --keyring-backend test)
```

### Check Balance
```bash
evmosd query bank balances $(evmosd keys show validator -a --keyring-backend test)
```

### Backup Validator Key (CRITICAL!)
```bash
cp ~/.evmosd/config/priv_validator_key.json ~/priv_validator_key_backup.json
```

## Network Info

- **Chain ID**: evmos_100892-1
- **RPC**: https://rpc.yonetwork.io
- **Explorer**: https://explorer.yonetwork.io  
- **Currency**: YO (aevmos)
- **Min Stake**: 1,000 YO

---

For detailed documentation, see [README.md](README.md)
