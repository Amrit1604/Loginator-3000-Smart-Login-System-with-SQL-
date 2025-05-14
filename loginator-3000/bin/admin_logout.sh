#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\admin_logout.sh

# Set content type for JSON response
echo "Content-Type: application/json"
echo ""

# Get session ID from cookie
SESSION_ID=$(echo "$HTTP_COOKIE" | grep -o 'admin_session=[^;]*' | sed 's/admin_session=//')

# Path to admin sessions file
ADMIN_SESSIONS_FILE="../data/admin_sessions.txt"

# Check if session ID is provided
if [ -z "$SESSION_ID" ]; then
    echo '{"success":false,"message":"No active admin session"}'
    exit 0
fi

# Create a temporary file
TEMP_FILE=$(mktemp)

# Remove the session and write to temp file
if [ -f "$ADMIN_SESSIONS_FILE" ]; then
    grep -v "^$SESSION_ID:" "$ADMIN_SESSIONS_FILE" > "$TEMP_FILE"
    
    # Replace the old file with the new one
    mv "$TEMP_FILE" "$ADMIN_SESSIONS_FILE"
fi

# Clear the session cookie
echo "Set-Cookie: admin_session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly"

# Return success
echo '{"success":true,"redirect":"index.html"}'
