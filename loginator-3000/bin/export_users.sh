#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\export_users.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
EXPORT_FILE="../data/user_export_$(date +%Y%m%d_%H%M%S).json"

# Ensure data directory exists
mkdir -p ../data

# Export active users
USERS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
SELECT 
    id, username, password, email, phone, 
    DATE_FORMAT(registration_date, '%Y-%m-%d %H:%i:%s') as registration_date,
    security_question, security_answer, active
FROM 
    users
ORDER BY
    id ASC;
" 2>/dev/null)

# Export pending users
PENDING=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
SELECT 
    id, username, password, email, phone, 
    DATE_FORMAT(registration_date, '%Y-%m-%d %H:%i:%s') as registration_date,
    security_question, security_answer
FROM 
    pending_users
ORDER BY
    id ASC;
" 2>/dev/null)

# Start JSON object
echo "{" > "$EXPORT_FILE"
echo "  \"export_date\": \"$(date +"%Y-%m-%d %H:%M:%S")\"," >> "$EXPORT_FILE"

# Process approved users
echo "  \"users\": [" >> "$EXPORT_FILE"
FIRST=true
while IFS=$'\t' read -r id username password email phone reg_date sec_question sec_answer active; do
    # Skip the header row
    if [ "$id" != "id" ]; then
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo "    }," >> "$EXPORT_FILE"
        fi
        echo "    {" >> "$EXPORT_FILE"
        echo "      \"id\": $id," >> "$EXPORT_FILE"
        echo "      \"username\": \"$username\"," >> "$EXPORT_FILE"
        echo "      \"password\": \"$password\"," >> "$EXPORT_FILE"
        echo "      \"email\": \"$email\"," >> "$EXPORT_FILE"
        echo "      \"phone\": \"$phone\"," >> "$EXPORT_FILE"
        echo "      \"registration_date\": \"$reg_date\"," >> "$EXPORT_FILE"
        echo "      \"security_question\": \"$sec_question\"," >> "$EXPORT_FILE"
        echo "      \"security_answer\": \"$sec_answer\"," >> "$EXPORT_FILE"
        echo "      \"active\": \"$active\"" >> "$EXPORT_FILE"
    fi
done <<< "$USERS"

# Close the last user entry if there was at least one
if [ "$FIRST" = false ]; then
    echo "    }" >> "$EXPORT_FILE"
fi
echo "  ]," >> "$EXPORT_FILE"

# Process pending users
echo "  \"pending_users\": [" >> "$EXPORT_FILE"
FIRST=true
while IFS=$'\t' read -r id username password email phone reg_date sec_question sec_answer; do
    # Skip the header row
    if [ "$id" != "id" ]; then
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo "    }," >> "$EXPORT_FILE"
        fi
        echo "    {" >> "$EXPORT_FILE"
        echo "      \"id\": $id," >> "$EXPORT_FILE"
        echo "      \"username\": \"$username\"," >> "$EXPORT_FILE"
        echo "      \"password\": \"$password\"," >> "$EXPORT_FILE"
        echo "      \"email\": \"$email\"," >> "$EXPORT_FILE"
        echo "      \"phone\": \"$phone\"," >> "$EXPORT_FILE"
        echo "      \"registration_date\": \"$reg_date\"," >> "$EXPORT_FILE"
        echo "      \"security_question\": \"$sec_question\"," >> "$EXPORT_FILE"
        echo "      \"security_answer\": \"$sec_answer\"" >> "$EXPORT_FILE"
    fi
done <<< "$PENDING"

# Close the last pending entry if there was at least one
if [ "$FIRST" = false ]; then
    echo "    }" >> "$EXPORT_FILE"
fi
echo "  ]" >> "$EXPORT_FILE"

# Close the JSON object
echo "}" >> "$EXPORT_FILE"

# Set secure permissions on the file
chmod 600 "$EXPORT_FILE"

# Return success message with file path
echo "{\"success\":true,\"message\":\"User data exported to $EXPORT_FILE\",\"file\":\"$EXPORT_FILE\"}"