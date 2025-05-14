#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\update_work_status.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

# Read POST data
read -r POST_DATA

# Extract parameters
id=$(echo "$POST_DATA" | grep -oP 'id=\K[^&]+')
status=$(echo "$POST_DATA" | grep -oP 'status=\K[^&]+')
username=$(echo "$POST_DATA" | grep -oP 'username=\K[^&]+')

# URL decode parameters
id=$(echo -e "$(echo "$id" | sed 's/%/\\x/g')")
username=$(echo -e "$(echo "$username" | sed 's/%/\\x/g')")

# Determine status value
completed=0
if [ "$status" = "completed" ]; then
    completed=1
fi

echo "Updating task $id status to $completed for user $username" >> "$DEBUG_LOG"

# Update database
mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF
UPDATE work_assignments SET completed=$completed WHERE id=$id AND username='$username';
EOF

# Check if MySQL command was successful
if [ $? -eq 0 ]; then
    echo '{"success": true, "message": "Status updated successfully"}'
else
    echo '{"success": false, "message": "Database error occurred"}'
fi