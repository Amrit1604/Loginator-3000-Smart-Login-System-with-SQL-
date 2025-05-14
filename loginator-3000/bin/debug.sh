#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\bin\debug.sh

echo "Content-Type: text/plain"
echo ""

echo "===== SYSTEM DEBUG OUTPUT ====="
echo "Date: $(date)"
echo "PHP Version: $(php -v | head -n 1)"
echo ""

echo "----- File Structure -----"
ls -la ../data/

echo ""
echo "----- users.txt Content -----"
cat ../data/users.txt

echo ""
echo "----- Last 20 lines of debug log -----"
tail -n 20 ../data/debug.log

echo ""
echo "----- Last login attempt -----"
grep -A 20 "LOGIN ATTEMPT" ../data/debug.log | tail -n 21

echo ""
echo "===== END OF DEBUG ====="