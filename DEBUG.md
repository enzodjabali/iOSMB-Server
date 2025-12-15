# iOSMB-Server Debugging Guide

## 🔍 Step-by-Step Debugging

### 1. Check if the daemon is running
```bash
ssh root@YOUR_IPHONE_IP
ps aux | grep iOSMB-Server
```
**Expected output:** You should see `/usr/bin/iOSMB-Server` process
**If not running:** Daemon failed to start

### 2. Check LaunchDaemon status
```bash
launchctl list | grep iosmb
```
**Expected output:** `com.enzodjabali.iosmb-server` with PID
**If not listed:** LaunchDaemon not loaded

### 3. Check if LaunchDaemon file exists
```bash
ls -la /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist
```
**Expected:** File should exist
**If missing:** Installation didn't complete properly

### 4. Check SSL certificates
```bash
ls -la /Library/Application\ Support/iOSMB-Server/
```
**Expected files:**
- `certs.sh`
- `passphrase`
- `iosmb.key`
- `iosmb.pem`
- `iosmb.der`
- `iosmb.p12`

**If missing:** SSL certificate generation failed

### 5. Check preferences file
```bash
cat /var/mobile/Library/Preferences/com.enzodjabali.iosmb-server.plist
```
**Expected:** XML plist with port, ssl, password settings
**If missing:** Settings not saved yet

### 6. Check system logs
```bash
tail -50 /var/log/syslog | grep -i iosmb
# or
tail -50 /var/log/syslog | grep -i webmessage
```
**Look for:** Error messages, crash reports

### 7. Manually load the daemon
```bash
launchctl unload /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist
launchctl load /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist
```
**Then check logs immediately:**
```bash
tail -f /var/log/syslog
```

### 8. Test manual launch
```bash
/usr/bin/iOSMB-Server
```
**Watch for:** Any crash or error output

### 9. Check port binding
```bash
netstat -an | grep 8190
# or
lsof -i :8190
```
**Expected:** Port 8190 should be LISTENING
**If not:** Server isn't running or failed to bind

### 10. Test direct connection
```bash
curl -k https://localhost:8190/
# or
curl http://localhost:8190/
```
**Expected:** Some response (even error is good - means server is running)
**If connection refused:** Server not running

## 🐛 Common Issues & Fixes

### Issue 1: Settings app crashes on "Restart WebMessage"
**Cause:** IPC communication failure
**Fix:** 
1. The daemon must be running first
2. Check if `com.enzodjabali.iosmb-server-listener` IPC center is registered
3. The button should be renamed to "Restart iOSMB-Server"

### Issue 2: Daemon not starting
**Possible causes:**
- SSL certificates missing (check step 4)
- Wrong paths in code (check if using old WebMessage paths)
- Permissions issue (daemon should run as root)
- Missing dependencies (check if libmryipc is installed)

### Issue 3: Port 8190 connection refused
**Possible causes:**
- Daemon not running (check step 1)
- Still trying to use port 8180 somewhere
- Firewall blocking (unlikely on iOS)
- SSL certificate load failure

### Issue 4: Preferences not working
**Fix:**
1. Go to Settings > iOSMB-Server
2. Set password (any value)
3. Set port to 8190
4. Enable/disable SSL toggle
5. This will create the preferences file

## 🔧 Quick Fix Commands

### Complete reinstall:
```bash
# Remove old installation
dpkg -r com.enzodjabali.iosmb-server

# Reinstall
dpkg -i iOSMB-Server.deb

# Force certificate generation
chmod +x /Library/Application\ Support/iOSMB-Server/certs.sh
/Library/Application\ Support/iOSMB-Server/certs.sh

# Restart daemon
launchctl unload /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist
launchctl load /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist

# Check status
ps aux | grep iOSMB-Server
```

### Force daemon restart:
```bash
killall -9 iOSMB-Server
launchctl unload /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist
launchctl load /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist
```

## 📝 Collect Debug Info

Run this script on your iPhone to collect all debug info:

```bash
echo "=== iOSMB-Server Debug Info ===" > /tmp/iosmb-debug.txt
echo "" >> /tmp/iosmb-debug.txt
echo "Process Status:" >> /tmp/iosmb-debug.txt
ps aux | grep iOSMB >> /tmp/iosmb-debug.txt
echo "" >> /tmp/iosmb-debug.txt
echo "LaunchDaemon Status:" >> /tmp/iosmb-debug.txt
launchctl list | grep iosmb >> /tmp/iosmb-debug.txt
echo "" >> /tmp/iosmb-debug.txt
echo "Files:" >> /tmp/iosmb-debug.txt
ls -la /usr/bin/iOSMB-Server >> /tmp/iosmb-debug.txt
ls -la /Library/LaunchDaemons/com.enzodjabali.iosmb-server.plist >> /tmp/iosmb-debug.txt
ls -la /Library/Application\ Support/iOSMB-Server/ >> /tmp/iosmb-debug.txt
echo "" >> /tmp/iosmb-debug.txt
echo "Preferences:" >> /tmp/iosmb-debug.txt
cat /var/mobile/Library/Preferences/com.enzodjabali.iosmb-server.plist >> /tmp/iosmb-debug.txt
echo "" >> /tmp/iosmb-debug.txt
echo "Recent Logs:" >> /tmp/iosmb-debug.txt
tail -50 /var/log/syslog | grep -i iosmb >> /tmp/iosmb-debug.txt
echo "" >> /tmp/iosmb-debug.txt
echo "Port Status:" >> /tmp/iosmb-debug.txt
netstat -an | grep 8190 >> /tmp/iosmb-debug.txt

cat /tmp/iosmb-debug.txt
```

Then share the output to diagnose the issue.
