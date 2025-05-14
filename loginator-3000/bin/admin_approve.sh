#!/bin/bash

echo "Content-type: text/html"
echo ""

DATA_DIR="../data"
PENDING_FILE="$DATA_DIR/pending.txt"
USER_FILE="$DATA_DIR/users.txt"
LOG_FILE="$DATA_DIR/logs.txt"
CONTAINER_DIR="../containers"

TMP_PENDING="$PENDING_FILE.tmp"

mkdir -p "$CONTAINER_DIR"

# Read form data
read -n "$CONTENT_LENGTH" POST_DATA

# URL decode
urldecode() { : "${1//+/ }"; echo -e "${_//%/\\x}"; }
declare -A decisions
IFS='&' read -ra pairs <<< "$POST_DATA"
for pair in "${pairs[@]}"; do
    key=$(echo "$pair" | cut -d= -f1)
    val=$(echo "$pair" | cut -d= -f2-)
    key=$(urldecode "$key")
    val=$(urldecode "$val")
    decisions["$key"]="$val"
done

echo "<h2>Admin Decision Summary:</h2>"

while IFS=: read -r username email phone hash; do
  decision_key="decision_$username"
  decision="${decisions[$decision_key]}"

  if [[ "$decision" == "approve" ]]; then
    echo "$username:$email:$phone:$hash" >> "$USER_FILE"
    mkdir -p "$CONTAINER_DIR/$username"
    chmod 700 "$CONTAINER_DIR/$username"

    echo "<p>✅ Approved: $username</p>"
    echo "$(date) | Approved user: $username" >> "$LOG_FILE"
  elif [[ "$decision" == "reject" ]]; then
    echo "<p>❌ Rejected: $username</p>"
    echo "$(date) | Rejected user: $username" >> "$LOG_FILE"
  else
    # Keep entry if no decision
    echo "$username:$email:$phone:$hash" >> "$TMP_PENDING"
  fi
done < "$PENDING_FILE"

# Replace pending with any unprocessed entries
mv "$TMP_PENDING" "$PENDING_FILE" 2>/dev/null

"$(dirname "$0")/update_export.sh" &> /dev/null &

echo "<br><a href='../admin.html'>← Back to Admin Panel</a>"




