#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\get_all_submissions.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123" 
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

# Get all work submissions with assignment details
result=$(mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
    SELECT 
        s.id, 
        s.task_id, 
        s.username, 
        s.content, 
        s.file_path, 
        s.submitted_at, 
        s.completed,
        a.work_description
    FROM 
        work_submissions s
    JOIN 
        work_assignments a ON s.task_id = a.id
    ORDER BY 
        s.submitted_at DESC" --batch --silent | sed 's/\t/","/g;s/^/["/;s/$/"],/;s/\n//g')

# Format as JSON
echo "[$result]" | sed 's/],$/]/'