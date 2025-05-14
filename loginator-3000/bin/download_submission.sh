#!/bin/bash

# Get query parameters
QUERY_STRING="${QUERY_STRING:-}"
FILE_PATH=$(echo "$QUERY_STRING" | grep -oP "file=\K[^&]+" | sed 's/%20/ /g')

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Content-Type: text/plain"
    echo "Status: 404 Not Found"
    echo ""
    echo "File not found"
    exit 1
fi

# Get file info
FILENAME=$(basename "$FILE_PATH")
MIME_TYPE=$(file -b --mime-type "$FILE_PATH")

# Set headers
echo "Content-Type: $MIME_TYPE"
echo "Content-Disposition: attachment; filename=\"$FILENAME\""
echo ""

# Output file content
cat "$FILE_PATH"
