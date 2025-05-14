#!/bin/bash

echo "Content-Type: application/json"
echo ""

# Database credentials
DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# File paths
DEBUG_LOG="../data/debug.log"
JSON_FILE="../data/user_export_20250512_131748.json"

# Ensure debug log directory exists
mkdir -p ../data

echo "================================" >> "$DEBUG_LOG"
echo "USER DELETION ATTEMPT: $(date)" >> "$DEBUG_LOG"

# Read POST data
if [ ! -z "$CONTENT_LENGTH" ]; then
    POST_DATA=$(cat)
    echo "Raw POST data: $POST_DATA" >> "$DEBUG_LOG"
else
    POST_DATA=""
    echo "No POST data received" >> "$DEBUG_LOG"
fi

# Extract username
USERNAME=$(echo "$POST_DATA" | grep -o 'username=[^&]*' | sed 's/username=//' | sed 's/+/ /g' | sed 's/%20/ /g')

echo "Extracted username: '$USERNAME'" >> "$DEBUG_LOG"

# Input validation
if [ -z "$USERNAME" ]; then
    echo "Missing username" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Username is required."}'
    exit 0
fi

# STEP 1: Delete from MySQL database first
echo "Attempting to delete user from database..." >> "$DEBUG_LOG"
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "DELETE FROM users WHERE username='$USERNAME';" 2>> "$DEBUG_LOG"

# Check if database deletion was successful
DB_STATUS=$?
if [ $DB_STATUS -ne 0 ]; then
    echo "Database deletion failed with status: $DB_STATUS" >> "$DEBUG_LOG"
    echo '{"success":false,"message":"Failed to delete user from database."}'
    exit 0
fi

# Get affected rows
AFFECTED_ROWS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -Nse "SELECT ROW_COUNT();")
echo "Database rows affected: $AFFECTED_ROWS" >> "$DEBUG_LOG"

# STEP 2: Delete from JSON file
echo "Attempting to delete user from JSON file..." >> "$DEBUG_LOG"
TMP_FILE=$(mktemp)

# Use jq to remove the user from the JSON file
if jq --arg un "$USERNAME" '.users = [.users[] | select(.username != $un)]' "$JSON_FILE" > "$TMP_FILE"; then
    # Count number of users before and after to determine if anyone was deleted
    USERS_BEFORE=$(jq '.users | length' "$JSON_FILE")
    USERS_AFTER=$(jq '.users | length' "$TMP_FILE")
    
    echo "JSON users before: $USERS_BEFORE, after: $USERS_AFTER" >> "$DEBUG_LOG"
    
    if [ "$USERS_BEFORE" -gt "$USERS_AFTER" ]; then
        # Move the temp file to replace the original
        mv "$TMP_FILE" "$JSON_FILE"
        echo "User '$USERNAME' deleted successfully from JSON file" >> "$DEBUG_LOG"
        echo '{"success":true,"message":"User deleted successfully from database and JSON file."}'
    else
        rm "$TMP_FILE"
        
        # If database deletion worked but JSON didn't find user, still consider it a success
        if [ "$AFFECTED_ROWS" -gt 0 ]; then
            echo "User deleted from database but not found in JSON file" >> "$DEBUG_LOG"
            echo '{"success":true,"message":"User deleted from database (not found in local cache)."}'
        else
            echo "User not found in database or JSON file" >> "$DEBUG_LOG"
            echo '{"success":false,"message":"User not found."}'
        fi
    fi
else
    rm "$TMP_FILE"
    
    # If database deletion worked but JSON processing failed
    if [ "$AFFECTED_ROWS" -gt 0 ]; then
        echo "User deleted from database but JSON processing failed" >> "$DEBUG_LOG"
        echo '{"success":true,"message":"User deleted from database (JSON update failed)."}'
    else
        echo "Error processing JSON file and no database rows affected" >> "$DEBUG_LOG"
        echo '{"success":false,"message":"User not found or error processing data."}'
    fi
fi