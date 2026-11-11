# SysUtil — Agent Guide

**Purpose**: Bash utility suite for managing SysPDV PDV (POS) on Ubuntu 18.04/22.04. Used internally by Casa Magalhães.

**Version**: 8.0.0

## Entry Points

- `sysutil` (no extension) — **sole** main menu. Re-runs itself with `sudo` when not root and shows a root notice in the menu.
- `install.sh` || `update.sh` — one-liner install/update via `curl | sudo bash`. Installs to `/opt/sysutil` (all users) and links `/usr/local/bin/sysutil`.
- `functions.sh` — aggregates all `func/` modules via `. func/...` — never run directly.

## Architecture

- **`func/*.sh`** — individual feature modules (sourced, never `chmod +x`'d).
- **`func/utils/utilities.sh`** — shared helpers: `error_msg`, `success_msg`, `confirm_action`, `check_root`, `command_exists`, `die`, `backup_file`, `ensure_directory`, `log_info/log_error`.
- **`func/utils/menu_system.sh`** — pure Bash menu (no `fzf`: it does not run on 18.04). Arrows, `j`/`k`, `1-9`, `q`/ESC = last option (Sair/Voltar).
- **`func/utils/download_manager.sh`** — dependency downloader with SHA256 verification.
- **`config/version.sh`** — single source of truth for version number.
- **`config/downloads.conf`** — URLs/shas for runtime downloads (DocGate, VPN packages).
- **`scripts/create_alias.sh`** — legacy alias/PATH setup (no longer used by the installer).
- **`dep/`** — bundled scripts only (Tec55). Binary packages are downloaded at runtime.

## Platform

- Targets **Ubuntu 18.04** (i386 VPN) and **22.04+** (multi-arch).
- Many operations require **sudo** (`check_root` is available but not always called).
- **Wine** required to run the SysPDV Windows installer (`.exe`).

## Conventions

- All scripts use `. ` (dot) sourcing, not `source`. Header includes version/author/license.
- Use `confirm_action "prompt"` before destructive operations.
- Message helpers: `error_msg`, `success_msg`, `warning_msg`, `info_msg`, `print_msg`.
- Colors: `${RED}`, `${GREEN}`, `${YELLOW}`, `${BLUE}`, `${BOLD}`, `${NC}` from `colors.sh`.
- Every `func/*.sh` guards with `type -t error_msg` and fallback-sources `utilities.sh`.
- `config/version.sh` is the single version source; source it for `$VERSION`.

## Release Process

- **Conventional Commits** — scopes optional, e.g. `feat: add foo`, `fix: bar`.
- Release Please v4 on push to `master`/`dev` — `feat` bumps minor, `fix` bumps patch, rest are skipped.
- Changelog sections are in **Portuguese** (configured in `.release-please-config.json`).
- `install.sh` is uploaded as a release asset.
- PowerShell helper: `scripts/git-commit.ps1` (`git-commit -Type feat -Message "..."`).

## Quirks

- `sysutil.sh` was removed in v8.0. Only `sysutil` exists now.
- `db.sh` was removed in v8.0 (was a placeholder).
- Binary dependencies (VPN `.deb`/`.rpm`, DocGate) are **not** tracked in git.
  Downloaded at runtime via `download_manager.sh`.
- Tests: `bash tests/smoke.sh` (fast, fakes sudo/apt/dpkg) and `bash tests/run_docker.sh` (Ubuntu 18.04 i386 + 22.04 amd64 with PDV paths, plus shellcheck). Manual test machines: `bash tests/docker/maquina.sh criar|entrar|pdv|atualizar|apagar|remover`.
- `chmod 777` on `/opt/Gertec55` and `/opt/ServidorBiometrico` is intentional (owner's decision).
