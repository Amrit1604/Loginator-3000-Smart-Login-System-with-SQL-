#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\login.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

mkdir -p ../data

echo "================================" >> "$DEBUG_LOG"
echo "LOGIN ATTEMPT: $(date)" >> "$DEBUG_LOG"
echo "HTTP_COOKIE: $HTTP_COOKIE" >> "$DEBUG_LOG"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "Raw POST data: $POST_DATA" >> "$DEBUG_LOG"
else
    POST_DATA=""
    echo "No POST data received" >> "$DEBUG_LOG"
fi

# Extract username and password with improved URL decoding
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
PASSWORD=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/password=//' | sed 's/%40/@/g' | sed 's/%21/!/g' | sed 's/%23/#/g' | sed 's/%24/$/g' | sed 's/%26/\&/g' | sed 's/%27/'\''/g' | sed 's/%28/(/g' | sed 's/%29/)/g' | sed 's/%2A/*/g' | sed 's/%2B/+/g' | sed 's/%2C/,/g' | sed 's/%3A/:/g' | sed 's/%3B/;/g' | sed 's/%3D/=/g' | sed 's/%3F/?/g' | sed 's/+/ /g')

echo "Extracted username: '$USERNAME'" >> "$DEBUG_LOG"
echo "Extracted password: [REDACTED]" >> "$DEBUG_LOG"

# Input validation
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Missing username or password" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Username and password required."}'
    exit 0
fi

# Check credentials in users table (active users only)
USER_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM users WHERE username='$USERNAME' AND password='$PASSWORD' AND active=1;")
if [ "$USER_EXISTS" -eq 1 ]; then
    echo "Login successful for $USERNAME" >> "$DEBUG_LOG"
    # Generate a session ID and log it
    SESSION_ID="${USERNAME}_session_$(date +%s)"
    echo "Generated session ID: $SESSION_ID" >> "$DEBUG_LOG"
    
    # Track login activity (add this line)
    ./track_login.sh "$USERNAME" "$REMOTE_ADDR" "$HTTP_USER_AGENT" &> /dev/null &
    
    echo "{\"success\":true,\"redirect\":\"dashboard.html\",\"username\":\"$USERNAME\"}"

else
    # Check if user exists but is not active
    INACTIVE_USER=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM users WHERE username='$USERNAME' AND password='$PASSWORD' AND active=0;")
    if [ "$INACTIVE_USER" -eq 1 ]; then
        echo "Login failed for $USERNAME: account not active" >> "$DEBUG_LOG"
        echo '{"success":false,"message":"Your account is not active. Please contact administration to allow your access."}'
    else
        echo "Login failed for $USERNAME" >> "$DEBUG_LOG"
        echo '{"success":false,"message":"Invalid username or password."}'
    fi
fi





# # Setup directories and log files
# mkdir -p ../data
# USERS_FILE="../data/users.txt"
# LOG_FILE="../data/login_log.txt"
# DEBUG_LOG="../data/debug.log"
# ACTIVE_USERS="../data/active_users.txt"

# # Initial debug log entry with timestamp for easy tracking
# echo "================================" >> "$DEBUG_LOG"
# echo "LOGIN ATTEMPT: $(date)" >> "$DEBUG_LOG"
# echo "HTTP_COOKIE: $HTTP_COOKIE" >> "$DEBUG_LOG"

# # Read POST data
# if [ ! -z "$CONTENT_LENGTH" ]; then
#     POST_DATA=$(cat)
#     echo "Raw POST data: $POST_DATA" >> "$DEBUG_LOG"
# else
#     POST_DATA=""
#     echo "No POST data received" >> "$DEBUG_LOG"
# fi

# # Extract username and password with improved URL decoding
# USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
# PASSWORD=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/password=//' | sed 's/%40/@/g' | sed 's/%21/!/g' | sed 's/%23/#/g' | sed 's/%24/$/g' | sed 's/%26/\&/g' | sed 's/%27/'\''/g' | sed 's/%28/(/g' | sed 's/%29/)/g' | sed 's/%2A/*/g' | sed 's/%2B/+/g' | sed 's/%2C/,/g' | sed 's/%3A/:/g' | sed 's/%3B/;/g' | sed 's/%3D/=/g' | sed 's/%3F/?/g' | sed 's/+/ /g')

