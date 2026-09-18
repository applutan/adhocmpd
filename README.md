# AdHocMPD

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux / macOS](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-blue.svg)](https://github.com/applutan/adhocmpd)
[![MPD Protocol](https://img.shields.io/badge/protocol-MPD-red.svg)](https://www.musicpd.org/)

**The "DJ Drop-In" queue preserver for Music Player Daemon (MPD).**

Interrupt any active playlist or stream to play a requested track, then seamlessly resume the original session right where you left off.

---

## The Problem

A universal frustration with media servers and streaming setups is **queue destruction**:

You have a curated session, radio stream, or a 1,000-track shuffle playlist going. Someone wants to hear *one specific song*. In virtually every player, queuing or playing that song either wipes out your queue, interrupts the entire flow, or leaves you stranded at the end of the song with silence.

## The Solution: AdHocMPD

`AdHocMPD` treats one-off song requests as a **DJ Drop-In**:

```
[ Active Queue: Track #758 @ 02:45 ]
               │
               ▼  (AdHocMPD "Oh Caroline")
┌───────────────────────────────────────────────────────┐
│ 1. Freezes session state (queue, track index, elapsed)│
│ 2. Switches to requested track and plays it           │
│ 3. Displays live ticking progress in your terminal    │
│ 4. Waits for track completion (or handles Ctrl+C)     │
│ 5. Restores original 1,000+ track queue               │
│ 6. Resumes Track #758 at the exact second (02:45)     │
└───────────────────────────────────────────────────────┘
```

---

## Features

* **Smart Search Normalization**:
  * Phonetic voice-to-text corrections (e.g. automatically resolves conversational speech *"Oh Caroline"* to the tagged title *"O Caroline"*).
  * Leading article stripping (`The`, `A`, `An`).
  * Multi-word AND search across all significant keywords.
* **Bulletproof Safety Trap (`Ctrl+C`)**:
  * If you interrupt or cancel playback early, the exit signal trap catches it and **guarantees** your original queue and position are restored immediately.
* **Repeat Loop Prevention**:
  * If your MPD server has `repeat: on`, a single drop-in track would loop forever. `AdHocMPD` temporarily suspends repeat mode for the drop-in and restores your exact mode settings (`repeat`, `random`, `single`, `consume`) on return.
* **Live Terminal Progress**:
  * Interactive progress meter showing elapsed and remaining duration (`⏱ Progress: 2:15/4:38 (48%)`).
* **Home Assistant & Pipeline Ready (`--json` & `--async`)**:
  * Machine-readable JSON output for APIs, voice satellites, and automation pipelines.
  * Detached background worker mode (`--async`) allowing voice engines to acknowledge commands immediately without hitting action timeouts.

---

## Installation

### Dependencies
Requires `mpc` (standard lightweight MPD client):
```bash
# Debian / Ubuntu
sudo apt install mpc jq

# Arch Linux
sudo pacman -S mpc jq

# Fedora
sudo dnf install mpc jq

# macOS
brew install mpc jq
```

### Quick Install

```bash
# Clone the repository
git clone https://github.com/applutan/adhocmpd.git
cd adhocmpd

# Install system-wide (requires sudo)
sudo ./install.sh

# OR install to user directory (~/.local/bin)
./install.sh --user
```

*(Alternatively, use `sudo make install` or simply copy `adhocmpd` into your `$PATH`).*

---

## Configuration

`AdHocMPD` uses a clean priority hierarchy:
1. CLI flags (`-h`, `-p`, `-P`)
2. Environment variables (`$MPD_HOST`, `$MPD_PORT`, `$MPD_PASSWORD`)
3. User config file (`~/.config/adhocmpd/config` or `~/.adhocmpd.conf`)
4. System config file (`/etc/adhocmpd.conf`)
5. Defaults (`localhost:6600`)

### Example Config (`~/.config/adhocmpd/config`)
```ini
# MPD host or IP address
MPD_HOST="192.168.1.100"

# MPD port (default: 6600)
MPD_PORT="6600"

# MPD server password (optional)
MPD_PASSWORD="mysecretpassword"
```

Secure your config file:
```bash
chmod 600 ~/.config/adhocmpd/config
```

---

## Usage

### Interactive CLI

```bash
# Search and play a track
adhocmpd "Goldberg Variations"

# Target a remote host explicitly
adhocmpd -h 192.168.1.50 -P secret "Karma Police"

# Press Ctrl+C at any time during playback to immediately restore previous session
```

### JSON Pipeline Mode (`-j` / `--json`)

```bash
adhocmpd -j "Roadwalkermash"
```

Outputs clean, structured JSON on `stdout` (with progress logs diverted to `stderr`):

```json
{
  "status": "completed",
  "async": false,
  "interrupted": {
    "track": "Said Rizan - Kinana (radio edit)",
    "position": 758,
    "elapsed": "3:52",
    "playlist_length": 1034
  },
  "dropin": {
    "track": "Utan Banan - RoadwalkerMash",
    "file": "Utan/AISuno/48-RoadwalkerMash.mp3",
    "query": "Roadwalkermash"
  },
  "tts_message": "Interrupting 'Said Rizan - Kinana (radio edit)' to play 'Utan Banan - RoadwalkerMash'. Resuming at 3:52 afterwards."
}
```

---

## Home Assistant & Voice Assistant Integration

When integrating with **Home Assistant Assist** or voice satellites (Wyoming / ESP32), voice engines typically expect an action to finish in 1–2 seconds so they can speak a confirmation back to the room.

Use the `-a, --async` flag combined with `-j, --json`:

```bash
adhocmpd -j -a "Roadwalkermash"
```

The script will snapshot the session, trigger the track, print the JSON payload, and detach the restoration monitor into the background—returning in ~200 ms.

### Home Assistant Automation Example

In Home Assistant's `configuration.yaml`:
```yaml
command_line:
  - switch:
      name: adhocmpd_runner
      command_on: "/usr/local/bin/adhocmpd -j -a"
```

Or trigger directly from an Assist sentence automation:
```yaml
alias: "Voice: Drop-In Song on MPD"
trigger:
  - platform: conversation
    command:
      - "play {song} on mpd"
      - "interrupt with {song}"
action:
  - service: shell_command.adhoc_dropin
    data:
      song: "{{ trigger.slots.song }}"
```

---

## License

Released under the [MIT License](LICENSE). Copyright (c) 2026 applutan.
