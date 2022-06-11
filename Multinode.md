# Multinode Setup (Regtest Mode)

## Preparation

Allow connections to LND over clearnet

1. Edit ~/citadel/lnd/lnd.conf, set `tor.active=0`

2. Restart LND container with `docker restart lightning`

## Using Lightning Polar

Make sure Citadel is running before starting Polar so that ports aren't occupied.

### Connecting Bitcoin Nodes

1. Open Polar, start a Bitcoin node and right click -> "Launch Terminal"
2. Connect to Citadel's Bitcoin node

```shell
bitcoin-cli addnode "172.17.0.1:8333" "add"
```

3. Verify the connection

```shell
bitcoin-cli getconnectioncount
```

4. Start mining some blocks

```shell
citadel auto-mine
```

or click "Quick Mine" in Polar

You should see synchronized block height on both nodes (you may have to refresh Polar)

### Opening Channels

Add some funds to your wallets

```shell
citadel fund
```

#### Citadel -> Polar

1. Click on the Lightning node you want to open a channel with in with in Polar
2. On the right, click on the "Connect" tab and copy "P2P External"
3. Replace the IP with `172.17.0.1`
4. Paste into "Open Channel" UI

#### Polar -> Citadel

1. Look up Citadel's node key with `lncli getinfo | jq .identity_pubkey -r` or find it in the UI
2. Find the Lightning node you want to open a channel from in Polar, right click -> "Launch Terminal"
3. Connect nodes
   - LND: `lncli connect <node_key>@172.17.0.1`
   - CLN: `lightning-cli connect <node_key>@172.17.0.1`
   - Eclair: `eclair-cli connect --uri=<node_key>@172.17.0.1`
4. Open a channel
   - LND: `lncli openchannel <node_key> 1000000`
   - CLN: `lightning-cli fundchannel <node_key> 1000000`
   - Eclair: `eclair-cli open --nodeId=<node_key> --fundingSatoshis=1000000`

If you find that your Polar nodes don't have a large enough balance, try opening some channels in Polar first and it will fund them for you.

## Using Extra Nodes In Citadel

_tbd_
