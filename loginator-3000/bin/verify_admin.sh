#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\verify_admin.sh

# Set up paths
SESSION_FILE="../data/admin_session.txt"
DEBUG_LOG="../data/admin_debug.log"

# Debug logging
echo "=== ADMIN SESSION VERIFICATION $(date) ===" >> "$DEBUG_LOG"
echo "HTTP_COOKIE: $HTTP_COOKIE" >> "$DEBUG_LOG"

# Check if session file exists
if [ ! -f "$SESSION_FILE" ]; then
    echo "No admin session file exists" >> "$DEBUG_LOG"
    echo "Content-Type: application/json"
    echo ""
    echo '{"valid":false}'
    exit 0
fi

# Extract session ID from cookie
SESSION_ID=""
if [ ! -z "$HTTP_COOKIE" ]; then
    SESSION_ID=$(echo "$HTTP_COOKIE" | grep -o 'admin_session=[^;]*' | sed 's/admin_session=//')
    echo "Extracted session ID: $SESSION_ID" >> "$DEBUG_LOG"
fi

# Check if session ID is empty
if [ -z "$SESSION_ID" ]; then
    echo "No admin session ID found in cookie" >> "$DEBUG_LOG"
    echo "Content-Type: application/json"
    echo ""
    echo '{"valid":false}'
    exit 0
fi

# Read stored session
STORED_SESSION=$(cat "$SESSION_FILE" | cut -d':' -f1)
echo "Stored session: $STORED_SESSION" >> "$DEBUG_LOG"

# Verify session
if [ "$SESSION_ID" = "$STORED_SESSION" ]; then
    # Session is valid
    echo "Admin session is valid" >> "$DEBUG_LOG"
    echo "Content-Type: application/json"
    echo ""
    echo '{"valid":true}'
else
    # Session is invalid
    echo "Admin session is invalid" >> "$DEBUG_LOG"
    echo "Content-Type: application/json"
    echo ""
    echo '{"valid":false}'
fi