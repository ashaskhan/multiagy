# 🌌 Multiagy

> **The production-ready profile, session, and quota manager for the Antigravity IDE.**  
> Run unlimited Antigravity profiles simultaneously — each with its own isolated accounts, settings, and quotas.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Linux | macOS](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)](#install)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](#install)

---

## 📖 Table of Contents
- [Why Multiagy?](#-why-multiagy)
- [The Linux Keyring Fix](#-the-secret-sauce-the-linux-keyring-fix)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Auth-Only Profiles (Save Disk Space)](#-auth-only-profiles-save-disk-space)
- [The Quota Pooling Playbook](#-the-quota-pooling-playbook)
  - [Strategy 1: The Relay / Quota Failover](#strategy-1-the-relay--quota-failover)
  - [Strategy 2: The Git Worktree Swarm](#strategy-2-the-git-worktree-swarm)
  - [Strategy 3: Specialized Agent Swarms](#strategy-3-specialized-agent-swarms)
- [Command Reference](#-command-reference)
- [Storage & Cache Cleanup](#-storage--cache-cleanup)
- [Troubleshooting & Diagnostics](#-troubleshooting--diagnostics)
- [Credits & Attribution](#-credits--attribution)

---

## ❓ Why Multiagy?

By default, the **Antigravity IDE** enforces a single global session:
1. **Account Conflicts:** Opening a second window or attempting to sign in with a different account instantly logs out your primary session or causes token conflicts.
2. **Quota Exhaustion:** Heavy AI coding burns through daily model quotas quickly. Switching between accounts manually requires constant logging in, browser 2FA, and re-authenticating.
3. **Workspace Inflexibility:** You cannot easily isolate work projects, personal accounts, and client workspaces.

**Multiagy** solves this by containerizing each instance into its own isolated profile sandbox (`~/AntigravityProfiles/<name>`), allowing you to launch and run as many Antigravity profiles as you want simultaneously.

---

## 🛡️ The Secret Sauce: The Linux Keyring Fix

If you have tried other tools like `multigravity-cli` or `multigravity-pro` on Linux, you likely encountered two critical issues:
1. **The Shared Keyring Leak:** Upstream tools only redirected standard directory paths (`HOME`, `XDG_CONFIG_HOME`). However, Antigravity's Go runtime retrieves OAuth tokens via the desktop **D-Bus Secret Service (GNOME Keyring)** under `service: 'gemini', username: 'antigravity'`. As a result, opening a new profile always pulled your host account's credentials, defeating profile isolation.
2. **The "Awaiting Authentication" Freeze:** Naively isolating the D-Bus bus severed communication with your running desktop browser (`xdg-open` / `gio`), leaving Antigravity perpetually stuck on *"Awaiting authentication"*.

### How Multiagy Solves This:
* **Private Keyring Sandboxing:** On Linux, Multiagy executes each profile inside an isolated D-Bus session with a private `gnome-keyring-daemon` tied strictly to that profile's folder (`$profile/.local/share/keyrings`).
* **Desktop Browser Bridge:** It transparently bridges authentication requests to your running desktop browser (Google Chrome / default browser) so the Google OAuth sign-in tab opens instantly and redirects tokens directly into the private profile keyring.

---

## ⚡ Installation

### Linux & macOS

Run this one-line command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/ashaskhan/multiagy/main/install.sh | bash
```

Verify your installation:

```bash
multiagy doctor
```

```text
Checking multiagy environment...
  [✓] Platform: linux
  [✓] Antigravity: Found at /home/.../.local/bin/antigravity
  [✓] Global Binary: /home/.../.local/bin/multiagy
  [✓] Profile storage: /home/.../AntigravityProfiles (writable)

✓ Your environment looks perfect!
```

---

## 🚀 Quick Start

### 1. Create a Profile
Create a profile for each account you want to use:

```bash
# Recommended: Auth-only mode (shares extensions and themes, isolates login)
multiagy new personal --auth-only
multiagy new work --auth-only
multiagy new backup --auth-only
```

Each profile automatically generates a clickable desktop shortcut:
* **Linux:** `~/.local/share/applications/multiagy-<name>.desktop` (visible in your desktop application menu)
* **macOS:** `~/Applications/Multiagy <name>.app`

### 2. Sign In (One-Time Setup)
Launch the profile from your terminal:

```bash
multiagy work
```

1. Click **Sign In** inside the Antigravity window.
2. Your browser will automatically open the Google OAuth login page.
3. Sign in with the respective Google account.
4. The login token is now permanently saved inside that profile's private keyring!

### 3. Launching with Projects
You can pass directory paths and CLI arguments straight through to Antigravity:

```bash
# Open current directory
multiagy work .

# Open a specific project
multiagy backup ~/Documents/my-project

# Open in a new window
multiagy personal --new-window
```

---

## 💾 Auth-Only Profiles (Save Disk Space)

Standard profile managers duplicate all extensions, themes, and language servers for every profile, quickly consuming tens of gigabytes of disk space.

With the `--auth-only` flag:
* **Shared:** Extensions, themes, keybindings, and editor settings are symlinked from your default Antigravity installation.
* **Isolated:** Cookies, local storage, D-Bus keyrings, and login tokens are kept 100% separate.
* **Benefit:** When you install an extension or change your theme in one window, all profiles get it instantly, and each profile consumes only ~30 MB!

```bash
multiagy new <profile-name> --auth-only
```

---

## 🧠 The Quota Pooling Playbook

Want to turn 5 or 6 separate accounts into **one giant, continuous quota pool**? Here are three proven workflows:

### Strategy 1: The Relay / Quota Failover
When working continuously on a single large project:
1. Start working in your primary window:
   ```bash
   antigravity ~/my-project
   ```
2. When your primary account exhausts its daily or hourly rate limit, simply launch your backup profile on the same directory:
   ```bash
   multiagy a1 ~/my-project
   ```
3. Prompt the agent:
   > *"Inspect git diff and the latest commit to see what was just finished, and continue with the next task."*
4. Because the files and git repository live on disk, the new profile picks up right where you left off with 100% fresh quota!

---

### Strategy 2: The Git Worktree Swarm
If you want multiple accounts coding on the same project **at the exact same time** without file collisions, use **Git Worktrees**:

1. In your project directory, create dedicated worktree branches:
   ```bash
   cd ~/my-project
   git worktree add ../project-fe -b task/frontend
   git worktree add ../project-be -b task/backend
   ```
2. Launch different profiles into each branch:
   * **Window 1 (Account 1):**
     ```bash
     multiagy a1 ../project-fe
     ```
     *Prompt:* "Build the React dashboard and form components."
   * **Window 2 (Account 2):**
     ```bash
     multiagy a2 ../project-be
     ```
     *Prompt:* "Build the backend API endpoints and schema models."
3. Both agents commit to the same repository. When finished, merge both branches into `main`!

---

### Strategy 3: Specialized Agent Swarms
Divide accounts by token weight and task complexity:

| Profile | Assigned Role | Typical Prompts |
| :--- | :--- | :--- |
| **`lead`** | **Architect / Planner** | *"Read the codebase, design the architecture, and write tasks into `TASKS.md`."* |
| **`coder`** | **Heavy Implementer** | *"Read `TASKS.md` tasks 1-3 and write the implementation code."* |
| **`qa`** | **Testing & Debugging** | *"Inspect the newly created files, write unit tests, and run them until they pass."* |

---

## 📋 Command Reference

| Command | Description |
| :--- | :--- |
| `multiagy new <name>` | Create a new full profile |
| `multiagy new <name> --auth-only` | Create a profile sharing extensions/settings but isolating auth |
| `multiagy <name> [args...]` | Launch Antigravity with the given profile (passes arguments through) |
| `multiagy list` | List all existing profiles |
| `multiagy status` | Show active running profiles, types, last used dates, and disk usage |
| `multiagy stats` | Display detailed disk storage usage per profile |
| `multiagy rename <old> <new>` | Rename a profile (automatically updates desktop shortcuts) |
| `multiagy clone <src> <dest>` | Clone an existing profile |
| `multiagy delete <name>` | Delete a profile and its isolated credentials |
| `multiagy template save <p> <t>` | Save an existing profile as a reusable template |
| `multiagy template list` | List available saved templates |
| `multiagy template delete <t>` | Delete a template |
| `multiagy export <name> [path]` | Export a profile to a compressed `.tar.gz` archive |
| `multiagy import <tar> [name]` | Import a profile from a `.tar.gz` archive |
| `multiagy doctor` | Run environment diagnosis and path verification |
| `multiagy completion` | Output shell completion instructions (supports bash & zsh) |
| `multiagy update` | Update `multiagy` to the latest release |

---

## 🧹 Storage & Cache Cleanup

During Google OAuth sign-in, the browser may cache temporary web pages, icons, and shader assets inside the profile directory. Once you are authenticated, you can safely wipe the temporary browser cache without losing your login:

```bash
for p in ~/AntigravityProfiles/*; do
  rm -rf "$p/.cache/google-chrome" "$p/.config/google-chrome"
done
```

Your persistent login tokens are safely stored inside `$p/.local/share/keyrings/login.keyring` and will not be affected.

---

## 🩺 Troubleshooting & Diagnostics

#### 1. Checking which profiles are running:
```bash
multiagy status
```

#### 2. Overriding default storage locations:
You can customize the base directory or the binary location using environment variables:
```bash
export MULTIAGY_HOME="$HOME/MyProfiles"
export MULTIAGY_APP="/path/to/antigravity"
```

#### 3. Autocompletion setup:
For Bash:
```bash
echo 'source <(multiagy completion bash)' >> ~/.bashrc
```
For Zsh:
```bash
echo 'source <(multiagy completion zsh)' >> ~/.zshrc
```

---

## 📜 Credits & Attribution

Multiagy builds upon foundational work from the open-source community:
* Forked and enhanced from [Pulkit7070/multigravity-pro](https://github.com/Pulkit7070/multigravity-pro)
* Originally inspired by [sujitagarwal/multigravity-cli](https://github.com/sujitagarwal/multigravity-cli)
* **Multiagy improvements:** Developed by [ashaskhan](https://github.com/ashaskhan) to fix Linux D-Bus/GNOME Keyring isolation, browser OAuth redirection, and multi-agent quota pooling.

Distributed under the [MIT License](LICENSE).
