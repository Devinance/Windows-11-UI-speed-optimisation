# Windows 11 UI Optimizer v2.0 - Enhanced Edition

## Overview

This enhanced PowerShell script optimizes Windows 11 UI responsiveness by applying performance-focused registry tweaks and power plan adjustments. The script includes comprehensive backup/restore functionality, extensive logging, and advanced error handling.

## Key Enhancements in v2.0

### 1. **Advanced Backup System**
- **Versioned Backups**: Each backup is timestamped for easy identification
- **Automatic Cleanup**: Maintains only the specified number of recent backups (default: 10)
- **Backup Verification**: Validates backup integrity before use
- **Enhanced Metadata**: Includes computer name, username, and item count
- **UTF-8 Encoding**: Proper character encoding for international support

### 2. **Enhanced Restore Functionality**
- **Backup Preview**: View detailed backup information before restoring
- **Validation**: Checks backup integrity before restoration
- **User Confirmation**: Requires explicit confirmation before applying changes
- **Detailed Status**: Shows success/failure count for each operation
- **Error Recovery**: Continues restoration even if some items fail

### 3. **Improved Code Quality**
- **Parameter Validation**: All functions use proper parameter validation
- **Error Handling**: Comprehensive try-catch blocks with detailed error messages
- **Null Safety**: Proper handling of null values throughout
- **Type Safety**: Explicit type conversions with error checking
- **Input Validation**: User inputs are validated before processing

### 4. **Advanced Logging & Debugging**
- **File Logging**: All operations logged to timestamped log files
- **Verbose Mode**: Enable with `-VerboseMode` parameter for detailed output
- **Debug Messages**: Detailed debugging information for troubleshooting
- **Log Management**: Automatic cleanup of logs older than 30 days
- **Error Context**: Full error details including stack traces

### 5. **Enhanced User Experience**
- **Visual Menu**: Improved menu layout with better formatting
- **Progress Indicators**: Clear indication of operation progress
- **Summary Statistics**: Optimization level percentage and item counts
- **Backup Management**: View and manage all backups from the UI
- **Log Viewer**: Quick access to current session logs

## Usage

### Basic Usage
```powershell
# Run with default settings
.\optimization.ps1
```

### Advanced Usage
```powershell
# Run with verbose logging
.\optimization.ps1 -VerboseMode

# Specify maximum number of backups to retain
.\optimization.ps1 -MaxBackups 20

# Combine parameters
.\optimization.ps1 -VerboseMode -MaxBackups 15
```

### Menu Options

1. **Apply optimization tweaks**
   - Creates automatic backup
   - Applies all registry optimizations
   - Configures high-performance power plan
   - Provides detailed summary

2. **Restore previous settings**
   - Lists all available backups with details
   - Validates backup before restoration
   - Requires user confirmation
   - Shows restoration summary

3. **View current optimization status**
   - Displays all tweaks and their current values
   - Shows optimization percentage
   - Displays active power plan
   - Color-coded status indicators

4. **Manage backups**
   - View all backups with metadata
   - See backup age and validity
   - Display total backup size
   - Quick backup overview

5. **View logs**
   - Access current session log
   - Option to open log in default viewer

## Optimizations Applied

### Registry Tweaks (15 total)

1. **Reduce menu show delay** - Faster context menus
2. **Disable minimize/restore animations** - Instant window operations
3. **Disable transparency effects** - Reduced GPU usage
4. **Disable taskbar animations** - Faster taskbar response
5. **Disable list view fade selection** - Cleaner file selection
6. **Disable list view shadows** - Reduced rendering overhead
7. **Open File Explorer to This PC** - Faster Explorer startup
8. **Disable Start menu recent items** - Privacy and performance
9. **Adjust visual effects for best performance** - System-wide optimization
10. **Disable Aero Peek preview** - Reduced desktop manager overhead
11. **Disable background apps globally** - Lower resource usage
12. **Disable search background execution** - Reduced CPU usage
13. **Disable Start menu content suggestions** - Cleaner Start menu
14. **Disable Start menu suggestions** - Faster Start menu
15. **Eliminate startup application delay** - Faster boot times

### Power Plan Optimization

Sets the active power plan to either:
- Ultimate Performance (if available)
- High Performance (standard alternative)

## File Locations

### Backups
```
%LOCALAPPDATA%\Win11-UI-Optimizer\Backups\
```

