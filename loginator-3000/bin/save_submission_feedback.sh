#!/bin/bash

echo "Content-Type: application/json"
echo ""

# Parse POST data
if [ "$REQUEST_METHOD" = "POST" ]; then
    read -n $CONTENT_LENGTH POST_DATA
    ID=$(echo "$POST_DATA" | grep -oP "id=\K[^&]+")
    FEEDBACK=$(echo "$POST_DATA" | grep -oP "feedback=\K[^&]+" | sed 's/+/ /g' | sed 's/%20/ /g')
    
    # Get the username and submission filename from ID
    # Format is usually: ASSIGNMENT_ID_TIMESTAMP.txt
    SUBMISSION_FILE=$(echo "$ID" | sed 's/%20/ /g')
    
    # Find the file in the submissions directory
    SUBMISSIONS_DIR="../data/assignment_submissions"
    FEEDBACK_FILE="${SUBMISSIONS_DIR}/.feedback/${SUBMISSION_FILE}.feedback"
    
    # Create the feedback directory if it doesn't exist
    mkdir -p "${SUBMISSIONS_DIR}/.feedback"
    
    # Save the feedback to file
    echo "$FEEDBACK" > "$FEEDBACK_FILE"
    
    # Check if saving was successful
    if [ $? -eq 0 ]; then
        echo "{\"success\":true,\"message\":\"Feedback saved successfully for submission $ID\"}"
    else
        echo "{\"success\":false,\"message\":\"Failed to save feedback\"}"
    fi
else
    echo "{\"success\":false,\"message\":\"Invalid request method\"}"
fi
