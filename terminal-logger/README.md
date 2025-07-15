# Terminal Activity Logger

A comprehensive and reliable terminal activity logging system for Kali Linux that captures all commands and terminal sessions with precise timestamps for client documentation, compliance, and accountability.

## Overview

This tool provides professional-grade logging capabilities for penetration testers, security professionals, and anyone who needs detailed documentation of their terminal activities. It's specifically designed for client engagement documentation and evidence collection with a focus on simplicity and reliability.

## Features

### 🚀 **Simple & Reliable**
- **Zero Configuration**: Automatically creates all required directories
- **Works Immediately**: No complex setup required
- **Proven Functionality**: Simplified approach that actually works
- **Minimal Dependencies**: Uses standard Linux tools only

### 📝 **Comprehensive Logging**
- **Command History**: Every command with millisecond precision timestamps  
- **Working Directory**: Tracks location context for each command
- **User Information**: Records who executed what and when
- **Complete Terminal Recording**: Full session capture including all output
- **Session Metadata**: Detailed information about each logging session

### 🎯 **Client-Ready Features**
- **Professional HTML Reports**: Clean, formatted reports ready for client delivery
- **Timeline Documentation**: Clear chronological view of all activities
- **Evidence Quality**: Complete audit trail with timestamps
- **Multiple Views**: Command history, full output, and session metadata
- **Easy Sharing**: Self-contained HTML reports

### 🔧 **Session Management**
- **Named Sessions**: Organize logs by client, project, or engagement
- **Session Isolation**: Each session is completely separate
- **Easy Navigation**: List, view, and manage all sessions
- **Automatic Organization**: Time-stamped and clearly organized storage

## Installation

### Quick Start
```bash
# Navigate to the terminal-logger directory
cd terminal-logger

# Make executable (if not already)
chmod +x terminal-logger.sh

# Start logging immediately (requires sudo for setup)
sudo ./terminal-logger.sh start client_pentest
```

**Note**: Sudo is only required for the initial directory setup and to switch to your user account. The actual logging session runs as your normal user.

## Usage

### Basic Commands

#### Start Logging Session
```bash
# Start with custom session name (sudo required for setup)
sudo ./terminal-logger.sh start client_pentest

# Start with auto-generated name
sudo ./terminal-logger.sh start

# Example session names
sudo ./terminal-logger.sh start acme_corp_pentest
sudo ./terminal-logger.sh start webapp_assessment
sudo ./terminal-logger.sh start network_scan
```

#### Stop Current Session
```bash
# Simply exit the logged shell
exit
```

#### List All Sessions
```bash
./terminal-logger.sh list
```

#### View Session Details
```bash
./terminal-logger.sh view client_pentest_20250715_143022
```

#### Manual Setup (Optional)
```bash
sudo ./terminal-logger.sh setup
```

### What Happens When You Start

1. **Directory Setup**: Creates `/var/log/terminal-activity/` if needed
2. **Session Creation**: Creates timestamped session directory
3. **User Switch**: Switches to your normal user account  
4. **Logging Starts**: Opens interactive shell with `[LOGGING]` prompt
5. **Command Capture**: Records every command with timestamps
6. **Output Recording**: Captures complete terminal session
7. **Report Generation**: Creates HTML report when session ends

### Advanced Usage

#### Viewing Session Output
```bash
# View complete terminal output
less /var/log/terminal-activity/sessions/[session_name]/terminal_output.log

# View just the commands
cat /var/log/terminal-activity/sessions/[session_name]/commands.log

# View session metadata
cat /var/log/terminal-activity/sessions/[session_name]/session_info.txt
```

#### Viewing Reports
```bash
# Open HTML report in browser
firefox /var/log/terminal-activity/sessions/[session_name]/session_report.html

# Or any other browser
google-chrome /var/log/terminal-activity/sessions/[session_name]/session_report.html
```

## File Structure

### Storage Locations
```
/var/log/terminal-activity/
├── sessions/
│   ├── client_pentest_20250715_143022/
│   │   ├── session_info.txt          # Session metadata
│   │   ├── commands.log               # Timestamped commands
│   │   ├── bash_history.log           # Raw bash history with timestamps
│   │   ├── terminal_output.log        # Complete terminal session
│   │   ├── session_report.html        # Professional HTML report
│   │   └── start_shell.sh             # Session startup script
│   └── another_session_20250715_150000/
│       └── ...
```

### Generated Files

#### `session_info.txt`
```
Session Name: client_pentest_20250715_143022
Start Time: 2025-07-15 14:30:22 UTC
User: ac1d
Hostname: kali-machine
Working Directory: /home/ac1d
PID: 12345
End Time: 2025-07-15 16:45:33 UTC
```

#### `commands.log`
```
[2025-07-15 14:30:22.123] [ac1d] [/opt/targets] nmap -sS 192.168.1.100
[2025-07-15 14:30:45.456] [ac1d] [/opt/targets] gobuster dir -u http://target.com
[2025-07-15 14:31:02.789] [ac1d] [/opt/evidence] ls -la findings/
[2025-07-15 14:31:15.234] [ac1d] [/opt/evidence] cp scan_results.txt evidence/
```

#### `session_report.html`
Professional HTML report with:
- Session information and metadata
- Complete command timeline with timestamps
- Full terminal output (searchable)
- File inventory and session details
- Professional styling ready for client delivery

