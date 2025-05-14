#!/bin/bash

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
DEBUG_LOG="../data/debug.log"

echo "================================" >> "$DEBUG_LOG"
echo "GET WORK ASSIGNMENTS: $(date)" >> "$DEBUG_LOG"

TABLE_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SHOW TABLES LIKE 'work_assignments'")
if [ -z "$TABLE_EXISTS" ]; then
    echo "Table does not exist" >> "$DEBUG_LOG"
    echo "[]"
    exit 0
fi

COUNT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT COUNT(*) FROM work_assignments")
if [ "$COUNT" -eq 0 ]; then
    echo "No assignments found in database" >> "$DEBUG_LOG"
    echo "[]"
    exit 0
fi

# Query and build JSON array
RESULT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse \
"SELECT 
    id, 
    username, 
    REPLACE(REPLACE(work_description, '\"', '\\\"'), '\n', ' ') as work_description, 
    DATE_FORMAT(assigned_at, '%Y-%m-%d %H:%i:%s') as assigned_at,
    completed,
    IFNULL(DATE_FORMAT(completed_at, '%Y-%m-%d %H:%i:%s'), 'NULL') as completed_at
FROM work_assignments 
ORDER BY assigned_at DESC;")

echo "["

first=1
while IFS=$'\t' read -r id username work_description assigned_at completed completed_at; do
    # Skip empty lines
    [ -z "$id" ] && continue

    # Handle NULL for completed_at
    if [ "$completed_at" = "NULL" ]; then
        completed_at_json="null"
    else
        completed_at_json="\"$completed_at\""
    fi

    # Add comma if not the first item
    if [ $first -eq 0 ]; then
        echo ","
    fi
    first=0

    # Output JSON object
    echo -n "{\"id\":$id,\"username\":\"$username\",\"work_description\":\"$work_description\",\"assigned_at\":\"$assigned_at\",\"completed\":$completed,\"completed_at\":$completed_at_json}"
done <<< "$RESULT"

echo "]"