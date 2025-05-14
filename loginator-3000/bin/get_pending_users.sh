#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\get_pending_users.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# Get all pending users from the database
RESULT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
SELECT 
    id, username, email, phone, DATE_FORMAT(registration_date, '%Y-%m-%d %H:%i:%s') as date
FROM 
    pending_users
ORDER BY
    registration_date DESC;
" 2>/dev/null)

# Convert result to JSON
if [ -z "$RESULT" ]; then
    echo "[]"
    exit 0
fi

# Skip the header line and convert to JSON
JSON="["
FIRST=true
while IFS=$'\t' read -r id username email phone date; do
    # Skip the header row
    if [ "$id" != "id" ]; then
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            JSON="$JSON,"
        fi
        JSON="$JSON{\"id\":$id,\"username\":\"$username\",\"email\":\"$email\",\"phone\":\"$phone\",\"date\":\"$date\"}"
    fi
done <<< "$RESULT"
JSON="$JSON]"

echo "$JSON"




# # Set content type for JSON response
# echo "Content-Type: application/json"
# echo ""

# # Path to pending users file
# PENDING_FILE="../data/pending.txt"

# # Initialize empty JSON array
# echo -n "["

# # Check if the file exists and is not empty
# if [ -f "$PENDING_FILE" ] && [ -s "$PENDING_FILE" ]; then
#     # Process the first line separately to handle JSON comma rules
#     FIRST_LINE=true
    
#     # Read each line from pending file
#     while IFS=: read -r username password email phone date; do
#         # If not the first line, add a comma separator
#         if [ "$FIRST_LINE" = "true" ]; then
#             FIRST_LINE=false
#         else
#             echo -n ","
#         fi
        
#         # Output JSON object with user details
#         echo -n "{\"username\":\"$username\",\"email\":\"$email\",\"phone\":\"$phone\",\"date\":\"$date\"}"
#     done < "$PENDING_FILE"
# fi

# # Close JSON array
# echo "]"
