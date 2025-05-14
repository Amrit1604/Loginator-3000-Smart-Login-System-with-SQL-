#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\get_submission_details.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123" 
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

# Get submission ID from query string
id=$(echo "$QUERY_STRING" | grep -oP 'id=\K[^&]+')

# Get submission details
result=$(mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
    SELECT 
        s.id, 
        s.task_id, 
        s.username, 
        s.content, 
        s.file_path, 
        s.submitted_at, 
        s.completed,
        s.feedback,
        a.work_description
    FROM 
        work_submissions s
    JOIN 
        work_assignments a ON s.task_id = a.id
    WHERE
        s.id = $id
    LIMIT 1" --batch --silent | sed 's/\t/","/g;s/^/["/;s/$/"],/;s/\n//g')

# Format as JSON, but return first object only
echo "[${result%,}]" | sed 's/^\[\[/[{/;s/\]\]$/}]/' | sed 's/\]\],/}],/g'