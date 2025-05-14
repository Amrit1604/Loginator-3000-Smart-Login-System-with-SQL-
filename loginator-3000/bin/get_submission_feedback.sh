#!/bin/bash

echo "Content-Type: application/json"
echo ""

# Get the submission ID from query string
QUERY_STRING="${QUERY_STRING:-}"
ID=$(echo "$QUERY_STRING" | grep -oP "id=\K[^&]+" | sed 's/%20/ /g')

# Path to the feedback file
SUBMISSIONS_DIR="../data/assignment_submissions"
FEEDBACK_FILE="${SUBMISSIONS_DIR}/.feedback/${ID}.feedback"

# Check if the feedback file exists
if [ -f "$FEEDBACK_FILE" ]; then
    # Read the feedback
    FEEDBACK=$(cat "$FEEDBACK_FILE" | sed 's/"/\\"/g')
    echo "{\"success\":true,\"feedback\":\"$FEEDBACK\"}"
else
    # No feedback found
    echo "{\"success\":true,\"feedback\":\"\"}"
fi
