# Eaglercraft 1.12.2 Survival Server

Connects Eaglercraft 1.12.2 browser clients to a Paper 1.21.4 backend.

## Architecture

```
Browser (Eaglercraft 1.12.2)
    | WebSocket :8081
Velocity proxy + EaglerXServer plugin   <- translates WebSocket -> TCP
    | TCP :25565 (modern forwarding)
Paper 1.21.4 + ViaVersion + ViaBackwards  <- translates 1.12.2 protocol -> 1.21.4
```

---

## How to host on GitHub Codespaces (step by step)

### Step 1 — Create the Codespace
1. Go to your repo on GitHub: `https://github.com/Frankfurt-debug/eaglercraft-1.12.2`
2. Click the green **Code** button → **Codespaces** tab
3. Click **Create codespace on claude/fervent-lamport-8azu5q**
4. Wait for it to load (1-2 minutes)

### Step 2 — Open a terminal
Press **Ctrl+`** (backtick) or go to **Terminal → New Terminal** in the top menu.

### Step 3 — Clone and run setup (first time only)
In the terminal, type these commands one at a time and press Enter after each:

```bash
cd ~/eaglercraft-1.12.2
git pull
cd server
chmod +x setup.sh START.sh
./setup.sh
```

This will automatically install everything needed and download all the server files.
It takes 2-3 minutes. Wait until you see `=== Setup complete! ===` before continuing.

### Step 4 — Open a second terminal
Click the **+** icon next to your terminal tab at the bottom to open a second terminal.

You now have **two terminals**. You need both running at the same time.

### Step 5 — Start Velocity in terminal 1
In the **first terminal**:
```bash
cd ~/eaglercraft-1.12.2/server
java -Xmx512M -jar velocity/velocity.jar
```
Wait until you see `Done` in the output before moving to the next step.

### Step 6 — Start Paper in terminal 2
In the **second terminal**:
```bash
cd ~/eaglercraft-1.12.2/server
java -Xmx2G -Xms512M -jar paper/paper.jar --nogui
```
Wait until you see `Done (Xs)! For help, type "help"` — the terminal is now your **Minecraft console**.

### Step 7 — Make yourself admin
In the Paper terminal (terminal 2), type:
```
op YourMinecraftUsername
```
Press Enter. No slash needed in the server console.

### Step 8 — Get your player connection URL
1. Click the **Ports** tab at the bottom of the Codespace window
2. Find port **8081** in the list
3. Right-click it → **Port Visibility** → set to **Public**
4. Copy the URL shown (looks like `https://xxxx-8081.app.github.dev`)
5. Change `https://` to `wss://` at the very start
6. That is your server address — paste it into the Eaglercraft client

**Example:** `wss://laughing-potato-abc123-8081.app.github.dev`

### Each time you reopen the Codespace
You do **not** need to run setup.sh again. Just repeat Steps 4-6 (start Velocity, then Paper).

---

## Useful server commands

Type these in the **Paper terminal** (terminal 2). No slash needed.

| What you want to do | Command |
|---|---|
| Make yourself admin | `op YourUsername` |
| Remove admin | `deop YourUsername` |
| See who is online | `list` |
| Kick a player | `kick PlayerName` |
| Ban a player | `ban PlayerName` |
| Change gamemode | `gamemode survival PlayerName` |
| Give yourself items | `give YourUsername minecraft:diamond 64` |
| Teleport to coordinates | `tp YourUsername 0 64 0` |
| Change time | `time set day` |
| Change weather | `weather clear` |
| Stop the server | `stop` |

---

## Troubleshooting

**`python3: command not found`**
Run `sudo apt-get install -y python3` in the terminal, then run `./setup.sh` again.

**Players can't connect**
- Make sure port 8081 is set to **Public** in the Ports tab
- Make sure both Velocity AND Paper are running
- Double-check you changed `https://` to `wss://` in the URL

**Codespace went to sleep**
Reopen it and repeat Steps 4-6. You do not need to run setup.sh again.

**Out of memory errors**
Change `-Xmx2G` to `-Xmx1G` in the Paper start command.