# echo "Extracted username: '$USERNAME'" >> "$DEBUG_LOG"
# echo "Extracted password: [REDACTED]" >> "$DEBUG_LOG"

# # Ensure data files exist
# mkdir -p ../data
# touch "$USERS_FILE"
# touch "$LOG_FILE"
# touch "$ACTIVE_USERS"

# echo "Checking users file: $USERS_FILE" >> "$DEBUG_LOG"
# echo "File exists: $([ -f "$USERS_FILE" ] && echo "Yes" || echo "No")" >> "$DEBUG_LOG"
# echo "File size: $(wc -c < "$USERS_FILE" 2>/dev/null || echo "unknown") bytes" >> "$DEBUG_LOG"
# echo "File permissions: $(ls -la "$USERS_FILE" 2>/dev/null || echo "unknown")" >> "$DEBUG_LOG"

# # Debug: Show users file content with line numbers to help debug
# echo "Users file content (with line numbers):" >> "$DEBUG_LOG"
# nl -ba "$USERS_FILE" >> "$DEBUG_LOG" 2>/dev/null || cat "$USERS_FILE" >> "$DEBUG_LOG"

# # First check if the file is empty
# if [ ! -s "$USERS_FILE" ]; then
#     echo "⚠️ Users file is empty!" >> "$DEBUG_LOG"
#     echo "Content-Type: application/json"
#     echo ""
#     echo "{\"success\":false,\"message\":\"No registered users found. Please contact administrator.\"}"
#     exit 0
# fi

# # Create temp file with Unix line endings for consistent processing
# TMP_FILE=$(mktemp)
# cat "$USERS_FILE" | tr -d '\r' > "$TMP_FILE"

# echo "Checking for user: '$USERNAME'" >> "$DEBUG_LOG"

# # Try multiple grep approaches for better reliability
# echo "Grep attempt 1 result:" >> "$DEBUG_LOG"
# grep "^$USERNAME:" "$TMP_FILE" >> "$DEBUG_LOG" || echo "No match" >> "$DEBUG_LOG"

# echo "Grep attempt 2 (case-insensitive) result:" >> "$DEBUG_LOG"
# grep -i "^$USERNAME:" "$TMP_FILE" >> "$DEBUG_LOG" || echo "No match" >> "$DEBUG_LOG"

# # Check if user exists in users file - first try exact match, then case-insensitive
# USER_LINE=$(grep "^$USERNAME:" "$TMP_FILE" || grep -i "^$USERNAME:" "$TMP_FILE" || echo "")

# if [ -n "$USER_LINE" ]; then
#     echo "Found user entry: $USER_LINE" >> "$DEBUG_LOG"
    
#     # Extract username with correct case from the matched line
#     MATCHED_USERNAME=$(echo "$USER_LINE" | cut -d':' -f1)
#     echo "Matched username with correct case: $MATCHED_USERNAME" >> "$DEBUG_LOG"
    
#     # Extract stored password
#     STORED_PASSWORD=$(echo "$USER_LINE" | cut -d':' -f2)
#     echo "Stored password length: ${#STORED_PASSWORD} chars" >> "$DEBUG_LOG"
#     echo "Input password length: ${#PASSWORD} chars" >> "$DEBUG_LOG"
    
#     # NEW: Decode stored password if it contains URL encoding
#     DECODED_PASSWORD="$STORED_PASSWORD"
#     if echo "$STORED_PASSWORD" | grep -q "%"; then
#         DECODED_PASSWORD=$(echo "$STORED_PASSWORD" | sed 's/%40/@/g' | sed 's/%21/!/g' | sed 's/%23/#/g' | sed 's/%24/$/g')
#         echo "Decoded stored password for comparison" >> "$DEBUG_LOG"
#     fi
    
#     # Compare passwords character by character to find where they differ
#     for ((i=0; i<${#PASSWORD} && i<${#DECODED_PASSWORD}; i++)); do
#         if [ "${PASSWORD:$i:1}" != "${DECODED_PASSWORD:$i:1}" ]; then
#             echo "Passwords differ at position $i: '${PASSWORD:$i:1}' vs '${DECODED_PASSWORD:$i:1}'" >> "$DEBUG_LOG"
#         fi
#     done
    
