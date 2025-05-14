#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\verify_session.sh

# Setup basic paths
SESSIONS_FILE="../data/user_sessions.txt" 
DEBUG_LOG="../data/debug.log"

# Initial debug log entry
echo "=== SESSION VERIFICATION $(date) ===" >> "$DEBUG_LOG"
echo "HTTP_COOKIE: $HTTP_COOKIE" >> "$DEBUG_LOG"

# Get session ID from cookie
SESSION_ID=""
if [ ! -z "$HTTP_COOKIE" ]; then
    SESSION_ID=$(echo "$HTTP_COOKIE" | grep -o 'user_session=[^;]*' | sed 's/user_session=//')
    echo "Extracted session ID: $SESSION_ID" >> "$DEBUG_LOG"
fi

# Set content type for JSON response
echo "Content-Type: application/json"
echo ""

# Check if session ID exists
if [ -z "$SESSION_ID" ]; then
    echo "No session ID found" >> "$DEBUG_LOG"
    echo '{"valid":false}'
    exit 0
fi

# Check if session file exists
if [ ! -f "$SESSIONS_FILE" ]; then
    echo "Sessions file not found" >> "$DEBUG_LOG"
    echo '{"valid":false}'
    exit 0
fi

# Look for session in the sessions file
if grep -q "^$SESSION_ID:" "$SESSIONS_FILE"; then
    # Extract username from session entry
    USERNAME=$(grep "^$SESSION_ID:" "$SESSIONS_FILE" | cut -d':' -f2)
    echo "Valid session found for user: $USERNAME" >> "$DEBUG_LOG"
    
    # Return success with username
    echo "{\"valid\":true,\"username\":\"$USERNAME\"}"
else
    echo "Session ID not found in sessions file" >> "$DEBUG_LOG"
    echo '{"valid":false}'
fi