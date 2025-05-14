#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\logout.sh

# Setup directories and log files
mkdir -p ../data
LOG_FILE="../data/login_log.txt"
DEBUG_LOG="../data/debug.log"
SESSIONS_FILE="../data/user_sessions.txt"
ACTIVE_USERS="../data/active_users.txt"

# Initial debug log entry
echo "=== LOGOUT $(date) ===" >> "$DEBUG_LOG"
echo "HTTP_COOKIE: $HTTP_COOKIE" >> "$DEBUG_LOG"

# Get session ID from cookie
SESSION_ID=""
if [ ! -z "$HTTP_COOKIE" ]; then
    SESSION_ID=$(echo "$HTTP_COOKIE" | grep -o 'user_session=[^;]*' | sed 's/user_session=//')
    echo "Extracted session ID: $SESSION_ID" >> "$DEBUG_LOG"
fi

# Set headers to expire the cookie
echo "Content-Type: application/json"
echo "Set-Cookie: user_session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT"
echo ""

# If session ID exists, remove it from sessions file and active users
if [ ! -z "$SESSION_ID" ] && [ -f "$SESSIONS_FILE" ]; then
    # Get username from session
    USERNAME=$(grep "^$SESSION_ID:" "$SESSIONS_FILE" | cut -d':' -f2)
    
    if [ ! -z "$USERNAME" ]; then
        echo "Found username for session: $USERNAME" >> "$DEBUG_LOG"
        
        # Remove from sessions file
        grep -v "^$SESSION_ID:" "$SESSIONS_FILE" > "$SESSIONS_FILE.tmp"
        mv "$SESSIONS_FILE.tmp" "$SESSIONS_FILE"
        
        # Remove from active users
        if [ -f "$ACTIVE_USERS" ]; then
            grep -v "^$USERNAME:" "$ACTIVE_USERS" > "$ACTIVE_USERS.tmp"
            mv "$ACTIVE_USERS.tmp" "$ACTIVE_USERS"
        fi
        
        # Remove session file
        rm -f "../data/sessions/${USERNAME}_session.txt"
        
        # Log logout
        echo "$(date): User $USERNAME logged out" >> "$LOG_FILE"
        
        echo "{\"success\":true,\"message\":\"Logged out successfully\"}"
    else
        echo "No username found for session" >> "$DEBUG_LOG"
        echo "{\"success\":true,\"message\":\"Logged out\"}"
    fi
else
    echo "No valid session to logout" >> "$DEBUG_LOG"
    echo "{\"success\":true,\"message\":\"No active session\"}"
fi