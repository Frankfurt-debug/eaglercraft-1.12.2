#!/usr/bin/env bash
# Eaglercraft 1.12.2 → Paper 1.21.4 server setup script
# Run this once on your VPS or PC to download everything and configure the stack.
# Requirements: Java 17+, curl, bash

set -e

PAPER_VERSION="1.21.4"

echo "=== Eaglercraft 1.12.2 Server Setup ==="
echo ""

# ── 1. Paper backend ──────────────────────────────────────────────────────────
echo "[1/4] Downloading Paper $PAPER_VERSION..."
mkdir -p paper/plugins
PAPER_BUILD=$(curl -fsSL "https://api.papermc.io/v2/projects/paper/versions/$PAPER_VERSION" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['builds'][-1])")
curl -fsSL -o paper/paper.jar \
  "https://api.papermc.io/v2/projects/paper/versions/$PAPER_VERSION/builds/$PAPER_BUILD/downloads/paper-$PAPER_VERSION-$PAPER_BUILD.jar"

# Accept EULA automatically
echo "eula=true" > paper/eula.txt

# Write server.properties
cat > paper/server.properties <<'EOF'
server-port=25565
online-mode=false
gamemode=survival
difficulty=normal
max-players=50
spawn-protection=0
view-distance=10
motd=Eaglercraft Server
EOF

# ── 2. Via* plugins (protocol translation 1.12.2 → 1.21.4) ──────────────────
echo "[2/4] Downloading ViaVersion + ViaBackwards..."

# Helper: download the latest release file for a Modrinth project that supports
# our Paper version. Falls back to the newest file if no exact game-version match.
modrinth_dl() {
  local slug="$1" out="$2"
  local url
  url=$(curl -fsSL "https://api.modrinth.com/v2/project/$slug/version" | python3 -c "
import sys, json
versions = json.load(sys.stdin)
def pick():
    for v in versions:
        if '$PAPER_VERSION' in v.get('game_versions', []) and 'paper' in v.get('loaders', []):
            return v['files'][0]['url']
    for v in versions:
        if '$PAPER_VERSION' in v.get('game_versions', []):
            return v['files'][0]['url']
    return versions[0]['files'][0]['url']
print(pick())
")
  curl -fsSL -o "$out" "$url"
}

modrinth_dl viaversion   paper/plugins/ViaVersion.jar
modrinth_dl viabackwards paper/plugins/ViaBackwards.jar

# ── 3. Velocity proxy ─────────────────────────────────────────────────────────
echo "[3/4] Downloading Velocity proxy..."
mkdir -p velocity/plugins
VELOCITY_VERSION=$(curl -fsSL "https://api.papermc.io/v2/projects/velocity" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['versions'][-1])")
VELOCITY_BUILD=$(curl -fsSL "https://api.papermc.io/v2/projects/velocity/versions/$VELOCITY_VERSION" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['builds'][-1])")
curl -fsSL -o velocity/velocity.jar \
  "https://api.papermc.io/v2/projects/velocity/versions/$VELOCITY_VERSION/builds/$VELOCITY_BUILD/downloads/velocity-$VELOCITY_VERSION-$VELOCITY_BUILD.jar"

# Generate a forwarding secret (used to authenticate the proxy → backend connection)
FORWARD_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32)

# Write velocity.toml
cat > velocity/velocity.toml <<EOF
config-version = "2.7"
bind = "0.0.0.0:25577"
motd = "<#09add3>Eaglercraft Server"
show-max-players = 50
online-mode = false
force-key-authentication = false
prevent-client-proxy-connections = false
player-info-forwarding-mode = "modern"
forwarding-secret-file = "forwarding.secret"
announce-forge = false
kick-existing-players = false
ping-passthrough = "DISABLED"
enable-player-address-logging = true

[servers]
  survival = "127.0.0.1:25565"
  try = ["survival"]

[forced-hosts]

[advanced]
  compression-threshold = 256
  compression-level = -1
  login-ratelimit = 3000
  connection-timeout = 5000
  read-timeout = 30000
  haproxy-protocol = false
  tcp-fast-open = false
  bungee-plugin-messaging-channel = true
  show-ping-requests = false
  failover-on-unexpected-server-disconnect = true
  announce-proxy-commands = true
  log-command-executions = false
  log-player-connections = true
  accepts-transfers = false

[query]
  enabled = false
  port = 25577
EOF

echo "$FORWARD_SECRET" > velocity/forwarding.secret

# ── 4. EaglerXServer plugin (WebSocket → Java protocol bridge) ────────────────
echo "[4/4] Downloading EaglerXServer plugin..."
curl -fsSL -o velocity/plugins/EaglerXServer.jar \
  "https://github.com/lax1dude/eaglerxserver/releases/latest/download/EaglerXServer.jar"

# Also needed on the Paper backend for modern forwarding support
curl -fsSL -o paper/plugins/EaglerXBackendRPC.jar \
  "https://github.com/lax1dude/eaglerxserver/releases/latest/download/EaglerXBackendRPC.jar" 2>/dev/null || \
  echo "  (EaglerXBackendRPC not found separately - check eaglerxserver releases page)"

# Paper needs modern forwarding secret too
mkdir -p paper/config
cat > paper/config/paper-global.yml <<EOF
proxies:
  velocity:
    enabled: true
    online-mode: false
    secret: "$FORWARD_SECRET"
EOF

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Forwarding secret: $FORWARD_SECRET"
echo "(already written to velocity/forwarding.secret and paper/config/paper-global.yml)"
echo ""
echo "Next steps:"
echo "  1. Run Paper first:    cd paper && java -Xmx2G -jar paper.jar --nogui"
echo "  2. Then run Velocity:  cd velocity && java -Xmx512M -jar velocity.jar"
echo "  3. Configure EaglerXServer WebSocket port (see velocity/plugins/EaglerXServer/)"
echo "  4. Players connect to:  wss://YOUR_IP:8081"
echo ""
echo "See START.sh to run both with a single command."
