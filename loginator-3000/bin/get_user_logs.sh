#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\get_user_logs.sh

# Set proper headers for JSON response
echo "Content-Type: application/json"
echo ""

# Path to user activity logs
LOGS_DIR="../data/logs"
USERS_FILE="../data/users.txt" 
ACTIVE_USERS="../data/active_users.txt"

# Create log directory if it doesn't exist
mkdir -p "$LOGS_DIR"

# Start JSON array
echo "["

# Flag to track first item (for comma handling)
FIRST=true

# Get all log files 
LOG_FILES=$(ls -1 "$LOGS_DIR"/*_activity.log 2>/dev/null)

if [ -z "$LOG_FILES" ]; then
    # No logs found, return empty array
    echo "]"
    exit 0
fi

# Process each log file
for LOG_FILE in $LOG_FILES; do
    # Extract username from filename
    USERNAME=$(basename "$LOG_FILE" | sed 's/_activity.log//')
    
    # Get user info if available
    if [ -f "$USERS_FILE" ]; then
        USER_INFO=$(grep "^$USERNAME:" "$USERS_FILE" 2>/dev/null)
        EMAIL=$(echo "$USER_INFO" | cut -d':' -f3 2>/dev/null)
    else
        EMAIL="$USERNAME@example.com"
    fi
    
    # If email is empty, set a default
    if [ -z "$EMAIL" ]; then
        EMAIL="$USERNAME@example.com"
    fi
    
    # Generate session ID if needed
    SESSION_ID="${USERNAME}_session_$(date +%s)"
    
    # Get last login time
    LAST_LOGIN=$(grep "logged in" "$LOG_FILE" | tail -1 | sed 's/\[//' | sed 's/\].*//' 2>/dev/null || echo "Unknown")
    
    # Simulate usage metrics
    CPU=$(( (RANDOM % 20) + 5 ))
    MEMORY=$(( (RANDOM % 300) + 100 ))
    
    # Get recent activities - escape quotes for JSON
    RECENT_ACTIVITIES=$(tail -10 "$LOG_FILE" | sed 's/"/\\"/g' | tr '\n' '|' | sed 's/|/\\n/g')
    
    # Add comma if not first entry
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo ","
    fi
    
    # Output user data in JSON format
    cat <<EOF
    {
        "username": "$USERNAME",
        "email": "$EMAIL",
        "lastLogin": "$LAST_LOGIN",
        "sessionId": "$SESSION_ID",
        "cpuUsage": $CPU,
        "memoryUsage": $MEMORY,
        "recentActivities": "$RECENT_ACTIVITIES"
    }
EOF
done

# End JSON array
echo "]"