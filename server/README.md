# Eaglercraft 1.12.2 Survival Server

Connects Eaglercraft 1.12.2 browser clients to a Paper 1.21.4 backend.

## Architecture

```
Browser (Eaglercraft 1.12.2)
    ↓ WebSocket :8081
Velocity proxy + EaglerXServer plugin   ← translates WebSocket → TCP
    ↓ TCP :25565 (modern forwarding)
Paper 1.21.4 + ViaVersion + ViaBackwards  ← translates 1.12.2 protocol → 1.21.4
```

## Requirements

- Java 17 or newer
- Linux/Mac (or WSL on Windows)
- At least 3GB RAM
- Ports **8081** (WebSocket) and **25565** (internal, can stay closed to outside) open

## Setup (run once)

```bash
cd server/
chmod +x setup.sh START.sh
./setup.sh
```

This downloads:
- Paper 1.21.4
- ViaVersion + ViaBackwards plugins
- Velocity proxy
- EaglerXServer plugin (WebSocket bridge)

## Start the server

```bash
./START.sh
```

## Connect

Point your Eaglercraft 1.12.2 client page at:
```
wss://YOUR_SERVER_IP:8081
```

If hosting on your PC, find your public IP at whatismyip.com and make sure port **8081** is forwarded on your router.

## Firewall (VPS)

```bash
# Allow WebSocket port for players
sudo ufw allow 8081
# Keep 25565 closed to outside (internal only between Velocity → Paper)
```

## Managing the server

```bash
screen -r paper      # Paper console (stop, op, etc.)
screen -r velocity   # Velocity console
# Press Ctrl+A then D to detach without stopping
```

## Adding plugins

Drop plugin JARs into `paper/plugins/` and restart Paper (`screen -r paper` → type `restart`).

## Troubleshooting

**Players can't connect:** Check that EaglerXServer is loaded in Velocity (`screen -r velocity`, look for EaglerXServer in startup logs). Verify port 8081 is open.

**"Outdated server" errors:** ViaVersion/ViaBackwards should handle this automatically. Check they're loaded in Paper's plugin list.

**White screen on client:** The client HTML page must point to the correct WebSocket address.
