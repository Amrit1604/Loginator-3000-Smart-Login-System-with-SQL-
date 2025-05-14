#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\check_username.sh

echo "Content-Type: application/json"
echo ""

# Get POST data
if [ -n "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
else
    echo '{"exists":false,"message":"No data received"}'
    exit 0
fi

# Extract username
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')

# Path to users file
USERS_FILE="../data/users.txt"

if [ ! -f "$USERS_FILE" ]; then
    echo '{"exists":false,"message":"Users database not found"}'
    exit 0
fi

# Look for the user
USER_LINE=$(grep "^$USERNAME:" "$USERS_FILE")

if [ -n "$USER_LINE" ]; then
    # Extract security question (6th field)
    SECURITY_QUESTION=$(echo "$USER_LINE" | cut -d':' -f6)
    
    # Get readable question text
    case "$SECURITY_QUESTION" in
        mother_maiden) QUESTION_TEXT="What is your mother's maiden name?" ;;
        first_pet) QUESTION_TEXT="What was the name of your first pet?" ;;
        birth_city) QUESTION_TEXT="In which city were you born?" ;;
        school) QUESTION_TEXT="What was the name of your first school?" ;;
        favorite_color) QUESTION_TEXT="What is your favorite color?" ;;
        *) QUESTION_TEXT="Security question" ;;
    esac
    
    echo "{\"exists\":true,\"security_question\":\"$QUESTION_TEXT\"}"
else
    echo '{"exists":false,"message":"Username not found"}'
fi