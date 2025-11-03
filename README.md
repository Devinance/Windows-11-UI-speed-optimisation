# Windows 11 UI Speed Optimizer

> Lightweight PowerShell tool to improve Windows 11 UI responsiveness — safe backups, restore workflow, and helpful logs.

[![Platform](https://img.shields.io/badge/platform-Windows%2011-blue.svg)](https://www.microsoft.com)
[![PowerShell](https://img.shields.io/badge/powershell-5.1%2B-blue.svg)](https://docs.microsoft.com/powershell)

---

## Table of contents

- [Quick start](#quick-start)
- [Features](#features)
- [Requirements](#requirements)
- [Usage examples](#usage-examples)
- [Where backups & logs live](#where-backups--logs-live)
- [What changes are applied](#what-changes-are-applied)
- [Troubleshooting](#troubleshooting)
- [Contributing & license](#contributing--license)
- [Links](#links)

---

## Quick start

1. Open an elevated PowerShell (Run as Administrator).
2. Change to the repository folder (or provide a full path) and run the script.

```powershell
# From an elevated PowerShell
Set-Location -Path 'C:\path\to\Windows-11-UI-speed-optimisation'
pwsh.exe -ExecutionPolicy Bypass -File .\optimization.ps1
```

Tip: pass `-VerboseMode` to see extra debug output. Use `-MaxBackups <n>` to change how many backups are retained (default: 10).

## Features

- Interactive menu: apply tweaks, restore, view status, manage backups, view logs
- Automatic timestamped backups (JSON metadata + exported .reg files)
- Backup integrity verification
- Session logging (local %LOCALAPPDATA% path)
- Attempts to set a high-performance power plan when optimizing

## Requirements

- Windows 11 (build 22000+) — the script checks the OS and warns if not running on Win11
- PowerShell 5.1 or newer
- Must run with Administrator privileges (the script will exit if not elevated)

## Usage examples

Run with verbose logging and keep up to 20 backups:

```powershell
pwsh.exe -ExecutionPolicy Bypass -File .\optimization.ps1 -VerboseMode -MaxBackups 20
```

Run non-interactively (not recommended) — the script is designed to be interactive. It's safest to use the menu.

Menu options you'll see:

- Apply optimization tweaks (creates a backup first)
- Restore previous settings from a timestamped backup
- View current optimization status (shows which settings already match target)
- Manage backups (list, inspect, prune)
- View logs (opens the current session log when available)

## Where backups & logs live

- Backups: `%LOCALAPPDATA%\\Win11-UI-Optimizer\\Backups`
	- Each backup folder: `backup_YYYYMMDD_HHMMSS`
	- Contains `backup.json` (metadata) and exported `.reg` files for registry keys
- Logs: `%LOCALAPPDATA%\\Win11-UI-Optimizer\\Logs`
	- Named like `optimizer_YYYYMMDD_HHMMSS.log`

## What changes are applied (high level)

The script applies a curated set of registry tweaks intended to make the UI feel snappier:

- Reduce `MenuShowDelay` for faster menu opening
- Disable minimize/restore and taskbar animations
- Disable transparency effects
- Turn off various Start/menu suggestions and background app behaviors
- Reduce startup delay (where supported)
- Set Visual Effects to prioritize performance

All modified values are recorded in the backup metadata so they can be restored.

## Troubleshooting

- Not elevated / permission errors: re-launch PowerShell as Administrator.
- Backups fail or are invalid: check the session log under `%LOCALAPPDATA%\\Win11-UI-Optimizer\\Logs`.
- Power plan restore fails: some power schemes are not available on every OS SKU — the script will warn if it can't restore the exact plan.

## Contributing & license

Contributions welcome. For adding new tweaks, follow the existing `PSCustomObject` entries in `optimization.ps1` and include:

- `FriendlyName`, `Hive` (HKCU/HKLM), `Path`, `Name`, `DesiredValue`, `Type`

This repository currently has no license file. If you plan to publish it on GitHub, consider adding a `LICENSE` (MIT is a common choice).

## Links

- `optimization.ps1` — main script
- `CHANGELOG.md` — changes and release notes
- `OPTIMIZATION_GUIDE.md` — deeper explanation of tweaks and rationale
- `QUICK_REFERENCE.md` — short usage notes

---

If you want, I can also:

- Add a `CONTRIBUTING.md` and a minimal `LICENSE` (MIT) file
- Add a GitHub Actions workflow that runs `Invoke-ScriptAnalyzer` as a lint step
- Add a short GIF/screenshot for the README header