#     echo "Passwords match: $([ "$PASSWORD" = "$DECODED_PASSWORD" ] && echo "Yes" || echo "No")" >> "$DEBUG_LOG"
    
#     # Check active status
#     if ! grep -q "^$MATCHED_USERNAME:" "$ACTIVE_USERS" 2>/dev/null; then
#         echo "⚠️ User account not activated by admin" >> "$DEBUG_LOG"
#         echo "Content-Type: application/json"
#         echo ""
#         echo "{\"success\":false,\"message\":\"Your account is not active. Please contact administrator.\"}"
#         exit 0
#     fi
    
#     # Verify password - USING DECODED PASSWORD
#     if [ "$PASSWORD" = "$DECODED_PASSWORD" ] || [ "$PASSWORD" = "$STORED_PASSWORD" ]; then
#         echo "✅ Password verified!" >> "$DEBUG_LOG"
        
#         # Generate session ID
#         SESSION_ID="${MATCHED_USERNAME}_session_$(date +%s)"
#         echo "Generated session ID: $SESSION_ID" >> "$DEBUG_LOG"
        
#         # Create sessions directory if it doesn't exist
#         mkdir -p "../data/sessions"
        
#         # Save session in user-specific file for better organization
#         echo "$SESSION_ID:$(date +%s)" > "../data/sessions/${MATCHED_USERNAME}_session.txt"
        
#         # Also save to central sessions file
#         echo "$SESSION_ID:$MATCHED_USERNAME:$(date +%s)" >> "../data/user_sessions.txt"
        
#         # Log successful login
#         echo "$(date): User $MATCHED_USERNAME logged in successfully" >> "$LOG_FILE"
        
#         # IMPORTANT FIX: Update active users without overwriting
#         # First remove any existing entry for this user
#         if [ -f "$ACTIVE_USERS" ]; then
#             grep -v "^$MATCHED_USERNAME:" "$ACTIVE_USERS" > "$ACTIVE_USERS.tmp"
#             mv "$ACTIVE_USERS.tmp" "$ACTIVE_USERS"
#         fi
#         # Then append the user
#         echo "$MATCHED_USERNAME:$(date +%s)" >> "$ACTIVE_USERS"
        
#         # IMPORTANT: Set headers, then a blank line, then content
#         echo "Content-Type: application/json"
#         echo "Set-Cookie: user_session=$SESSION_ID; Path=/; SameSite=Lax"
#         echo ""
#         echo "{\"success\":true,\"redirect\":\"dashboard.html\",\"username\":\"$MATCHED_USERNAME\"}"
        
#         echo "Login successful, session cookie set" >> "$DEBUG_LOG"



# if [ "$password_valid" = "true" ]; then
#     # Generate a 6-digit code
#     code=$(shuf -i 100000-999999 -n 1 2>/dev/null || echo "123456")
    
#     # Save the code
#     echo "$code" > "/tmp/2fa_${username}"
    
#     # For testing, print code to error log so you can see it
#     echo "2FA CODE for $username: $code" >&2
    
#     # Return twofa flag instead of success
#     echo 'Content-Type: application/json'
#     echo
#     echo '{"twofa": true}'
#     exit 0
# fi
#     else
#         echo "❌ Password verification failed" >> "$DEBUG_LOG"
#         echo "Content-Type: application/json"
#         echo ""
#         echo "{\"success\":false,\"message\":\"Invalid username or password\"}"
#     fi
# else
#     echo "❌ User not found in database" >> "$DEBUG_LOG"
    
#     # Extra debugging - try to find similar usernames
#     echo "Similar usernames in database:" >> "$DEBUG_LOG"
#     grep -i "$USERNAME" "$TMP_FILE" >> "$DEBUG_LOG" || echo "None found" >> "$DEBUG_LOG"
    
#     echo "Content-Type: application/json"
#     echo ""
#     echo "{\"success\":false,\"message\":\"Invalid username or password\"}"
# fi

# # Clean up temporary file
# rm -f "$TMP_FILE"