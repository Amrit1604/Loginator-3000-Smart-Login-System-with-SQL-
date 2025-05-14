#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\get_user_submissions.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

# Get username from query string
username=$(echo "$QUERY_STRING" | grep -oP 'username=\K[^&]+')

# URL decode the username
username=$(echo -e "$(echo "$username" | sed 's/%/\\x/g')")

echo "Fetching assignments for: $username" >> "$DEBUG_LOG"

# Get assignments from database for this user
result=$(mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
    SELECT id, work_description, assigned_at, completed 
    FROM work_assignments 
    WHERE username='$username'
    ORDER BY assigned_at DESC" --batch --silent | sed 's/\t/","/g;s/^/["/;s/$/"],/;s/\n//g')

# Format as JSON
echo "[$result]" | sed 's/],$/]/'