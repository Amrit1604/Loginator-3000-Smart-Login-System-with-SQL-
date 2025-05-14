#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\track_login.sh

# Create required database table first time
# CREATE TABLE login_history (
#   id INT AUTO_INCREMENT PRIMARY KEY,
#   username VARCHAR(50) NOT NULL,
#   ip_address VARCHAR(50),
#   user_agent TEXT,
#   login_time DATETIME DEFAULT CURRENT_TIMESTAMP
# );

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# First parameter should be username
USERNAME="$1"

# Second parameter is IP (or use REMOTE_ADDR)
IP_ADDRESS="${2:-$REMOTE_ADDR}"
if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS="Unknown"
fi

# Third parameter is user agent (or use HTTP_USER_AGENT)
USER_AGENT="${3:-$HTTP_USER_AGENT}"
if [ -z "$USER_AGENT" ]; then
    USER_AGENT="Unknown"
fi

# Record the login
mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "
INSERT INTO login_history (username, ip_address, user_agent, login_time)
VALUES ('$USERNAME', '$IP_ADDRESS', '$USER_AGENT', NOW());
" 2>/dev/null

# Return success - this won't show but ensures no errors
exit 0