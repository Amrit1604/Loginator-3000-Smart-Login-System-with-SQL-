#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\toggle_user_status.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    READ_LENGTH=$((CONTENT_LENGTH + 1))
    read -n "$READ_LENGTH" POST_DATA
else
    POST_DATA=""
fi

# Log for debugging
echo "POST data: $POST_DATA" >> ../data/admin_debug.log

# Extract username and status
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/%40/@/g')
STATUS=$(echo "$POST_DATA" | grep -o 'status=[^&]*' | sed 's/status=//')

if [ -z "$USERNAME" ] || [ -z "$STATUS" ]; then
    echo '{"success":false,"message":"Missing username or status"}'
    exit 1
fi

# Determine the new active value
if [ "$STATUS" = "active" ]; then
    NEW_ACTIVE=1
else
    NEW_ACTIVE=0
fi

# Update user status
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
UPDATE users 
SET active = $NEW_ACTIVE
WHERE username = '$USERNAME';
" 2>>../data/admin_debug.log

# Check if the update was successful
if [ $? -eq 0 ]; then
    echo '{"success":true,"message":"User status updated successfully"}'
else
    echo '{"success":false,"message":"Failed to update user status"}'
fi




# echo "Content-Type: application/json"
# echo ""

# # Read POST data
# if [ ! -z "$CONTENT_LENGTH" ]; then
#     POST_DATA=$(cat)
# else
#     POST_DATA=""
# fi

# # Extract username and status
# USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//')
# STATUS=$(echo "$POST_DATA" | grep -o 'status=[^&]*' | sed 's/status=//')

# # Paths
# ACTIVE_USERS="../data/active_users.txt"
# LOG_FILE="../data/admin_log.txt"

# # Create files if they don't exist
# mkdir -p ../data
# touch "$ACTIVE_USERS"
# touch "$LOG_FILE"

# # Check for valid admin session (should be added for security)
# # ...

# # Update user status
# if [ "$STATUS" = "active" ]; then
#     # Add to active users
#     if ! grep -q "^$USERNAME:" "$ACTIVE_USERS"; then
#         echo "$USERNAME:$(date +%s)" >> "$ACTIVE_USERS"
#     fi
#     echo "$(date): Admin activated user $USERNAME" >> "$LOG_FILE"
#     echo '{"success":true,"message":"User activated successfully"}'
# else
#     # Remove from active users
#     grep -v "^$USERNAME:" "$ACTIVE_USERS" > "$ACTIVE_USERS.tmp"
#     mv "$ACTIVE_USERS.tmp" "$ACTIVE_USERS"
#     echo "$(date): Admin deactivated user $USERNAME" >> "$LOG_FILE"
#     echo '{"success":true,"message":"User deactivated successfully"}'
# fi