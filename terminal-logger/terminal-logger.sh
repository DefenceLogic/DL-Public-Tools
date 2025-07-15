#!/bin/bash

# Simple Terminal Logger - Direct approach
# This version uses a more direct logging approach

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LOG_DIR="/var/log/terminal-activity"
SESSION_DIR="$LOG_DIR/sessions"

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Setup directories if needed
setup_dirs() {
    if [[ ! -d "$LOG_DIR" ]]; then
        if [[ $EUID -ne 0 ]]; then
            print_error "Need sudo to create log directories"
            echo "Run: sudo $0 $*"
            exit 1
        fi
        mkdir -p "$SESSION_DIR"
        chmod 755 "$LOG_DIR" "$SESSION_DIR"
        if [[ -n "${SUDO_USER:-}" ]]; then
            chown -R "$SUDO_USER:$SUDO_USER" "$LOG_DIR"
        fi
    fi
}

start_session() {
    local session_name="${1:-session_$(date '+%Y%m%d_%H%M%S')}"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local actual_user="${SUDO_USER:-$(whoami)}"
    
    setup_dirs
    
    session_name="${session_name}_${timestamp}"
    local session_path="$SESSION_DIR/$session_name"
    
    mkdir -p "$session_path"
    
    # Fix ownership if running with sudo
    if [[ -n "${SUDO_USER:-}" ]]; then
        chown -R "$SUDO_USER:$SUDO_USER" "$session_path"
    fi
    
    # Create session info
    cat > "$session_path/session_info.txt" << EOF
Session Name: $session_name
Start Time: $(date '+%Y-%m-%d %H:%M:%S %Z')
User: $actual_user
Hostname: $(hostname)
Working Directory: $(pwd)
PID: $$
EOF
    
    print_success "Started logging session: $session_name"
    print_status "Session directory: $session_path"
    
    # Start the logging shell directly
    start_logging_shell "$session_path" "$actual_user"
}

