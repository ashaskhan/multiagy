# Contributing to Multiagy

Thank you for your interest in improving **Multiagy**! We welcome contributions from the community.

---

## 🛠️ Local Development & Testing

### 1. Prerequisites
Make sure you have `shellcheck` installed locally:
* **Ubuntu/Debian:** `sudo apt-get install -y shellcheck`
* **macOS:** `brew install shellcheck`
* **Fedora:** `sudo dnf install -y ShellCheck`

### 2. Syntax & Linter Verification
Before submitting a PR, always ensure your changes pass ShellCheck and bash syntax checks:

```bash
bash -n multiagy install.sh
shellcheck -S warning install.sh
shellcheck -S warning multiagy
```

### 3. Local Verification
Test your modified script locally:

```bash
./multiagy doctor
./multiagy help
./multiagy list
```

---

## 📝 Commit Conventions

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
* `feat:` A new feature or capability
* `fix:` A bug fix or security patch
* `docs:` Documentation improvements
* `ci:` CI workflow updates
* `refactor:` Code restructuring without functional changes

**Format:**
```text
<type>(<optional scope>): <imperative description>

[optional body explaining motivation and design decisions]
```

---

## 🚀 Submitting a Pull Request

1. Fork the repository and create a feature branch (`git checkout -b feat/my-improvement`).
2. Make your changes and commit them cleanly.
3. Push to your fork and submit a Pull Request.
4. Ensure all automated GitHub Actions CI checks pass.
