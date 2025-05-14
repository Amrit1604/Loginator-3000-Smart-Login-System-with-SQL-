#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\check_system.sh

echo "Content-Type: text/plain"
echo ""

echo "SYSTEM CHECK REPORT"
echo "=================="
echo "Date: $(date)"
echo ""

# Function to check file
check_file() {
    local file="$1"
    local description="$2"
    
    echo "----- $description ($file) -----"
    if [ -f "$file" ]; then
        echo "✓ File exists"
        echo "Size: $(wc -c < "$file" 2>/dev/null || echo "unknown") bytes"
        echo "Lines: $(wc -l < "$file" 2>/dev/null || echo "unknown")"
        echo "Format check:"
        if [ -s "$file" ]; then
            head -n 1 "$file" | cat -A
        else
            echo "(file is empty)"
        fi
    else
        echo "✗ File does not exist"
    fi
    echo ""
}

# Setup paths
DATA_DIR="../data"
USERS_FILE="$DATA_DIR/users.txt"
PENDING_FILE="$DATA_DIR/pending.txt"
SESSIONS_FILE="$DATA_DIR/user_sessions.txt"
ACTIVE_USERS="$DATA_DIR/active_users.txt"

# Check directory structure
mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/sessions"

# Check key files
check_file "$USERS_FILE" "Users Database"
check_file "$PENDING_FILE" "Pending Registrations"
check_file "$SESSIONS_FILE" "Session Information"
check_file "$ACTIVE_USERS" "Active Users"

# Check active users
echo "----- Active Users -----"
if [ -f "$ACTIVE_USERS" ] && [ -s "$ACTIVE_USERS" ]; then
    echo "Currently active users:"
    while IFS=: read -r username timestamp rest; do
        if [ ! -z "$username" ]; then
            echo "- $username (since $(date -d @$timestamp 2>/dev/null || echo "unknown"))"
        fi
    done < "$ACTIVE_USERS"
else
    echo "No active users"
fi
echo ""

# Check pending registrations
echo "----- Pending Registrations -----"
if [ -f "$PENDING_FILE" ] && [ -s "$PENDING_FILE" ]; then
    echo "Users awaiting approval:"
    while IFS=: read -r username password email phone date; do
        if [ ! -z "$username" ]; then
            echo "- $username ($email, registered on $date)"
        fi
    done < "$PENDING_FILE"
else
    echo "No pending registrations"
fi
echo ""

echo "System check complete."