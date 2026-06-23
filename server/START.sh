#!/usr/bin/env bash
# Starts Paper backend and Velocity proxy in separate screen sessions.
# Run setup.sh first if you haven't already.
# Requirements: screen, Java 17+

set -e

if ! command -v screen &>/dev/null; then
  echo "ERROR: 'screen' is not installed. Install it with: sudo apt install screen"
  exit 1
fi

if [ ! -f paper/paper.jar ]; then
  echo "ERROR: paper/paper.jar not found. Run setup.sh first."
  exit 1
fi

if [ ! -f velocity/velocity.jar ]; then
  echo "ERROR: velocity/velocity.jar not found. Run setup.sh first."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting Paper backend..."
screen -dmS paper bash -c "cd '$SCRIPT_DIR/paper' && java -Xmx2G -Xms512M -jar paper.jar --nogui; exec bash"
sleep 3

echo "Starting Velocity proxy..."
screen -dmS velocity bash -c "cd '$SCRIPT_DIR/velocity' && java -Xmx512M -jar velocity.jar; exec bash"

echo ""
echo "Both servers are running in screen sessions."
echo "  Attach to Paper:    screen -r paper"
echo "  Attach to Velocity: screen -r velocity"
echo "  Detach from screen: Ctrl+A then D"
echo ""
echo "Players connect via: wss://YOUR_IP:8081"
echo "To stop: screen -r paper  (then type 'stop'), and  screen -r velocity  (then Ctrl+C)"
