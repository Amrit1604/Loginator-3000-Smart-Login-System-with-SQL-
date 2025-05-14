#!/bin/bash

echo "Content-type: text/html"
echo ""

DATA_DIR="../data"
TOKEN_FILE="$DATA_DIR/reset_tokens.txt"
SESSION_FILE="$DATA_DIR/sessions.txt"
LOG_FILE="$DATA_DIR/logs.txt"

read -n "$CONTENT_LENGTH" POST_DATA

# URL decode
urldecode() { : "${1//+/ }"; echo -e "${_//%/\\x}"; }
declare -A form
IFS='&' read -ra pairs <<< "$POST_DATA"
for pair in "${pairs[@]}"; do
    key=$(echo "$pair" | cut -d= -f1)
    val=$(echo "$pair" | cut -d= -f2-)
    key=$(urldecode "$key")
    val=$(urldecode "$val")
    form["$key"]="$val"
done

username="${form[username]}"
otp_input="${form[otp]}"

# Verify OTP
found=0
now=$(date +%s)

# Read line by line
while IFS=: read -r user saved_otp expiry; do
    if [[ "$user" == "$username" && "$otp_input" == "$saved_otp" && "$now" -lt "$expiry" ]]; then
        found=1
        break
    fi
done < "$TOKEN_FILE"

if [[ "$found" == 1 ]]; then
    # Generate session token
    token=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
    expire=$(date -d "+30 minutes" +%s)
    echo "$username:$token:$expire" >> "$SESSION_FILE"
    echo "$(date) | OTP verified for $username, session started" >> "$LOG_FILE"

    # Redirect
    echo "<meta http-equiv='refresh' content='0; url=../dashboard.html?token=$token&user=$username'>"
else
    echo "<h3>❌ Invalid or expired OTP.</h3>"
    echo "<a href='../index.html'>← Try Again</a>"
    echo "$(date) | OTP failed for $username" >> "$LOG_FILE"
fi
