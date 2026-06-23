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

## How to run on GitHub Codespaces (step by step)

### Step 1 — Create the Codespace
1. Go to your repo on GitHub
2. Click the green **Code** button → **Codespaces** tab
3. Click **Create codespace on claude/fervent-lamport-8azu5q**
4. Wait for it to load (takes 1-2 minutes)

### Step 2 — Open a terminal
- Press **Ctrl+`** (backtick) or go to **Terminal → New Terminal** in the top menu

### Step 3 — Run setup (first time only)
Type this in the terminal and press Enter:
```
cd server && chmod +x setup.sh START.sh && ./setup.sh
```
Wait for it to finish downloading everything (takes 1-2 minutes).

### Step 4 — Start Velocity (the WebSocket proxy)
You need **two terminals** running at the same time. In your first terminal:
```
cd server && java -Xmx512M -jar velocity/velocity.jar
```
Leave this running. Open a **second terminal** (click the + icon next to the terminal tab).

### Step 5 — Start Paper (the game server / console)
In the second terminal:
```
cd server && java -Xmx2G -Xms512M -jar paper/paper.jar --nogui
```
The terminal will now become the **Minecraft server console**. You will see it say `Done!` when ready.

### Step 6 — Type server commands
Once you see `Done!` you can type commands directly in that terminal:
```
op YourUsername
```
```
gamemode creative YourUsername
```
```
whitelist add FriendName
```
```
list
```
Just type and press Enter — no slash needed in the server console (but /op works too).

### Step 7 — Get your player connection URL
1. Click the **Ports** tab at the bottom of the Codespace window
2. Find port **8081** in the list
3. Right-click it → **Port Visibility** → set to **Public**
4. Copy the URL shown (looks like `https://xxxx-8081.app.github.dev`)
5. Change `https://` to `wss://` at the start
6. Players paste that into the Eaglercraft server address box

Example: `wss://laughing-potato-abc123-8081.app.github.dev`

### Stopping the server
- In the Paper terminal, type `stop` and press Enter
- In the Velocity terminal, press **Ctrl+C**

---

## Useful server commands

| What you want to do | Command to type in Paper console |
|---|---|
| Make yourself admin | `op YourUsername` |
| Remove admin | `deop YourUsername` |
| See who's online | `list` |
| Kick a player | `kick PlayerName` |
| Ban a player | `ban PlayerName` |
| Change someone's gamemode | `gamemode survival PlayerName` |
| Give yourself items | `give YourUsername minecraft:diamond 64` |
| Teleport to coordinates | `tp YourUsername 0 64 0` |
| Change time | `time set day` |
| Change weather | `weather clear` |

---

## Troubleshooting

**Players can't connect:**
- Make sure port 8081 is set to **Public** in the Ports tab
- Make sure both Velocity AND Paper are running
- Double-check the `wss://` URL is correct

**Server says "outdated client" or similar:**
ViaVersion/ViaBackwards handle this automatically — check both plugins loaded by looking for them in the Paper startup messages.

**Codespace went to sleep:**
Just reopen it and run Steps 4 and 5 again. You do NOT need to run setup.sh again.

**Out of memory errors:**
Reduce Paper RAM: change `-Xmx2G` to `-Xmx1G` in Step 5.
