# logioptions-bash-script
Run this when Logi options+ breaks your mouse functionallity and freezes on loading due to their certificate misshap.

## macOS Tahoe Script

### Usage
The script `fix-logioptions-macos-tahoe.sh` automates the process of fixing Logi Options+ on macOS Tahoe by manipulating system time to work around certificate validation issues.

```bash
sudo ./fix-logioptions-macos-tahoe.sh
```

**Note:** This script requires sudo privileges to modify system time settings.

### What it does:
1. Disables automatic time synchronization
2. Sets the system date back by one year
3. Force quits Logi Options+ if it's running
4. Starts Logi Options+
5. Re-enables automatic time synchronization

The system time will automatically correct itself once automatic time is re-enabled.
