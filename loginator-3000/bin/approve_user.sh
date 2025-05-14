#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\approve_user.sh

# Content type header for CGI
echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# Read POST data (for CGI) - REPLACE THIS SECTION
if [ ! -z "$CONTENT_LENGTH" ]; then
    # Add 1 to CONTENT_LENGTH to ensure we get all characters
    READ_LENGTH=$((CONTENT_LENGTH + 1))
    read -n "$READ_LENGTH" POST_DATA
else
    POST_DATA=""
fi

# Log the full POST data for debugging
echo "Full POST data: $POST_DATA" >> ../data/approve_error.log


# Extract username from POST data (URL-decoded)
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/%40/@/g')

if [ -z "$USERNAME" ]; then
    echo '{"success":false,"message":"No username provided"}'
    exit 1
fi

echo "Approving user: $USERNAME" >> ../data/approve_error.log

mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
INSERT INTO users (
    username, password, email, phone, registration_date, security_question, security_answer, active
)
SELECT
    username, password, email, phone, registration_date, security_question, security_answer, 1
FROM pending_users WHERE username='$USERNAME';
DELETE FROM pending_users WHERE username='$USERNAME';
" 2>>../data/approve_error.log

echo '{"success":true,"message":"User approved successfully"}'





# # Setup directories and files
# DATA_DIR="../data"
# PENDING="$DATA_DIR/pending.txt"  # Using the correct filename from get_pending_users.sh
# USERS="$DATA_DIR/users.txt"
# LOG="$DATA_DIR/admin_log.txt"
# DEBUG_LOG="$DATA_DIR/debug.log"

# mkdir -p "$DATA_DIR"
# touch "$PENDING"
# touch "$USERS"

# # Debug logging
# echo "===== APPROVE USER $(date) =====" >> "$DEBUG_LOG"

# # Read POST data
# if [ ! -z "$CONTENT_LENGTH" ]; then
#     POST_DATA=$(cat)
#     echo "POST data: $POST_DATA" >> "$DEBUG_LOG"
# else
#     POST_DATA=""
#     echo "No POST data received" >> "$DEBUG_LOG"
# fi

# # Extract username
# USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//')
# echo "Username to approve: $USERNAME" >> "$DEBUG_LOG"

# echo "Pending file content:" >> "$DEBUG_LOG"
# cat "$PENDING" >> "$DEBUG_LOG"

# echo "Content-Type: application/json"
# echo ""

# # Check if user exists in pending
# if grep -q "^$USERNAME:" "$PENDING"; then
#     echo "User found in pending file" >> "$DEBUG_LOG"
    
#     # Extract full user entry
#     USER_ENTRY=$(grep "^$USERNAME:" "$PENDING")
#     echo "User entry: $USER_ENTRY" >> "$DEBUG_LOG"
    
#     # Add to users.txt - IMPORTANT: Ensure no extra blank lines or spaces
#     echo "$USER_ENTRY" >> "$USERS"
    
#     # Remove from pending
#     grep -v "^$USERNAME:" "$PENDING" > "$PENDING.tmp"
#     mv "$PENDING.tmp" "$PENDING"
    
#     # Log the approval
#     echo "$(date): Admin approved user $USERNAME" >> "$LOG"
    
#     echo '{"success":true,"message":"User approved successfully"}'
# else
#     echo "User not found in pending file" >> "$DEBUG_LOG"
#     echo '{"success":false,"message":"User not found in pending list"}'
# fi