# Windows 11 UI Optimizer v2.0 - Quick Reference

## 🚀 Quick Start

### Running the Script
```powershell
# Right-click PowerShell → Run as Administrator
.\optimization.ps1

# With detailed logging
.\optimization.ps1 -VerboseMode

# Custom backup limit
.\optimization.ps1 -MaxBackups 20
```

---

## 📋 Menu Options

| Option | Action | Safe? |
|--------|--------|-------|
| **1** | Apply optimization tweaks | ✅ Yes (auto-backup) |
| **2** | Restore previous settings | ✅ Yes (confirmation) |
| **3** | View current status | ✅ Safe (read-only) |
| **4** | Manage backups | ✅ Safe (view only) |
| **5** | View logs | ✅ Safe (read-only) |
| **Q** | Quit | ✅ Safe |

---

## 🎯 Common Tasks

### First Time Setup
1. Run as Administrator
2. Choose option **3** to view current status
3. Choose option **1** to apply optimizations
4. Restart Windows for full effect

### Restore to Default
1. Run as Administrator
2. Choose option **2** (Restore)
3. Select the backup before optimization
4. Confirm restoration
5. Restart Windows

### Check Optimization Status
1. Run as Administrator
2. Choose option **3**
3. Review the status table
4. Check optimization percentage

### Manage Backups
1. Run as Administrator
2. Choose option **4**
3. View all available backups
4. Note backup dates and validity

---

## 📁 File Locations

### Backups
```
%LOCALAPPDATA%\Win11-UI-Optimizer\Backups\backup_YYYYMMDD_HHMMSS\
```

### Logs
```
%LOCALAPPDATA%\Win11-UI-Optimizer\Logs\optimizer_YYYYMMDD_HHMMSS.log
```

### Quick Access
```powershell
# Open backup folder
explorer "%LOCALAPPDATA%\Win11-UI-Optimizer\Backups"

# Open logs folder
explorer "%LOCALAPPDATA%\Win11-UI-Optimizer\Logs"
```

---

## ⚡ What Gets Optimized

### UI Performance (9 tweaks)
- ✅ Faster menu display
- ✅ Disabled animations
- ✅ No transparency effects
- ✅ Instant window operations
- ✅ Optimized visual effects

### System Performance (6 tweaks)
- ✅ Disabled background apps
- ✅ Reduced search overhead
- ✅ Faster startup times
- ✅ Cleaner Start menu
- ✅ High-performance power plan

---

## 🔧 Troubleshooting

### "Script cannot be loaded"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Must run as Administrator"
- Right-click PowerShell
- Select "Run as Administrator"

### "Backup verification failed"
- Check disk space
- Verify file permissions
- Run with `-VerboseMode` for details

### "Some tweaks failed"
- Check log file for details
- May be Group Policy restrictions
- Contact IT administrator

---

## 🛡️ Safety Features

| Feature | Description |
|---------|-------------|
| 🔒 **Auto-Backup** | Always creates backup before changes |
| 🔍 **Verification** | Validates backups before restore |
| ⚠️ **Confirmation** | Asks before making changes |
| 📝 **Logging** | Records all operations |
| 🔄 **Retention** | Keeps last 10 backups (configurable) |
| ✅ **Validation** | Checks all user inputs |
| 🎯 **Rollback** | Easy restoration to any backup |

---

## 📊 Status Indicators

### Optimization Status Colors
- 🟢 **Green** (100%) - Fully optimized
- 🟡 **Yellow** (50-99%) - Partially optimized
- 🔴 **Red** (<50%) - Not optimized

### Backup Status
- ✓ **Valid** - Backup is intact and usable
- ✗ **Invalid** - Backup is corrupted or incomplete

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `1-5` | Select menu option |
| `Q` | Quit/Cancel |
| `Y` | Confirm action |
| `N` | Cancel action |
| `Enter` | Confirm selection |

---

## 📞 Support

### Check Logs First
```powershell
# Run with verbose mode
.\optimization.ps1 -VerboseMode

# View last log
explorer "%LOCALAPPDATA%\Win11-UI-Optimizer\Logs"
```

### Common Log Locations
- Console output: Real-time feedback
- Log files: Detailed operation history
- Error messages: Specific failure reasons

---

## 💡 Pro Tips

1. **Before Updates**: Create a backup before major Windows updates
2. **Test First**: Try on a test machine before production
3. **Keep Backups**: Don't delete old backups immediately
4. **Monitor Performance**: Note improvements after optimization
5. **Restart Required**: Always restart after applying/restoring
6. **Read Logs**: Check logs if something seems wrong
7. **Use Verbose**: Enable `-VerboseMode` when troubleshooting

---

## ⚠️ Important Notes

- ✅ **Always backup** before optimization
- ✅ **Restart Windows** after changes
- ✅ **Run as Administrator** required
- ✅ **Windows 11** recommended (works on Win10 with warnings)
- ✅ **Check logs** if errors occur

---

## 🔄 Restore Process

### Step-by-Step
1. **Launch** script as Administrator
2. **Choose** option 2 (Restore)
3. **Select** backup from list
4. **Review** backup details
5. **Confirm** restoration
6. **Wait** for completion
7. **Restart** Windows

### What Gets Restored
- ✅ All registry values
- ✅ Power plan settings
- ✅ Previous system state

---

## 📈 Expected Results

### After Optimization
- Faster window operations
- Snappier menu displays
- Reduced visual lag
- Lower resource usage
- Quicker system responses

### Performance Metrics
- Menu delay: 500ms → 20ms
- Animation overhead: Eliminated
- Background processes: Reduced
- Power mode: High Performance

---

## 🎓 Best Practices

✅ **DO**
- Create backups regularly
- Review status before/after
- Keep multiple restore points
- Monitor system performance
- Read documentation
- Check logs for errors

❌ **DON'T**
- Skip backups
- Ignore error messages
- Delete all backups
- Run without admin rights
- Optimize without testing

---

## 📱 Quick Commands

```powershell
# Standard run
.\optimization.ps1

# Debug mode
.\optimization.ps1 -VerboseMode

# Custom retention
.\optimization.ps1 -MaxBackups 5

# Open backup location
explorer "$env:LOCALAPPDATA\Win11-UI-Optimizer\Backups"

# Open logs
explorer "$env:LOCALAPPDATA\Win11-UI-Optimizer\Logs"

# Check PowerShell version
$PSVersionTable.PSVersion
```

---

## 🌟 Features at a Glance

| Feature | Available |
|---------|-----------|
| Auto-backup | ✅ Yes |
| Restore | ✅ Yes |
| Logging | ✅ Yes |
| Status Check | ✅ Yes |
| Validation | ✅ Yes |
| Cleanup | ✅ Yes |
| Verbose Mode | ✅ Yes |
| Confirmations | ✅ Yes |

---

**Version**: 2.0.0  
**Last Updated**: November 3, 2025  
**Status**: Production Ready

For detailed information, see **OPTIMIZATION_GUIDE.md**
