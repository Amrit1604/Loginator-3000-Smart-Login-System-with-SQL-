#!/bin/bash

echo "Content-Type: application/json"
echo ""

# Database credentials
DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# Debug log
DEBUG_LOG="../data/debug.log"

echo "================================" >> "$DEBUG_LOG"
echo "DELETE WORK ASSIGNMENT ATTEMPT: $(date)" >> "$DEBUG_LOG"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "Raw POST data: $POST_DATA" >> "$DEBUG_LOG"
else
    POST_DATA=""
    echo "No POST data received" >> "$DEBUG_LOG"
fi

# Extract work ID
ID=$(echo "$POST_DATA" | grep -o 'id=[^&]*' | sed 's/id=//' | sed 's/+/ /g')

echo "Extracted ID: '$ID'" >> "$DEBUG_LOG"

# Input validation
if [ -z "$ID" ]; then
    echo "Missing ID" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Work assignment ID is required."}'
    exit 0
fi

# Delete work assignment
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
DELETE FROM work_assignments WHERE id = $ID;" 2>> "$DEBUG_LOG"

# Check if deletion was successful
DB_STATUS=$?
if [ $DB_STATUS -ne 0 ]; then
    echo "Database deletion failed with status: $DB_STATUS" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Failed to delete work assignment."}'
    exit 0
fi

# Get affected rows
AFFECTED_ROWS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT ROW_COUNT();")
echo "Database rows affected: $AFFECTED_ROWS" >> "$DEBUG_LOG"

if [ "$AFFECTED_ROWS" -gt 0 ]; then
    echo "Work assignment deleted successfully" >> "$DEBUG_LOG"
    echo '{"success":true,"message":"Work assignment deleted successfully."}'
else
    echo "Work assignment not found" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Work assignment not found."}'
fi