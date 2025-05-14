#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\check_user.sh

echo "Content-Type: text/plain"
echo ""

# Set up paths
USERS_FILE="../data/users.txt"

echo "CHECKING FOR USER: Amrit"
echo "======================="

# Ensure file exists
if [ ! -f "$USERS_FILE" ]; then
    echo "❌ ERROR: users.txt file does not exist!"
    exit 0
fi

# Show file size
echo "Users file size: $(wc -c < "$USERS_FILE" 2>/dev/null || echo "unknown") bytes"
echo "Users file contains $(wc -l < "$USERS_FILE" 2>/dev/null || echo "unknown") lines"

echo ""
echo "File content with line numbers:"
nl -ba "$USERS_FILE"

echo ""
echo "Searching for 'Amrit':"
grep "Amrit" "$USERS_FILE" || echo "❌ NOT FOUND: 'Amrit' does not exist in users.txt"

echo ""
echo "Trying case-insensitive search:"
grep -i "amrit" "$USERS_FILE" || echo "❌ NOT FOUND: No match even with case-insensitive search"

echo ""
echo "If the user is not found, add it manually with:"
echo "echo \"Amrit:Amrit@123:amrit@example.com:1234567890:2023-05-08\" >> ../data/users.txt"