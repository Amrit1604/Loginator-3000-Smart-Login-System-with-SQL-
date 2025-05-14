#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\admin_login.sh

# Create data directory if it doesn't exist
mkdir -p ../data
DEBUG_LOG="../data/admin_debug.log"

# Set up paths
ADMIN_FILE="../data/admin.txt"
LOG_FILE="../data/admin_log.txt"

# Debug logging
echo "=== ADMIN LOGIN ATTEMPT $(date) ===" >> "$DEBUG_LOG"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "Raw POST data: $POST_DATA" >> "$DEBUG_LOG"
else
    POST_DATA=""
    echo "No POST data received" >> "$DEBUG_LOG"
fi

# Extract username and password with URL decoding
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//')
PASSWORD=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/password=//' | sed 's/%40/@/g')

echo "Login attempt for admin: $USERNAME" >> "$DEBUG_LOG"

# Check if admin credentials are correct (In production, use a more secure method)
if [ "$USERNAME" = "admin" ] && [ "$PASSWORD" = "admin@123" ]; then
    # Login successful
    echo "Admin login successful" >> "$DEBUG_LOG"
    
    # Generate session ID
    SESSION_ID=$(date +%s%N | sha256sum | head -c 64)
    
    # Store session ID in file
    echo "$SESSION_ID:admin:$(date +%s)" > "../data/admin_session.txt"
    chmod 600 "../data/admin_session.txt"
    
    # Log successful login
    echo "$(date): Admin logged in successfully" >> "$LOG_FILE"
    
    # Send HTTP response with session cookie
    echo "Content-Type: application/json"
    echo "Set-Cookie: admin_session=$SESSION_ID; Path=/"
    echo ""
    
    echo '{"success":true,"redirect":"admin.html"}'
else
    # Login failed
    echo "Admin login failed - invalid credentials" >> "$DEBUG_LOG"
    
    # Send HTTP response
    echo "Content-Type: application/json"
    echo ""
    
    echo '{"success":false,"message":"Invalid admin credentials"}'
fi