#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\assign_work.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

# Read POST data
read -r POST_DATA

# Extract username and work description
username=$(echo "$POST_DATA" | grep -oP 'username=\K[^&]+')
work=$(echo "$POST_DATA" | grep -oP 'work=\K[^&]*')

# URL decode the parameters
username=$(echo -e "$(echo "$username" | sed 's/%/\\x/g')")
work=$(echo -e "$(echo "$work" | sed 's/%/\\x/g')")

# Log assignment 
echo "Assigning work to $username: $work" >> "$DEBUG_LOG"

# Get current date/time
assigned_at=$(date +"%Y-%m-%d %H:%M:%S")

# Connect to database and insert assignment
mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF
INSERT INTO work_assignments (username, work_description, assigned_at, completed) 
VALUES ('$username', '$work', '$assigned_at', 0);
EOF

# Check if MySQL command was successful
if [ $? -eq 0 ]; then
    echo '{"success": true, "message": "Work assigned successfully"}'
else
    echo '{"success": false, "message": "Database error occurred"}'
fi