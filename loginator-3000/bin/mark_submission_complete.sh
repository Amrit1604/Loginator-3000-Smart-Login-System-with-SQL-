#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\mark_submission_complete.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123" 
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

# Read POST data
read -r POST_DATA

# Extract submission ID
id=$(echo "$POST_DATA" | grep -oP 'id=\K[^&]+')

# Update submission status
mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF
UPDATE work_submissions SET completed = 1 WHERE id = $id;
EOF

# Check if MySQL command was successful
if [ $? -eq 0 ]; then
    echo '{"success": true, "message": "Submission marked as complete"}'
else
    echo '{"success": false, "message": "Database error occurred"}'
fi