start_logging_shell() {
    local session_path="$1"
    local user="$2"
    local cmd_log="$session_path/commands.log"
    
    # Create the logging shell script
    cat > "$session_path/start_shell.sh" << 'SHELL_EOF'
#!/bin/bash

# Set up logging environment
export SESSION_PATH="$1"
export CMD_LOG="$2"
export LOG_USER="$3"

# Enhanced bash settings
set -o emacs
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "
export HISTFILE="$SESSION_PATH/bash_history.log"
export HISTSIZE=10000
export HISTFILESIZE=20000
shopt -s histappend

# Command logging function
log_cmd() {
    if [[ $# -gt 0 && "$1" != "log_cmd" && "$1" != "history" ]]; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
        local pwd=$(pwd)
        echo "[$timestamp] [$LOG_USER] [$pwd] $*" >> "$CMD_LOG"
    fi
}

# Enhanced prompt
export PS1='\[\033[1;32m\][LOGGING]\[\033[0m\] \u@\h:\w\$ '

# Trap to log commands
trap 'log_cmd $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//" 2>/dev/null || echo "unknown")' DEBUG

clear
echo "=========================================="
echo "         TERMINAL LOGGING ACTIVE"
echo "=========================================="
echo "Session: $(basename "$SESSION_PATH")"
echo "User: $LOG_USER"
echo "Commands logged to: $CMD_LOG"
echo ""
echo "Type 'exit' to stop logging"
echo "=========================================="
echo ""

# Start bash with custom settings
bash --noprofile --norc -i
SHELL_EOF
    
    chmod +x "$session_path/start_shell.sh"
    
    # Start the session recording
    local script_log="$session_path/terminal_output.log"
    
    if [[ -n "${SUDO_USER:-}" ]]; then
        cd "/home/$SUDO_USER" 2>/dev/null || cd /
        # Use script to record everything
        sudo -u "$SUDO_USER" script -q -f "$script_log" -c "$session_path/start_shell.sh $session_path $cmd_log $user"
    else
        script -q -f "$script_log" -c "$session_path/start_shell.sh $session_path $cmd_log $user"
    fi
    
    # Session ended
    echo "End Time: $(date '+%Y-%m-%d %H:%M:%S %Z')" >> "$session_path/session_info.txt"
    print_success "Logging session ended"
    print_status "Session saved to: $session_path"
    
    # Generate simple report
    generate_report "$session_path"
}

generate_report() {
    local session_path="$1"
    local history_log="$session_path/bash_history.log"
    local report="$session_path/session_report.html"
    
    # Generate command log from bash history
    local cmd_log="$session_path/commands.log"
    if [[ -f "$history_log" ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^#([0-9]+)$ ]]; then
                local timestamp="${BASH_REMATCH[1]}"
                # Read the next line which contains the command
                read -r command
                if [[ -n "$command" ]]; then
                    local formatted_time=$(date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S.000' 2>/dev/null || echo "$timestamp")
                    echo "[$formatted_time] [$(whoami)] [unknown] $command" >> "$cmd_log"
                fi
            fi
        done < "$history_log"
    fi
    
    cat > "$report" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Terminal Session Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .command { background: #f8f8f8; padding: 8px; margin: 4px 0; border-left: 3px solid #007acc; font-family: monospace; }
        .timestamp { color: #666; font-weight: bold; }
        .meta { background: #e8f4fd; padding: 10px; margin: 10px 0; border-radius: 3px; }
        .output { background: #f9f9f9; padding: 10px; margin: 10px 0; border: 1px solid #ddd; font-family: monospace; white-space: pre-wrap; max-height: 400px; overflow-y: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Terminal Session Report</h1>
        <p><strong>Generated:</strong> $(date '+%Y-%m-%d %H:%M:%S %Z')</p>
    </div>
    
    <div class="meta">
        <h2>Session Information</h2>
        <pre>$(cat "$session_path/session_info.txt" 2>/dev/null || echo "Session info not available")</pre>
    </div>
    
    <div class="meta">
        <h2>Command History</h2>
EOF
    
    if [[ -f "$cmd_log" ]]; then
        while IFS= read -r line; do
            echo "        <div class=\"command\">$line</div>" >> "$report"
        done < "$cmd_log"
    else
        echo "        <p>No commands logged</p>" >> "$report"
    fi
    
    cat >> "$report" << EOF
    </div>
    
    <div class="meta">
        <h2>Complete Terminal Output</h2>
        <div class="output">$(cat "$session_path/terminal_output.log" 2>/dev/null | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' || echo "No terminal output available")</div>
    </div>
    
    <div class="meta">
        <h2>Files Generated</h2>
        <ul>
            <li><strong>session_info.txt</strong> - Session metadata and timing</li>
            <li><strong>commands.log</strong> - Timestamped command history</li>
            <li><strong>bash_history.log</strong> - Raw bash history with timestamps</li>
            <li><strong>terminal_output.log</strong> - Complete terminal session recording</li>
            <li><strong>session_report.html</strong> - This report</li>
        </ul>
        
        <h3>Session Replay</h3>
        <p>To replay this session, use:</p>
        <code>less $session_path/terminal_output.log</code>
    </div>
</body>
</html>
EOF
    
    print_success "Report generated: $report"
}

# Main
case "${1:-}" in
    start)
        start_session "${2:-}"
        ;;
    list)
        if [[ -d "$SESSION_DIR" ]]; then
            echo "Available sessions:"
            ls -1 "$SESSION_DIR" | sort
        else
            echo "No sessions found"
        fi
        ;;
    view)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 view <session_name>"
            exit 1
        fi
        session="$SESSION_DIR/$2"
        if [[ -d "$session" ]]; then
            echo "=== Session Information ==="
            cat "$session/session_info.txt" 2>/dev/null || echo "No session info"
            echo ""
            echo "=== Command History ==="
            cat "$session/commands.log" 2>/dev/null || echo "No commands logged"
            echo ""
            echo "=== Files ==="
            ls -la "$session/"
        else
            echo "Session not found: $2"
            exit 1
        fi
        ;;
    setup)
        setup_dirs
        print_success "Logging directories setup complete"
        ;;
    *)
        echo "Terminal Activity Logger"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  start [name]    Start a new logging session (requires sudo)"
        echo "  list            List all available sessions"
        echo "  view <name>     View session details"
        echo "  setup           Setup logging directories (requires sudo)"
        echo ""
        echo "Examples:"
        echo "  sudo $0 start pentest_session"
        echo "  $0 list"
        echo "  $0 view pentest_session_20250715_105932"
        exit 1
        ;;
esac
