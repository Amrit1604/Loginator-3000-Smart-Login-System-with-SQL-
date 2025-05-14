#!/bin/bash

read -r QUERY_STRING
username=$(echo "$QUERY_STRING" | grep -oP 'username=\K[^&]*' | sed 's/%20/ /g')
code=$(echo "$QUERY_STRING" | grep -oP 'code=\K[^&]*')

codefile="/tmp/2fa_${username}"

if [ -f "$codefile" ]; then
    stored_code=$(cat "$codefile")
    if [ "$code" = "$stored_code" ]; then
        rm -f "$codefile"
        echo 'Content-Type: application/json'
        echo
        echo '{"success": true, "redirect": "dashboard.html"}'
        exit 0
    fi
fi

echo 'Content-Type: application/json'
echo
echo '{"success": false, "message": "Invalid or expired code."}'