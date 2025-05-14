#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\get_all_users.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# Get all users from the database
RESULT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
SELECT 
    id, username, email, phone, 
    DATE_FORMAT(registration_date, '%Y-%m-%d %H:%i:%s') as date,
    active
FROM 
    users
ORDER BY
    username ASC;
" 2>/dev/null)

# Convert result to JSON
if [ -z "$RESULT" ]; then
    echo "[]"
    exit 0
fi

# Skip the header line and convert to JSON
JSON="["
FIRST=true
while IFS=$'\t' read -r id username email phone date active; do
    # Skip the header row
    if [ "$id" != "id" ]; then
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            JSON="$JSON,"
        fi
        
        # Convert active to boolean
        if [ "$active" = "1" ]; then
            active="true"
        else
            active="false"
        fi
        
        JSON="$JSON{\"id\":$id,\"username\":\"$username\",\"email\":\"$email\",\"phone\":\"$phone\",\"date\":\"$date\",\"active\":$active}"
    fi
done <<< "$RESULT"
JSON="$JSON]"

echo "$JSON"





# echo "Content-Type: application/json"
# echo ""

# # Set up paths
# USERS_FILE="../data/users.txt"
# ACTIVE_USERS="../data/active_users.txt"
# SESSIONS_DIR="../data/sessions"

# # Create files if they don't exist
# mkdir -p "$SESSIONS_DIR"
# touch "$USERS_FILE"
# touch "$ACTIVE_USERS"

# # Create a temporary file with the current time
# CURRENT_TIME=$(date +%s)
# touch "$ACTIVE_USERS.tmp"

# # Get list of active sessions by scanning sessions directory
# for session_file in "$SESSIONS_DIR"/*_session.txt; do
#     if [ -f "$session_file" ]; then
#         # Extract username from session file name
#         filename=$(basename "$session_file")
#         username="${filename%_session.txt}"
        
#         # Record as active
#         echo "$username:$CURRENT_TIME" >> "$ACTIVE_USERS.tmp"
#     fi
# done

# # Get any additional active users from active_users.txt
# while IFS=: read -r user timestamp; do
#     if [ ! -z "$user" ]; then
#         # Check if not already in temp file
#         if ! grep -q "^$user:" "$ACTIVE_USERS.tmp"; then
#             echo "$user:$timestamp" >> "$ACTIVE_USERS.tmp"
#         fi
#     fi
# done < "$ACTIVE_USERS"

# # Replace active users file with updated one
# mv "$ACTIVE_USERS.tmp" "$ACTIVE_USERS"

# # Start JSON array
# echo "["

# # Process all users
# FIRST=true
# while IFS=: read -r username password email phone date rest; do
#     # Skip empty lines
#     if [ -z "$username" ]; then
#         continue
#     fi
    
#     # Check if user is active
#     ACTIVE="false"
#     if grep -q "^$username:" "$ACTIVE_USERS"; then
#         ACTIVE="true"
#     fi
    
#     # Get container status (mock data for now)
#     CONTAINER="stopped"
#     if [ "$ACTIVE" = "true" ]; then
#         CONTAINER="running"
#     fi
    
#     # Add comma separator between items (except first)
#     if [ "$FIRST" = true ]; then
#         FIRST=false
#     else
#         echo ","
#     fi
    
#     # Output user as JSON object
#     echo "{\"username\":\"$username\",\"email\":\"$email\",\"phone\":\"$phone\",\"date\":\"$date\",\"active\":$ACTIVE,\"container\":\"$CONTAINER\"}"
    
# done < "$USERS_FILE"

# # End JSON array
# echo "]"