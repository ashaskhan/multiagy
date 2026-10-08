# 🌌 Multiagy

> **The lightweight, production-grade profile and session manager for the Google Antigravity IDE.**  
> Seamlessly run multiple independent Antigravity profiles with true Linux credential sandboxing, shared extensions, and parallel Git worktree support.

[![CI](https://github.com/ashaskhan/multiagy/actions/workflows/ci.yml/badge.svg)](https://github.com/ashaskhan/multiagy/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/ashaskhan/multiagy?color=blue)](https://github.com/ashaskhan/multiagy/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Linux | macOS](https://img.shields.io/badge/Platform-Linux%20(Supported)%20%7C%20macOS%20(Experimental)-blue.svg)](#-platform-support)
[![GitHub Stars](https://img.shields.io/github/stars/ashaskhan/multiagy?style=social)](https://github.com/ashaskhan/multiagy/stargazers)

---

```
  __  __       _ _   _                 
 |  \/  |_   _| | |_(_) __ _  __ _ _   _ 
 | |\/| | | | | | __| |/ _` |/ _` | | | |
 | |  | | |_| | | |_| | (_| | (_| | |_| |
 |_|  |_|\__,_|_|\__|_|\__,_|\__, |\__, |
                             |___/ |___/ 
 Multi-Profile & Session Manager for Antigravity IDE
```

---

## 📖 Table of Contents
- [Why Multiagy?](#-why-multiagy)
- [Feature Comparison](#-feature-comparison)
- [The Secret Sauce: Linux Credential Isolation](#-the-secret-sauce-linux-credential-isolation)
- [Platform Support](#-platform-support)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Profile Modes: Auth-Only vs Full](#-profile-modes-auth-only-vs-full)
- [Advanced Workflows: Parallel Git Worktrees](#-advanced-workflows-parallel-git-worktrees)
- [Command Reference](#-command-reference)
- [Security & Safe Operations](#-security--safe-operations)
- [Frequently Asked Questions (FAQ)](#-frequently-asked-questions-faq)
- [Troubleshooting & Diagnostics](#-troubleshooting--diagnostics)
- [Contributing](#-contributing)
- [Credits & Attribution](#-credits--attribution)

---

## ❓ Why Multiagy?

By default, the **Antigravity IDE** locks your entire environment into a single global desktop session:
* **Account Switching Hassle:** Opening a second window or attempting to sign in with a different Google account forcibly logs out your primary session or triggers session desyncs.
* **Workspace Entanglement:** Personal experiments, enterprise repositories, and client codebases are forced into one global history and storage pool.
* **Linux Authentication Failures:** Due to shared desktop keyrings, standard workarounds on Linux leak credentials across profiles or leave windows frozen on *"Awaiting authentication"*.

**Multiagy** containerizes each Antigravity instance into an isolated profile sandbox (`~/AntigravityProfiles/<name>`), providing independent session states, separate workspace configurations, and dedicated credential keyrings.

---

## 📊 Feature Comparison

| Feature | Default Antigravity | Generic Shell Scripts | **Multiagy** |
| :--- | :---: | :---: | :---: |
| Multiple Concurrent Windows | ⚠️ Shared Account | ⚠️ Partial | ✅ **Independent** |
| Multi-Account Profiles | ❌ Forces Logout | ⚠️ Leaks on Linux | ✅ **Fully Isolated** |
| **Linux GNOME Keyring Isolation** | ❌ Shared | ❌ Leaked to Host | ✅ **Isolated D-Bus Keyring** |
| **Browser OAuth Redirection** | ✅ Default | ❌ Often Freezes | ✅ **Automatic Chrome/Default Bridge** |
| Extension & Theme Sharing | N/A | ❌ Duplicates GBs | ✅ **`--auth-only` (Zero Bloat)** |
| Desktop App Menu Shortcuts | ✅ Default | ⚠️ Manual | ✅ **Automated `.desktop` / `.app`** |
| Running Process Guard | N/A | ❌ Corrupts Files | ✅ **Prevents Deletion of Active Profiles** |
| Archive Import Protection | N/A | ❌ Zip Slip Vulnerable | ✅ **Path Traversal Defended** |

---

## 🛡️ The Secret Sauce: Linux Credential Isolation

On Linux desktop environments (GNOME, Wayland, X11), standard profile scripts fail because Antigravity's Go runtime retrieves OAuth tokens via the desktop **D-Bus Secret Service (GNOME Keyring)** under `service: 'gemini', username: 'antigravity'`.

Simply changing `$HOME` or `--user-data-dir` leaves the desktop D-Bus bus connected, causing any new profile to automatically read the host account's credentials. Furthermore, naively isolating D-Bus severs communication with your running desktop browser (`xdg-open` / `gio`), leaving the IDE permanently frozen on *"Awaiting authentication"*.

### Multiagy's Dual-Layer Architecture:
1. **Isolated Keyring Daemons:** Each Linux profile executes in its own private D-Bus session backed by an autonomous `gnome-keyring-daemon` tied strictly to that profile's folder (`$profile/.local/share/keyrings`).
2. **Desktop Browser Bridge:** OAuth sign-in URLs are bridged back to your desktop browser session (Google Chrome or default browser), allowing instant sign-in while routing tokens securely into the profile's private keyring.

---

## 💻 Platform Support

| Operating System | Profile Isolation | Credential Sandboxing | Status |
| :--- | :---: | :---: | :--- |
| **Linux** (Ubuntu, Debian, Fedora, Arch) | ✅ Full | ✅ Full (Private D-Bus Keyring) | **Supported** |
| **macOS** (Apple Silicon & Intel) | ✅ Full | ⚠️ Shared (Host Keychain) | **Experimental** |

> **Note on macOS:** On macOS, Multiagy cleanly isolates extensions, editor configurations, window states, and workspace layouts. However, because macOS uses a unified system Keychain, credential sandboxing between profiles is experimental.

---

## ⚡ Installation

Install Multiagy with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/ashaskhan/multiagy/main/install.sh | bash
```

Verify your environment:

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
multiagy new client-project --auth-only
```

Each profile automatically creates a desktop launcher:
* **Linux:** `~/.local/share/applications/multiagy-<name>.desktop` (searchable in your application launcher)
* **macOS:** `~/Applications/Multiagy <name>.app`

### 2. Sign In (One-Time Setup)
Launch the profile from your terminal:

```bash
multiagy work
```

1. Click **Sign In** inside the Antigravity window.
2. Google Chrome (or your default browser) will open the Google OAuth login page.
3. Sign in with the respective Google account.
4. Your credentials are now saved in that profile's private keyring.

### 3. Open Specific Workspaces
Pass directory paths and CLI arguments straight through to Antigravity:

```bash
# Open current directory
multiagy work .

# Open a specific project
multiagy client-project ~/Documents/client-code

# Open in a new window
multiagy personal --new-window
```

---

## 💾 Profile Modes: Auth-Only vs Full

* **`--auth-only` (Recommended):**  
  Symlinks your installed extensions, keybindings, and editor settings from your primary Antigravity installation while keeping cookies, local storage, and authentication keyrings completely isolated. Each profile consumes only ~30 MB on disk!
  ```bash
  multiagy new <name> --auth-only
  ```

* **Full Profile (Clean Slate):**  
  Creates an entirely isolated environment with its own separate extensions directory, configuration, and settings. Ideal for testing experimental plugins or maintaining strict client compliance.
  ```bash
  multiagy new <name>
  ```

---

## 🌿 Advanced Workflows: Parallel Git Worktrees

To run multiple Antigravity agent instances on different features of the same project simultaneously without file collision:

1. **Create Git worktrees in your repository:**
   ```bash
   cd ~/my-project
   git worktree add ../my-project-frontend -b feature/frontend
   git worktree add ../my-project-backend -b feature/backend
   ```

2. **Launch separate profiles for each worktree:**
   * **Window 1 (Frontend Agent):**
     ```bash
     multiagy work ../my-project-frontend
     ```
   * **Window 2 (Backend Agent):**
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
| `multiagy clone <src> <dest> [--fresh-auth]` | Clone an existing profile (use `--fresh-auth` to exclude login credentials) |
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

* **Active Process Guards:** `multiagy delete`, `rename`, and `export` automatically verify whether a profile is actively running before performing actions to avoid data corruption.
* **Sanitized Templates:** `multiagy template save` automatically purges authentication keyrings, session tokens, and browser caches, ensuring templates are clean, reusable baselines.
* **Sanitized Clones:** Running `multiagy clone <src> <dest> --fresh-auth` duplicates extensions, preferences, and workspaces while stripping login credentials.
* **Archive Path Validation:** `multiagy import` validates archive entries prior to extraction, preventing directory traversal (`../`) attacks.

---

## ❓ Frequently Asked Questions (FAQ)

### How do I fix Antigravity stuck on "Awaiting authentication" on Linux?
This occurs when D-Bus isolation severs the desktop browser link. Multiagy fixes this automatically using its desktop browser bridge. Run `multiagy doctor` to ensure `dbus-run-session` and `gnome-keyring-daemon` are installed on your Linux system.

### Will installing extensions in one profile duplicate them across all profiles?
If you created the profile with `--auth-only`, extensions and settings are shared via symlinks. Installing an extension in one profile makes it instantly available across all `--auth-only` profiles with zero extra disk usage.

### How do I free up disk space after logging in?
During OAuth, Chrome may cache web assets. Once authenticated, you can safely wipe temporary browser cache without losing your login:
```bash
for p in ~/AntigravityProfiles/*; do
  rm -rf "$p/.cache/google-chrome" "$p/.config/google-chrome"
done
```

---

## 🩺 Troubleshooting & Diagnostics

#### 1. Shell Autocompletion Setup
* **Bash:** Add to `~/.bashrc`:
  ```bash
  source <(multiagy completion bash)
  ```
* **Zsh:** Add to `~/.zshrc`:
  ```bash
  source <(multiagy completion zsh)
  ```

#### 2. Customizing Storage Paths
Override default storage directories using environment variables:
```bash
export MULTIAGY_HOME="$HOME/MyProfiles"
export MULTIAGY_APP="/path/to/antigravity"
```

---

## 🤝 Contributing

Contributions are welcome! Please check out [CONTRIBUTING.md](CONTRIBUTING.md) for local testing instructions and code standards.

---

## 📜 Credits & Attribution

Multiagy builds upon foundational work from the open-source community:
* Forked and enhanced from [Pulkit7070/multigravity-pro](https://github.com/Pulkit7070/multigravity-pro)
* Originally inspired by [sujitagarwal/multigravity-cli](https://github.com/sujitagarwal/multigravity-cli)
* **Multiagy enhancements:** Linux D-Bus/GNOME Keyring sandboxing, desktop OAuth browser bridging, archive import security, process safety checks, and template sanitization developed by [ashaskhan](https://github.com/ashaskhan).

Distributed under the [MIT License](LICENSE).