Each backup contains:
- `backup.json` - Metadata and registry snapshots
- `*.reg` - Exported registry keys for manual restoration

### Logs
```
%LOCALAPPDATA%\Win11-UI-Optimizer\Logs\
```

Log files are named: `optimizer_YYYYMMDD_HHMMSS.log`

## Safety Features

1. **Mandatory Backups**: Cannot apply optimizations without creating a backup first
2. **Administrator Check**: Validates elevated privileges before executing
3. **Windows 11 Detection**: Warns if running on unsupported OS versions
4. **Backup Integrity Checks**: Validates backups before restoration
5. **Detailed Logging**: Complete audit trail of all operations
6. **Error Recovery**: Graceful handling of failures
7. **Automatic Cleanup**: Prevents disk space issues with old backups

## Troubleshooting

### Common Issues

**Issue**: "This script must be run from an elevated PowerShell session"
- **Solution**: Right-click PowerShell and select "Run as Administrator"

**Issue**: "Execution policy prevents script from running"
- **Solution**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

**Issue**: Backup verification fails
- **Solution**: Check available disk space and file system permissions

**Issue**: Some tweaks fail to apply
- **Solution**: 
  - Check the log file for specific errors
  - Run with `-VerboseMode` for detailed diagnostics
  - Ensure no conflicting group policies

### Debug Mode

Enable verbose mode for detailed diagnostics:
```powershell
.\optimization.ps1 -VerboseMode
```

This provides:
- Registry operation details
- Power scheme enumeration results
- Backup/restore operation steps
- All error contexts and stack traces

## Best Practices

1. **Review Changes**: Check optimization status before and after applying tweaks
2. **Keep Backups**: Don't delete backups unless you're certain changes are permanent
3. **Test First**: Apply on a test system before production machines
4. **Document Custom Changes**: Note any manual modifications you make
5. **Regular Backups**: Create backups before major Windows updates
6. **Monitor Performance**: Track system performance after optimization
7. **Restart Required**: Restart Windows after applying/restoring for full effect

## Technical Details

### Code Improvements

1. **Parameter Validation**
   ```powershell
   [ValidateNotNullOrEmpty()]
   [ValidateRange(1, 100)]
   ```

2. **Error Handling**
   - All registry operations wrapped in try-catch
   - Specific error messages for different failure types
   - Graceful degradation when operations fail

3. **Type Safety**
   - Explicit type conversions for registry values
   - Null checks before operations
   - Default values for missing data

4. **Logging Architecture**
   - Multi-level logging (INFO, SUCCESS, WARNING, ERROR, DEBUG)
   - File and console output
   - Timestamp on all entries
   - Automatic log rotation

### Bug Fixes

1. **Fixed**: ASCII encoding issue in backup.json (now UTF-8)
2. **Fixed**: Missing null checks in value conversions
3. **Fixed**: Improper error handling in power plan operations
4. **Fixed**: Race conditions in backup verification
5. **Fixed**: Input validation gaps in user selections
6. **Fixed**: Missing error context in exception messages

## System Requirements

- Windows 11 Build 22000 or later (recommended)
- Windows 10 (may work with warnings)
- PowerShell 5.1 or later
- Administrator privileges
- Minimum 10 MB free disk space for backups

## Version History

### v2.0.0 (2025-11-03)
- ✅ Added comprehensive logging system
- ✅ Implemented automatic backup cleanup
- ✅ Enhanced error handling and validation
- ✅ Added backup integrity verification
- ✅ Improved user interface with better formatting
- ✅ Added verbose mode for debugging
- ✅ Enhanced restore functionality with preview
- ✅ Added backup management interface
- ✅ Fixed UTF-8 encoding issues
- ✅ Added parameter support for configuration
- ✅ Improved code documentation
- ✅ Added safety features and confirmations

### v1.0.0 (Original)
- Basic optimization functionality
- Simple backup/restore
- Registry tweaks and power plan

## License & Disclaimer

This script modifies Windows registry settings and system configuration. Use at your own risk. Always create backups before applying system modifications.

## Support & Feedback

For issues or suggestions:
1. Check the log files in `%LOCALAPPDATA%\Win11-UI-Optimizer\Logs\`
2. Run with `-VerboseMode` for detailed diagnostics
3. Review this documentation for common solutions

---

**Last Updated**: November 3, 2025  
**Version**: 2.0.0  
**Author**: Senior Software Engineer
