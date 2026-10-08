# 🌌 Multiagy

> **A multi-profile session and account manager for the Antigravity IDE.**  
> Organize independent workspaces, separate personal and work environments, and run parallel Git worktrees with true credential isolation on Linux.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Linux (Supported) | macOS (Experimental)](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)](#platform-support)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](#install)

---

## 📖 Table of Contents
- [Why Multiagy?](#-why-multiagy)
- [The Linux Credential Isolation Architecture](#-the-linux-credential-isolation-architecture)
- [Platform Support](#-platform-support)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Profile Modes: Auth-Only vs Full](#-profile-modes-auth-only-vs-full)
- [Advanced Workflows: Parallel Git Worktrees](#-advanced-workflows-parallel-git-worktrees)
- [Command Reference](#-command-reference)
- [Security & Safe Operations](#-security--safe-operations)
- [Troubleshooting & Diagnostics](#-troubleshooting--diagnostics)
- [Credits & Attribution](#-credits--attribution)

---

## ❓ Why Multiagy?

By default, the **Antigravity IDE** operates around a single global desktop session:
* **Account Switching Overhead:** Opening a second window or attempting to sign in with a different Google account either forces a global logout or causes authentication conflicts.
* **Workspace Entanglement:** Personal projects, client engagements, and enterprise repositories often share the same global storage, history, and active sessions.
* **Lack of Parallel Isolation:** Running distinct agent workflows across different branches of a repository in parallel can result in conflicting file edits and session collisions.

**Multiagy** introduces containerized profile management for Antigravity (`~/AntigravityProfiles/<name>`), providing isolated settings, separate workspace states, and independent credential sandboxes.

---

## 🛡️ The Linux Credential Isolation Architecture

On Linux desktop environments, standard profile isolation scripts often fail due to two architectural hurdles:

1. **The Shared Keyring Leak:** In Linux, Antigravity’s Go runtime accesses OAuth tokens through the desktop **D-Bus Secret Service (GNOME Keyring)** under `service: 'gemini', username: 'antigravity'`. Simply redirecting directory paths (`HOME`, `XDG_CONFIG_HOME`) leaves the D-Bus session shared, causing any new profile to automatically inherit the host's authentication token.
2. **The OAuth Redirection Trap:** Completely isolating the D-Bus bus severs communication with your running desktop browser (`xdg-open` / `gio`), causing the IDE to freeze on *"Awaiting authentication"* because the login page cannot open.

### Multiagy's Solution:
* **Per-Profile Keyring Daemons:** Each Linux profile executes inside an isolated D-Bus session backed by a private `gnome-keyring-daemon` tied strictly to that profile's storage (`$profile/.local/share/keyrings`).
* **Desktop Browser Bridge:** Authentication URLs are transparently forwarded to your running desktop browser (Google Chrome / default browser) through a desktop bridge shim. Tokens are received and saved exclusively within the profile's sandboxed keyring without touching the host session.

---

## 💻 Platform Support

| Operating System | Profile Isolation | Credential Sandboxing | Status |
| :--- | :---: | :---: | :--- |
| **Linux** | ✅ Full | ✅ Full (Private D-Bus Keyring) | **Supported** |
| **macOS** | ✅ Full | ⚠️ Shared (Host Keychain) | **Experimental** |

> **Note on macOS:** On macOS, Multiagy successfully isolates extensions, user settings, window states, and workspace layouts. However, because macOS uses a unified system Keychain, credential sandboxing between profiles is currently experimental.

---

## ⚡ Installation

Run this one-line command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/ashaskhan/multiagy/main/install.sh | bash
```

Verify your setup:

```bash
multiagy doctor
```

```text
Checking multiagy environment...
  [✓] Platform: linux
  [✓] Antigravity: Found at /home/.../.local/bin/antigravity
  [✓] Global Binary: /home/.../.local/bin/multiagy
  [✓] D-Bus session runner: Found (dbus-run-session)
  [✓] Keyring daemon: Found (gnome-keyring-daemon)
  [✓] Desktop URL opener: Found (/usr/bin/xdg-open)
  [✓] Browser: Google Chrome detected
  [✓] Profile storage: /home/.../AntigravityProfiles (writable)

✓ Your environment looks perfect!
```

---

## 🚀 Quick Start

### 1. Create a Profile
Create separate profiles for your different roles or projects:

```bash
# Recommended: Auth-only mode (shares extensions and themes, isolates login)
multiagy new personal --auth-only
multiagy new work --auth-only
multiagy new client-a --auth-only
```

Each profile automatically generates a desktop shortcut:
* **Linux:** `~/.local/share/applications/multiagy-<name>.desktop` (searchable in your application launcher)
* **macOS:** `~/Applications/Multiagy <name>.app`

### 2. Sign In (One-Time Setup)
Launch the profile from your terminal:

```bash
multiagy work
```

1. Click **Sign In** inside the Antigravity window.
2. Your desktop browser will open the Google OAuth login page.
3. Sign in with that profile's Google account.
4. The login token is saved permanently inside that profile's private keyring.

### 3. Open Specific Workspaces
Pass directory paths and CLI arguments straight through to Antigravity:

```bash
# Open current directory
multiagy work .

# Open a specific project
multiagy client-a ~/Documents/client-project

# Open in a new window
multiagy personal --new-window
```

---

## 💾 Profile Modes: Auth-Only vs Full

* **`--auth-only` (Recommended):**  
  Symlinks your extensions, keybindings, and editor settings from your primary Antigravity installation while isolating cookies, local storage, and authentication keyrings. You avoid downloading duplicate language servers and extensions, keeping profile footprints small (~30 MB).
  ```bash
  multiagy new <name> --auth-only
  ```

* **Full Profile (Clean Slate):**  
  Initializes a completely independent environment with its own isolated extensions directory, configuration, and settings. Ideal for testing experimental plugins or keeping strict client compliance.
  ```bash
  multiagy new <name>
  ```

---

## 🌿 Advanced Workflows: Parallel Git Worktrees

To run multiple Antigravity agent instances on the same project simultaneously without file collision:

1. **Create Git worktrees in your repository:**
   ```bash
   cd ~/my-project
   git worktree add ../my-project-frontend -b feature/frontend
   git worktree add ../my-project-backend -b feature/backend
   ```

2. **Launch separate profiles for each worktree:**
   * **Window 1 (Frontend):**
     ```bash
     multiagy work ../my-project-frontend
     ```
   * **Window 2 (Backend):**
     ```bash
     multiagy personal ../my-project-backend
     ```

3. Both windows run concurrently with independent agent states, committing to the same repository. When work is complete, merge both branches into `main`.

---

## 📋 Command Reference

| Command | Description |
| :--- | :--- |
| `multiagy new <name> [options]` | Create a new profile (`--auth-only`, `--from <template>`) |
| `multiagy <name> [args...]` | Launch Antigravity with the given profile (passes arguments through) |
| `multiagy list` | List all existing profiles |
| `multiagy status` | Show active running profiles, types, modification dates, and disk usage |
| `multiagy stats` | Display detailed disk storage usage per profile |
| `multiagy rename <old> <new>` | Rename a profile (safely blocks if the profile is running) |
| `multiagy clone <src> <dest> [--fresh-auth]` | Clone an existing profile (use `--fresh-auth` to sanitize login credentials) |
| `multiagy delete <name>` | Delete a profile and its isolated credentials (blocks if running) |
| `multiagy template save <p> <t>` | Save an existing profile as a sanitized, reusable template |
| `multiagy template list` | List available templates |
| `multiagy template delete <t>` | Delete a template |
| `multiagy export <name> [path]` | Export a profile to a self-contained `.tar.gz` archive |
| `multiagy import <archive> [name]` | Safely import a profile with path traversal / Zip Slip protection |
| `multiagy doctor` | Run environment diagnosis and return standard exit codes |
| `multiagy completion` | Output shell completion instructions (bash & zsh) |
| `multiagy update` | Update `multiagy` to the latest release |

---

## 🔒 Security & Safe Operations

* **Active Process Protection:** `multiagy delete`, `rename`, and `export` automatically verify whether a profile is currently active before performing destructive actions to avoid disk corruption.
* **Sanitized Templates:** `multiagy template save` strips out authentication keyrings, session tokens, and browser caches, ensuring templates are clean starting points.
* **Sanitized Clones:** Running `multiagy clone <src> <dest> --fresh-auth` duplicates extensions, preferences, and workspaces while stripping login credentials.
* **Archive Path Validation:** `multiagy import` validates archive entries prior to extraction, preventing directory traversal (`../`) attacks.

---

## 🩺 Troubleshooting & Diagnostics

#### 1. Verifying Environment Health
Run `multiagy doctor` to verify required tools. On Linux, it verifies:
* `dbus-run-session`
* `gnome-keyring-daemon`
* `xdg-open` / `gio`
* Installed browser binaries

#### 2. Shell Autocompletion
* **Bash:** Add to `~/.bashrc`:
  ```bash
  source <(multiagy completion bash)
  ```
* **Zsh:** Add to `~/.zshrc`:
  ```bash
  source <(multiagy completion zsh)
  ```

#### 3. Customizing Storage Locations
Override default directories using environment variables:
```bash
export MULTIAGY_HOME="$HOME/MyProfiles"
export MULTIAGY_APP="/path/to/antigravity"
```

---

## 📜 Credits & Attribution

Multiagy builds upon foundational work from the open-source community:
* Forked and enhanced from [Pulkit7070/multigravity-pro](https://github.com/Pulkit7070/multigravity-pro)
* Originally inspired by [sujitagarwal/multigravity-cli](https://github.com/sujitagarwal/multigravity-cli)
* **Multiagy enhancements:** Linux D-Bus/GNOME Keyring sandboxing, desktop OAuth browser bridging, archive import security, process safety checks, and template sanitization developed by [ashaskhan](https://github.com/ashaskhan).

Distributed under the [MIT License](LICENSE).
