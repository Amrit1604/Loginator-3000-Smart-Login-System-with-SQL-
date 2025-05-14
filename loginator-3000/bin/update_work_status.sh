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
echo "UPDATE WORK STATUS ATTEMPT: $(date)" >> "$DEBUG_LOG"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "Raw POST data: $POST_DATA" >> "$DEBUG_LOG"
else
    POST_DATA=""
    echo "No POST data received" >> "$DEBUG_LOG"
fi

# Extract work ID and status
ID=$(echo "$POST_DATA" | grep -o 'id=[^&]*' | sed 's/id=//' | sed 's/+/ /g')
STATUS=$(echo "$POST_DATA" | grep -o 'status=[^&]*' | sed 's/status=//' | sed 's/+/ /g')

echo "Extracted ID: '$ID'" >> "$DEBUG_LOG"
echo "Extracted status: '$STATUS'" >> "$DEBUG_LOG"

# Input validation
if [ -z "$ID" ] || [ -z "$STATUS" ]; then
    echo "Missing ID or status" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"ID and status required."}'
    exit 0
fi

# Update work assignment status
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

if [ "$STATUS" == "completed" ]; then
    # Set completed flag and timestamp
    mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
    UPDATE work_assignments 
    SET completed = 1, completed_at = '$CURRENT_TIME'
    WHERE id = $ID;" 2>> "$DEBUG_LOG"
else
    # Reset completed flag and timestamp
    mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
    UPDATE work_assignments 
    SET completed = 0, completed_at = NULL
    WHERE id = $ID;" 2>> "$DEBUG_LOG"
fi

# Check if update was successful
DB_STATUS=$?
if [ $DB_STATUS -ne 0 ]; then
    echo "Database update failed with status: $DB_STATUS" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Failed to update work status."}'
    exit 0
fi

# Get affected rows
AFFECTED_ROWS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT ROW_COUNT();")
echo "Database rows affected: $AFFECTED_ROWS" >> "$DEBUG_LOG"

if [ "$AFFECTED_ROWS" -gt 0 ]; then
    echo "Work status updated successfully" >> "$DEBUG_LOG"
    echo '{"success":true,"message":"Work status updated successfully."}'
else
    echo "Work assignment not found" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Work assignment not found."}'
fi