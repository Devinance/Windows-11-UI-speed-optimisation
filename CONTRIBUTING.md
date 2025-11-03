# Contributing

Thanks for your interest in contributing to Windows 11 UI Speed Optimizer!
This document explains the preferred workflow, code style, and minimal checks we run locally.

## Reporting issues

- Open an issue explaining the behavior, steps to reproduce, expected vs actual results, and your environment (Windows build, PowerShell version).
- Attach logs where relevant: `%LOCALAPPDATA%\Win11-UI-Optimizer\Logs`.

## Making changes (Pull Requests)

1. Fork the repository and create a topic branch for your change.
2. Keep changes focused and add tests or documentation where applicable.
3. Commit messages should be concise and descriptive.
4. Open a PR against `main`, include a short description and list of changes.

## Code style & conventions

- PowerShell functions should use approved verbs (see `Get-Verb`).
- Use `PascalCase` for function names and `camelCase` for local variables when appropriate.
- Keep functions small and focused. Prefer composition over very large functions.
- Use `Write-InfoMessage`, `Write-WarningMessage`, `Write-ErrorMessage`, and `Write-DebugMessage` helpers from the script for consistent logging.

## Adding registry tweaks

When adding a new tweak in `optimization.ps1`, follow the existing pattern:

```powershell
[pscustomobject]@{
    FriendlyName = 'Short description'
    Hive = 'HKCU' # or 'HKLM'
    Path = 'Software\\Example\\Path'
    Name = 'ValueName'
    DesiredValue = 1 # or '20' depending on type
    Type = 'DWord' # DWord, String, QWord, etc.
}
```

- Include a clear `FriendlyName` and verify the `DesiredValue` and `Type` are correct.
- Test changes locally by running the script in an elevated PowerShell.

## Local checks

- Run PSScriptAnalyzer to lint the script:

```powershell
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
Invoke-ScriptAnalyzer -Path .\optimization.ps1
```

- The `PSUseApprovedVerbs` rule is enforced; prefer verbs from `Get-Verb` such as `Get`, `Set`, `Test`, `Remove`, `New`, `Export`, `Import`.

## Testing changes

- There are no automated unit tests in this repository currently. Manual verification steps:
  - Run the script elevated, create a backup, apply a tweak, and verify logs/backups created.
  - Restore from the backup and confirm original settings are restored.

## Pull request checklist

- [ ] Code builds and has no syntax errors
- [ ] PSScriptAnalyzer linting completed (no critical issues)
- [ ] Changes documented (README or OPTIMIZATION_GUIDE as needed)

## License

By contributing you agree that your contributions will be licensed under the project's license (see `LICENSE` file).

Thank you for improving this project!