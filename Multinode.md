# Multinode Setup

## Preparation

Make sure Citadel is running before starting Polar so that ports aren't occupied.

Allow connections to LND over clearnet

1. Edit ~/citadel/lnd/lnd.conf, set `tor.active=0`

2. Restart LND container with `docker restart lightning`

## Using Lightning Polar

### Connecting Bitcoin Nodes

1. Open Polar, start a Bitcoin node and right click -> "Launch Terminal"
2. Connect to Citadel's Bitcoin Node

```shell
bitcoin-cli addnode "172.17.0.1:8333" "add"
```

3. Verify the connection

```shell
bitcoin-cli getconnectioncount
```

4. Start mining some blocks

`citadel auto-mine` or click "Quick Mine" in Polar

You should see synchronized block height on both nodes (you may have to refresh Polar)

### Opening Channels

Add some funds to your wallets

```shell
citadel fund
```

#### Citadel -> Polar

1. Click on the Lightning Node you want to open a channel with in with in Polar
2. On the right, click on the "Connect" tab and copy "P2P External"
3. Replace the IP with `172.17.0.1`
4. Paste into "Open Channel" UI

#### Polar -> Citadel

1. Find out node key with `lncli --network regtest getinfo` (look for `identity_pubkey`)
2. Find the Lightning Node you want to open a channel from in Polar, right click -> "Launch Terminal"
3. Connect nodes and open with `lncli --network regtest openchannel --node_key <node_key> --connect 172.17.0.1:9735 --local_amt 100000`

## Using Extra Nodes In Citadel

_tbd_
