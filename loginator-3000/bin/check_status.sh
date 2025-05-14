#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LOGIN\loginator-3000\bin\check_status.sh

echo "Content-Type: application/json"
echo ""

DB_USER="loginator"
DB_PASS="Yoyoyo@123"
DB_NAME="loginator3000"

# Check database connection - simplified version
DB_STATUS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -e "SELECT 1" 2>/dev/null && echo "ok" || echo "failed")

# Check filesystem - simplified with relative path
FS_STATUS=$([ -d "../data" ] && echo "ok" || echo "failed")

# Check if login script exists - simplified
LOGIN_STATUS=$([ -f "login.sh" ] && echo "ok" || echo "failed")

# Get server load 
LOAD=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo "N/A")

# Get disk space
DISK=$(df -h . 2>/dev/null | awk 'NR==2 {print $5}' || echo "N/A")

# Output JSON response
echo "{
  \"status\": {
    \"database\": \"${DB_STATUS}\",
    \"filesystem\": \"${FS_STATUS}\",
    \"login_system\": \"${LOGIN_STATUS}\",
    \"server_load\": \"${LOAD}\",
    \"disk_usage\": \"${DISK}\",
    \"timestamp\": $(date +%s)
  }
}"