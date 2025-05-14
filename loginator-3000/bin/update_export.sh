#!/bin/bash

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"
EXPORT_FILE="../data/user_export_latest.json"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DATED_EXPORT_FILE="../data/user_export_${TIMESTAMP}.json"

# Create JSON export
echo "{" > "$EXPORT_FILE"
echo "  \"export_date\": \"$(date +'%Y-%m-%d %H:%M:%S')\","  >> "$EXPORT_FILE"

# Export active users
echo "  \"users\": [" >> "$EXPORT_FILE"
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "SELECT * FROM users WHERE active=1" --batch --skip-column-names | \
while IFS=$'\t' read -r id username password email phone reg_date security_question security_answer active; do
  echo "    {" >> "$EXPORT_FILE"
  echo "      \"id\": $id," >> "$EXPORT_FILE"
  echo "      \"username\": \"$username\"," >> "$EXPORT_FILE"
  echo "      \"password\": \"$password\"," >> "$EXPORT_FILE"
  echo "      \"email\": \"$email\"," >> "$EXPORT_FILE"
  echo "      \"phone\": \"$phone\"," >> "$EXPORT_FILE"
  echo "      \"registration_date\": \"$reg_date\"," >> "$EXPORT_FILE"
  echo "      \"security_question\": \"$security_question\"," >> "$EXPORT_FILE"
  echo "      \"security_answer\": \"$security_answer\"," >> "$EXPORT_FILE"
  echo "      \"active\": \"$active\"" >> "$EXPORT_FILE"
  echo "    }," >> "$EXPORT_FILE"
done
# Remove trailing comma if there are users
sed -i '$s/,$//' "$EXPORT_FILE"
echo "  ]," >> "$EXPORT_FILE"

# Export pending users
echo "  \"pending_users\": [" >> "$EXPORT_FILE"
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "SELECT * FROM pending_users" --batch --skip-column-names | \
while IFS=$'\t' read -r id username password email phone reg_date security_question security_answer; do
  echo "    {" >> "$EXPORT_FILE"
  echo "      \"id\": $id," >> "$EXPORT_FILE"
  echo "      \"username\": \"$username\"," >> "$EXPORT_FILE"
  echo "      \"password\": \"$password\"," >> "$EXPORT_FILE"
  echo "      \"email\": \"$email\"," >> "$EXPORT_FILE"
  echo "      \"phone\": \"$phone\"," >> "$EXPORT_FILE"
  echo "      \"registration_date\": \"$reg_date\"," >> "$EXPORT_FILE"
  echo "      \"security_question\": \"$security_question\"," >> "$EXPORT_FILE"
  echo "      \"security_answer\": \"$security_answer\"" >> "$EXPORT_FILE"
  echo "    }," >> "$EXPORT_FILE"
done
# Remove trailing comma if there are pending users
sed -i '$s/,$//' "$EXPORT_FILE"
echo "  ]" >> "$EXPORT_FILE"

echo "}" >> "$EXPORT_FILE"

# Also create a timestamped copy
cp "$EXPORT_FILE" "$DATED_EXPORT_FILE"

exit 0