#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\admin_login.sh

# Debug logging setup
mkdir -p ../data
echo "===== ADMIN LOGIN ATTEMPT $(date) =====" >> ../data/debug.log

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "Raw POST data: $POST_DATA" >> ../data/debug.log
else
    POST_DATA=""
    echo "No POST data received" >> ../data/debug.log
fi

# Extract username and password with URL decoding
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//')
# IMPORTANT FIX: Properly decode %40 to @
PASSWORD=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/password=//' | sed 's/%40/@/g')

echo "Parsed username: '$USERNAME'" >> ../data/debug.log
echo "Parsed password: '$PASSWORD'" >> ../data/debug.log

# Admin credentials
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin@123"

# Check credentials
if [ "$USERNAME" = "$ADMIN_USERNAME" ] && [ "$PASSWORD" = "$ADMIN_PASSWORD" ]; then
    echo "Credentials match!" >> ../data/debug.log
    
    # CRITICAL FIX: Generate session ID BEFORE setting headers
    SESSION_ID=$(date +%s%N | sha256sum | head -c 64)
    echo "Generated session ID: $SESSION_ID" >> ../data/debug.log
    
    # Save session - IMPORTANT: Must use same session ID for cookie and file
    echo "$SESSION_ID:$ADMIN_USERNAME:$(date +%s)" >> "../data/admin_sessions.txt"
    echo "Saved session to admin_sessions.txt" >> ../data/debug.log
    
    # Now set headers with the SAME session ID
    echo "Content-Type: application/json"
    echo "Set-Cookie: admin_session=$SESSION_ID; Path=/"
    echo ""
    
    # Return success JSON
    echo '{"success":true,"redirect":"admin.html"}'
else
    # For failed login, we don't set cookies
    echo "Content-Type: application/json"
    echo ""
    
    echo "Credentials do not match." >> ../data/debug.log
    echo "$(date): Failed admin login attempt with username: $USERNAME" >> "../data/failed_logins.txt"
    echo '{"success":false,"message":"Invalid admin credentials"}'
fi