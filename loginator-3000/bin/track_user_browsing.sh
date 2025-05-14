#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\track_user_browsing.sh

# Read the request headers
echo "Content-Type: application/json"
echo ""

# Parse post data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
else
    echo '{"success":false,"message":"No data received"}'
    exit 0
fi

# Extract username and URL
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')
URL=$(echo "$POST_DATA" | grep -o 'url=[^&]*' | sed 's/url=//' | sed 's/+/ /g')
ACTION=$(echo "$POST_DATA" | grep -o 'action=[^&]*' | sed 's/action=//' | sed 's/+/ /g')

# Default action if not provided
if [ -z "$ACTION" ]; then
    ACTION="visited webpage"
fi

# URL decode
URL=$(echo "$URL" | sed 's/%3A/:/g' | sed 's/%2F/\//g' | sed 's/%3F/?/g' | sed 's/%3D/=/g' | sed 's/%26/\&/g')

# Log the browsing activity
if [ -n "$USERNAME" ] && [ -n "$URL" ]; then
    # Use the generic activity logger with silent option
    ../bin/log_user_activity.sh "$USERNAME" "User $ACTION: $URL" "silent"
    echo '{"success":true}'
else
    echo '{"success":false,"message":"Missing username or URL"}'
fi