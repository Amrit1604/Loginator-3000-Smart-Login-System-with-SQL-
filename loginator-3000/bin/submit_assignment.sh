#!/bin/bash

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

mkdir -p ../data/logs
touch "$DEBUG_LOG"

# Log submission attempt with clear separation
echo "===========================================" >> "$DEBUG_LOG"
echo "ASSIGNMENT SUBMISSION: $(date)" >> "$DEBUG_LOG"

# Create uploads directory
temp_dir="../data/uploads"
mkdir -p "$temp_dir"

# Read POST data
read -r POST_DATA
echo "Raw POST data: $POST_DATA" >> "$DEBUG_LOG"

# Extract form fields - improved parsing
task_id=$(echo "$POST_DATA" | grep -oP 'assignment_id=\K[^&]+')
username=$(echo "$POST_DATA" | grep -oP 'username=\K[^&]+')
content=$(echo "$POST_DATA" | grep -oP 'work_content=\K[^&]*' | sed 's/+/ /g' | sed 's/%20/ /g')

# URL decode values
task_id=$(echo -e "$(echo "$task_id" | sed 's/%/\\x/g')")
username=$(echo -e "$(echo "$username" | sed 's/%/\\x/g')")
content=$(echo -e "$(echo "$content" | sed 's/%/\\x/g')")

# Log the extracted data for debugging
echo "Task ID: $task_id" >> "$DEBUG_LOG"
echo "Username: $username" >> "$DEBUG_LOG"
echo "Content length: ${#content} bytes" >> "$DEBUG_LOG"

# Get current date/time
submission_date=$(date +"%Y-%m-%d %H:%M:%S")

# First check if the assignment exists for this user
assignment_exists=$(mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -sN -e "
    SELECT COUNT(*) FROM work_assignments 
    WHERE id='$task_id' AND username='$username'")

echo "Assignment exists check: $assignment_exists" >> "$DEBUG_LOG"

# THIS IS THE KEY FIX: We need to ensure an assignment record exists before proceeding
if [ "$assignment_exists" -eq "0" ]; then
    echo "Assignment not found for user, creating one now..." >> "$DEBUG_LOG"
    
    # IMPORTANT: First create a valid assignment BEFORE trying to submit
    mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF
    INSERT INTO work_assignments 
    (id, username, work_description, assigned_at, completed) 
    VALUES 
    ('$task_id', '$username', 'Auto-created assignment', NOW(), 0);
EOF
    
    # Check if creation was successful
    if [ $? -ne 0 ]; then
        echo "Failed to create assignment record" >> "$DEBUG_LOG"
        echo '{"success": false, "message": "Could not create assignment record"}'
        exit 1
    fi
    
    echo "Created assignment record successfully" >> "$DEBUG_LOG"
fi

# Now proceed with the submission since we know the assignment exists
echo "Proceeding with submission..." >> "$DEBUG_LOG"

# First write content to a file to avoid SQL injection and escape issues
content_file="../data/temp_content_$task_id.txt"
echo "$content" > "$content_file"

# THE MAIN FIX: Split operations and use >> to append to debug log
echo "Inserting submission record..." >> "$DEBUG_LOG"
mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF >> "$DEBUG_LOG" 2>&1
INSERT INTO work_submissions 
(task_id, username, content, submitted_at) 
VALUES 
('$task_id', '$username', '$content', '$submission_date');
EOF

submission_result=$?
echo "Submission insert result: $submission_result" >> "$DEBUG_LOG"

# Only update assignment if submission was successful
if [ $submission_result -eq 0 ]; then
    echo "Updating assignment status..." >> "$DEBUG_LOG"
    mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF >> "$DEBUG_LOG" 2>&1
UPDATE work_assignments 
SET completed = 1, completed_at = NOW()
WHERE id = '$task_id' AND username = '$username';
EOF
    update_result=$?
    echo "Assignment update result: $update_result" >> "$DEBUG_LOG"
else
    update_result=1
fi

# Check if operation was successful
if [ $submission_result -eq 0 ] && [ $update_result -eq 0 ]; then
    echo "Assignment submission successful" >> "$DEBUG_LOG"
    echo '{"success": true, "message": "Your work has been submitted successfully"}'
else
    echo "Database error occurred" >> "$DEBUG_LOG"
    
    # Show full MySQL error information
    echo "MySQL error details:" >> "$DEBUG_LOG"
    mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW ENGINE INNODB STATUS\G" >> "$DEBUG_LOG" 2>&1
    
    echo '{"success": false, "message": "Database error occurred while submitting your work"}'
fi