#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\reject_user.sh

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

# Extract username
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/%40/@/g')

if [ -z "$USERNAME" ]; then
    echo '{"success":false,"message":"No username provided"}'
    exit 1
fi

# Delete user from pending_users
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
DELETE FROM pending_users 
WHERE username = '$USERNAME';
" 2>>../data/admin_debug.log

# Check if the delete was successful
if [ $? -eq 0 ]; then
    echo '{"success":true,"message":"User rejected successfully"}'
else
    echo '{"success":false,"message":"Failed to reject user"}'
fi




# # Set content type for JSON response
# echo "Content-Type: application/json"
# echo ""

# # Read POST data
# read -n $CONTENT_LENGTH POST_DATA

# # Extract username
# USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/%20/ /g')

# # Path to pending users file
# PENDING_FILE="../data/pending.txt"

# # Check if username is provided
# if [ -z "$USERNAME" ]; then
#     echo '{"success":false,"message":"Username is required"}'
#     exit 0
# fi

# # Check if the user exists in pending
# if ! grep -q "^$USERNAME:" "$PENDING_FILE"; then
#     echo '{"success":false,"message":"User not found in pending registrations"}'
#     exit 0
# fi

# # Create a temporary file
# TEMP_FILE=$(mktemp)

# # Remove the user from pending file
# grep -v "^$USERNAME:" "$PENDING_FILE" > "$TEMP_FILE"

# # Replace the old file with the new one
# mv "$TEMP_FILE" "$PENDING_FILE"

# # Log the rejection
# echo "$(date): Admin rejected user registration: $USERNAME" >> "../data/logs.txt"

# # Return success
# echo "{\"success\":true,\"message\":\"User registration for $USERNAME has been rejected\"}"
