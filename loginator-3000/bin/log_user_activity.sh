#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\log_user_activity.sh

# Usage: log_user_activity.sh username "Activity description" [silent]

USERNAME="$1"
ACTIVITY="$2"
SILENT="$3"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Path to user's activity log
LOGS_DIR="../data/logs"
USER_LOG="$LOGS_DIR/${USERNAME}_activity.log"

# Create logs directory if it doesn't exist
mkdir -p "$LOGS_DIR"

# Log the activity with timestamp
echo "[$TIMESTAMP] $ACTIVITY" >> "$USER_LOG"

# Only return headers if called directly via web and not in silent mode
if [ -z "$SILENT" ]; then
  echo "Content-Type: application/json"
  echo ""
  echo '{"success":true}'
fi