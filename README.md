# Windows 11 UI Speed Optimizer

A small, focused PowerShell script to improve Windows 11 UI responsiveness by applying a set of registry and power-plan changes. The script creates safe, timestamped backups before making changes and includes a restore workflow and logs.

## At a glance

- Script: `optimization.ps1` (requires Administrator/elevated PowerShell)
- Purpose: Reduce UI animation delays, disable non-essential effects, and set a performance-oriented power plan
- Backup: Automatic timestamped backups (JSON metadata + exported `.reg` files)
- Logs: Session logs saved under `%LOCALAPPDATA%\Win11-UI-Optimizer\Logs`

## Requirements

- Windows 11 (build 22000 or later) — script performs a compatibility check and will warn if not running on Win11.
- PowerShell 5.1+ (the script uses the `#requires -Version 5.1` directive)
- Must run as Administrator (elevation required) — the script enforces this and will exit if not elevated.

## Files of interest

- `optimization.ps1` — main interactive script (apply, restore, status, backup management)
- `CHANGELOG.md`, `OPTIMIZATION_GUIDE.md`, `QUICK_REFERENCE.md` — repository documentation

## Important safety notes

- The script creates a backup of any registry values it will modify before applying tweaks. Backups are saved to `%LOCALAPPDATA%\Win11-UI-Optimizer\Backups` in timestamped folders (e.g. `backup_20251103_153045`).
- A system restart is recommended after applying or restoring settings for all changes to take full effect.
- While some changes may work on Windows 10, the script is designed for Windows 11 and may not be fully compatible on earlier OS versions.

## Usage

Open an elevated PowerShell (Run as Administrator) and run either from the current directory or by providing a full path to the script.

Example (current directory):

```powershell
# From PowerShell (Windows PowerShell / pwsh)
Set-Location -Path 'C:\path\to\Windows-11-UI-speed-optimisation'
pwsh.exe -ExecutionPolicy Bypass -File .\optimization.ps1
```

You can pass the script parameters directly:

```powershell
# Enable verbose mode and set max backups to retain
pwsh.exe -ExecutionPolicy Bypass -File .\optimization.ps1 -VerboseMode -MaxBackups 20
```

Notes on parameters found in the script:

- `-VerboseMode` (switch): Enable more detailed logging output to console and log file.
- `-MaxBackups <int>`: Maximum number of backups to retain (default: 10). Range validated between 1 and 100.

The script will present an interactive menu with options to:
- Apply optimization tweaks (creates backup first)
- Restore previous settings (choose from backups)
- View current optimization status
- Manage backups
- View logs

## Where backups and logs are stored

- Backups: `%LOCALAPPDATA%\Win11-UI-Optimizer\Backups` (each backup folder contains `backup.json` and exported `.reg` files)
- Logs: `%LOCALAPPDATA%\Win11-UI-Optimizer\Logs` (session logs named like `optimizer_YYYYMMDD_HHMMSS.log`)

## What the script changes (high-level)

The script contains a curated list of registry tweaks such as:
- Reducing `MenuShowDelay` for faster menus
- Disabling window and taskbar animations
- Disabling transparency effects
- Reducing startup delays
- Setting visual effects to favor performance

All modifications are recorded in the backup metadata and can be restored by the included restore workflow.

## Troubleshooting

- "Not elevated" / permission errors: Re-run PowerShell as Administrator.
- If a backup fails or is invalid, check the log file under `%LOCALAPPDATA%\Win11-UI-Optimizer\Logs` for details.
- If power plan restore fails, confirm the target power plan still exists on the system (some plans may not be present on all SKUs).

## Contributing

Small fixes, documentation improvements, or additional safe tweaks are welcome. Consider opening an issue or a pull request. If you add new registry tweaks, include:
- FriendlyName
- Hive (HKCU/HKLM)
- Path and Name
- DesiredValue and Type

## License & attribution

This repository does not include an explicit license file. If you intend to publish this on GitHub, add a `LICENSE` file (for example MIT) to clarify reuse terms.

## Links

- CHANGELOG: `CHANGELOG.md`
- Optimization Guide: `OPTIMIZATION_GUIDE.md`
- Quick Reference: `QUICK_REFERENCE.md`

---

If you'd like, I can also:
- Add a separate `CONTRIBUTING.md` with a brief developer guide
- Add example screenshots or a short GIF showing the menu
- Add a `LICENSE` file (suggest MIT) and populate repository metadata for GitHub releases