## Client Benefits

### 🎯 **Professional Documentation**
- **Complete Transparency**: Every action timestamped and logged
- **Professional Presentation**: Clean, formatted reports
- **Evidence Quality**: Court-ready documentation standards
- **Client Confidence**: Clear proof of work performed

### ⏰ **Time Tracking**
- **Precise Timing**: Millisecond accuracy for billing
- **Session Duration**: Total time spent per engagement
- **Activity Breakdown**: Detailed view of time allocation
- **Efficiency Metrics**: Performance tracking capabilities

### 🔒 **Compliance & Audit**
- **Audit Trail**: Complete chain of evidence
- **Regulatory Compliance**: Meets documentation requirements
- **Quality Assurance**: Verifiable work standards
- **Risk Management**: Documented security practices

## Technical Details

### System Requirements
- **Operating System**: Kali Linux (tested), Ubuntu/Debian (compatible)
- **Privileges**: Root access for initial setup only
- **Dependencies**: `script`, `bash` (standard Linux tools)
- **Storage**: Minimal disk space (text logs are small)

### Security Considerations
- **Log Security**: Stored in protected system directories
- **Access Control**: Root-owned directories, user-owned session files  
- **Data Integrity**: Timestamps prevent tampering
- **User Context**: Logging runs as normal user, not root

### Performance Impact
- **Minimal Overhead**: Lightweight logging mechanism
- **Background Operation**: No interference with normal operations
- **Efficient Storage**: Text-based logs with small footprint
- **Resource Usage**: Negligible CPU and memory impact

## Troubleshooting

### Common Issues

#### Permission Denied
```bash
# Ensure running with sudo for session start
sudo ./terminal-logger.sh start session_name
```

#### Session Not Starting
```bash
# Check if directories exist
ls -la /var/log/terminal-activity/

# Manual setup if needed
sudo ./terminal-logger.sh setup
```

#### Can't See Previous Sessions
```bash
# List all sessions
./terminal-logger.sh list

# View specific session
./terminal-logger.sh view session_name_timestamp
```

### Debug Tips
```bash
# Check what sessions exist
ls -la /var/log/terminal-activity/sessions/

# Verify latest session contents  
ls -la /var/log/terminal-activity/sessions/$(ls -t /var/log/terminal-activity/sessions/ | head -1)/

# Check session permissions
sudo ls -la /var/log/terminal-activity/sessions/[session_name]/
```

## Best Practices

### Session Naming
- Use descriptive, consistent naming conventions
- Include client/project identifiers
- Use dates for easy sorting
- Examples:
  - `acme_corp_webapp_pentest`
  - `client_network_assessment`
  - `internal_audit_2025`

### Log Management
- Review and archive old sessions regularly
- Export important sessions before cleanup
- Maintain separate logs per engagement
- Document session purposes in reports

### Client Delivery
- Generate HTML reports for each session
- Include session replay instructions
- Provide both technical logs and summary reports
- Archive complete session data

## Examples

### Typical Penetration Testing Session
```bash
# Start engagement logging
sudo ./terminal-logger.sh start acme_pentest

# You'll see the logging prompt:
[LOGGING] ac1d@kali:~$ 

# Your normal workflow - all commands are logged:
nmap -sS 192.168.1.0/24
gobuster dir -u http://target.acme.com
sudo sqlmap -u "http://target.acme.com/login.php" --data="user=test&pass=test"
# ... more testing commands ...

# Stop logging by exiting the session
exit

# View the generated report
firefox /var/log/terminal-activity/sessions/acme_pentest_[timestamp]/session_report.html
```

### Managing Multiple Projects
```bash
# Different sessions for different clients
sudo ./terminal-logger.sh start client_a_webapp
# ... work on client A ...
exit

sudo ./terminal-logger.sh start client_b_network  
# ... work on client B ...
exit

# Review all sessions
./terminal-logger.sh list

# View specific sessions
./terminal-logger.sh view client_a_webapp_20250715_143022
./terminal-logger.sh view client_b_network_20250715_150000
```

### What You'll See During Logging

**Starting a Session:**
```
[SUCCESS] Started logging session: pentest_demo_20250715_105932
[INFO] Session directory: /var/log/terminal-activity/sessions/pentest_demo_20250715_105932
==========================================
         TERMINAL LOGGING ACTIVE
==========================================
Session: pentest_demo_20250715_105932
User: ac1d
Commands logged to: /var/log/terminal-activity/sessions/pentest_demo_20250715_105932/commands.log

Type 'exit' to stop logging
==========================================

[LOGGING] ac1d@kali:~$ 
```

**Working in the Session:**
Every command you type is captured with timestamps and working directory context.

## Support

For issues, questions, or feature requests:
1. Check the troubleshooting section above
2. Verify permissions and directory structure
3. Test with a simple session first
4. Review generated log files for any error messages

**Current Status**: Working and tested on Kali Linux 2025

## License

This tool is provided as-is for educational and authorized security testing purposes only.

---

**Version**: 2.0 (Simplified & Reliable)  
**Author**: ac1d  
**Date**: July 15, 2025  
**Compatibility**: Kali Linux, Ubuntu, Debian  
**Dependencies**: Standard Linux tools (bash, script)  
**Status**: Production Ready
