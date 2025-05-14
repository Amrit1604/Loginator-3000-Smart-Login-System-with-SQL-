#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\get_users.sh

echo "Content-Type: application/json"
echo ""

# Set up data files
USERS_FILE="../data/users.txt"
ACTIVE_USERS="../data/active_users.txt"
LOGIN_LOGS="../data/user_logins.txt"

# Create files if they don't exist
mkdir -p ../data
touch "$USERS_FILE"
touch "$ACTIVE_USERS"
touch "$LOGIN_LOGS"

# Start JSON response
echo "["

# Process each user
FIRST=true
while IFS=: read -r username password email phone date; do
    # Skip empty lines
    if [ -z "$username" ]; then
        continue
    fi
    
    # Check if user is active
    ACTIVE="false"
    if grep -q "^$username:" "$ACTIVE_USERS"; then
        ACTIVE="true"
    fi
    
    # Get last login time
    LAST_LOGIN=""
    LAST_LOGIN=$(grep "User $username logged in" "$LOGIN_LOGS" | tail -1 | cut -d'|' -f1)
    
    # Add comma for all but first item
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo ","
    fi
    
    # Output user data as JSON
    echo "  {\"username\":\"$username\",\"email\":\"$email\",\"phone\":\"$phone\",\"date\":\"$date\",\"active\":$ACTIVE,\"last_login\":\"$LAST_LOGIN\"}"
    
done < "$USERS_FILE"

# End JSON array
echo "]"