#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\reset_password.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/password_reset.log"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(dd bs=1 count=$CONTENT_LENGTH 2>/dev/null)
else
    POST_DATA=""
fi

# Enhanced debug logging
echo "$(date): New password reset attempt" >> "$DEBUG_LOG"
echo "POST data: $POST_DATA" >> "$DEBUG_LOG"

# Extract data from POST
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
SECURITY_ANSWER=$(echo "$POST_DATA" | grep -o 'security_answer=[^&]*' | sed 's/security_answer=//' | sed 's/+/ /g' | sed 's/%20/ /g')
NEW_PASSWORD=$(echo "$POST_DATA" | grep -o 'new_password=[^&]*' | sed 's/new_password=//' | sed 's/+/ /g' | sed 's/%20/ /g' | sed 's/%40/@/g' | sed 's/%21/!/g' | sed 's/%23/#/g' | sed 's/%24/$/g' | sed 's/%25/%/g' | sed 's/%26/\&/g' | sed 's/%27/'\''/g' | sed 's/%28/(/g' | sed 's/%29/)/g' | sed 's/%2A/*/g' | sed 's/%2B/+/g' | sed 's/%2C/,/g' | sed 's/%3A/:/g' | sed 's/%3B/;/g' | sed 's/%3D/=/g' | sed 's/%3F/?/g')

# Stage determines what we're doing
STAGE=$(echo "$POST_DATA" | grep -o 'stage=[^&]*' | sed 's/stage=//')

# Log all extracted values
echo "USERNAME: $USERNAME" >> "$DEBUG_LOG"
echo "SECURITY_ANSWER: $SECURITY_ANSWER" >> "$DEBUG_LOG"
echo "NEW_PASSWORD: [REDACTED]" >> "$DEBUG_LOG"
echo "STAGE: $STAGE" >> "$DEBUG_LOG"

# If no stage, assume we're at stage 1 (getting security question)
if [ -z "$STAGE" ]; then
    echo "Processing stage 1 (get security question)" >> "$DEBUG_LOG"
    # Check if username exists
    USER_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM users WHERE username='$USERNAME';")
    
    if [ "$USER_EXISTS" -eq 0 ]; then
        echo "Username not found: $USERNAME" >> "$DEBUG_LOG"
        echo "{\"success\":false,\"message\":\"Username not found.\"}"
        exit 0
    fi
    
    # Get security question
    SECURITY_QUESTION=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT security_question FROM users WHERE username='$USERNAME';")
    echo "Found security question for $USERNAME" >> "$DEBUG_LOG"
    
    echo "{\"success\":true,\"stage\":1,\"username\":\"$USERNAME\",\"security_question\":\"$SECURITY_QUESTION\"}"
    exit 0
fi

# Stage 2: Check security answer and reset password
if [ "$STAGE" = "2" ]; then
    echo "Processing stage 2 (reset password)" >> "$DEBUG_LOG"
    # Verify security answer
    STORED_ANSWER=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT security_answer FROM users WHERE username='$USERNAME';")
    
    echo "Username: $USERNAME, Answer: $SECURITY_ANSWER, Stored: $STORED_ANSWER" >> "$DEBUG_LOG"
    
    # Make comparison case-insensitive
    if [ "$(echo "$STORED_ANSWER" | tr '[:upper:]' '[:lower:]')" = "$(echo "$SECURITY_ANSWER" | tr '[:upper:]' '[:lower:]')" ]; then
        echo "Security answer correct, updating password" >> "$DEBUG_LOG"
        # Security answer matches, update password
        RESULT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "UPDATE users SET password='$NEW_PASSWORD' WHERE username='$USERNAME';")
        ERROR=$?
        
        echo "MySQL Result: $RESULT, Exit code: $ERROR" >> "$DEBUG_LOG"
        
        if [ $ERROR -eq 0 ]; then
            echo "Password reset successful for $USERNAME" >> "$DEBUG_LOG"
            echo "{\"success\":true,\"message\":\"Password reset successful! You can now login with your new password.\"}"
        else
            echo "Database error when resetting password for $USERNAME" >> "$DEBUG_LOG"
            echo "{\"success\":false,\"message\":\"Database error. Please try again.\"}"
        fi
    else
        echo "Security answer incorrect for $USERNAME (case-insensitive comparison)" >> "$DEBUG_LOG"
        echo "{\"success\":false,\"message\":\"Security answer does not match our records.\"}"
    fi
    exit 0
fi

echo "Invalid request - stage not recognized: '$STAGE'" >> "$DEBUG_LOG"
echo "{\"success\":false,\"message\":\"Invalid request.\"}"





# echo "Content-Type: application/json"
# echo ""

# # Get POST data
# if [ -n "$CONTENT_LENGTH" ]; then
#     POST_DATA=$(cat)
# else
#     echo '{"success":false,"message":"No data received"}'
#     exit 0
# fi

# # Extract username and new password
# USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
# NEW_PASSWORD=$(echo "$POST_DATA" | grep -o 'password=[^&]*' | sed 's/password=//' | sed 's/+/ /g')

# # Path to users file
# USERS_FILE="../data/users.txt"
# TEMP_FILE=$(mktemp)

# if [ ! -f "$USERS_FILE" ]; then
#     echo '{"success":false,"message":"Users database not found"}'
#     exit 0
# fi

# # Lock for writing
# exec 9>$USERS_FILE.lock
# if ! flock -n 9; then
#     echo '{"success":false,"message":"System busy, try again"}'
#     exit 0
# fi

# # Flag to track if we updated the user
# UPDATED=false

# # Read line by line, update the password for matching user
# while IFS= read -r line || [ -n "$line" ]; do
#     if [[ "$line" =~ ^"$USERNAME": ]]; then
#         # Extract all fields
#         EMAIL=$(echo "$line" | cut -d':' -f3)
#         PHONE=$(echo "$line" | cut -d':' -f4)
#         REG_DATE=$(echo "$line" | cut -d':' -f5)
#         SEC_QUESTION=$(echo "$line" | cut -d':' -f6)
#         SEC_ANSWER=$(echo "$line" | cut -d':' -f7)
        
#         # Write updated user line
#         echo "$USERNAME:$NEW_PASSWORD:$EMAIL:$PHONE:$REG_DATE:$SEC_QUESTION:$SEC_ANSWER" >> "$TEMP_FILE"
#         UPDATED=true
#     else
#         # Keep other lines as is
#         echo "$line" >> "$TEMP_FILE"
#     fi
# done < "$USERS_FILE"

# # Replace original with updated file
# mv "$TEMP_FILE" "$USERS_FILE"

# # Release lock
# flock -u 9

# if [ "$UPDATED" = true ]; then
#     # Log the password reset
#     echo "$(date): Password reset for user $USERNAME" >> "../data/password_reset_log.txt"
#     echo '{"success":true,"message":"Password reset successful"}'
# else
#     echo '{"success":false,"message":"User not found"}'
# fi