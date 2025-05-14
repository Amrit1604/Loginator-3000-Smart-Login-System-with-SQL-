#!/bin/bash

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(dd bs=1 count=$CONTENT_LENGTH 2>/dev/null)
else
    POST_DATA=""
fi

# Extract username from POST
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')

# Make sure user_assignments table exists
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
CREATE TABLE IF NOT EXISTS user_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    assignment TEXT NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending'
);"

# Fetch assignments for the user
ASSIGNMENTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
    SELECT id, assignment, assigned_date, status 
    FROM user_assignments 
    WHERE username='$USERNAME'
    ORDER BY assigned_date DESC;" --batch --skip-column-names)

# Output JSON response
echo "{"
echo "  \"success\": true,"
echo "  \"assignments\": ["

# Format assignments as JSON
FIRST=true
echo "$ASSIGNMENTS" | while IFS=$'\t' read -r id assignment date status; do
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo ","
    fi
    
    echo "    {"
    echo "      \"id\": \"$id\","
    echo "      \"text\": \"$assignment\","
    echo "      \"date\": \"$date\","
    echo "      \"status\": \"$status\""
    echo -n "    }"
done

echo ""
echo "  ]"
echo "}"