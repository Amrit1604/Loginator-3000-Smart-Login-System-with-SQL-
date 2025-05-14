#!/bin/bash
# filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\install.sh

# Set color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== LinuxPro Authentication System Installer =====${NC}"
echo -e "${BLUE}Setting up directories and permissions...${NC}"

# Create necessary directories if they don't exist
mkdir -p data containers containers/basic containers/advanced containers/premium

# Create data files with proper permissions
touch data/users.txt data/pending.txt data/sessions.txt data/admin_sessions.txt
touch data/otps.txt data/failed_logins.txt data/logs.txt data/user_containers.txt

# Set proper permissions
chmod 700 data
chmod 600 data/*.txt

# Create admin account for first-time setup (if none exists)
if [ ! -s data/admin_sessions.txt ]; then
    echo -e "${GREEN}Creating default admin account...${NC}"
    echo "admin:admin@123" > data/admin.txt
    chmod 600 data/admin.txt
fi

# Make bin scripts executable
chmod 700 bin/*.sh

# Log installation
echo "$(date): System installed successfully" >> data/logs.txt

echo -e "${GREEN}===== Installation Complete =====${NC}"
echo -e "You can now access the system through your web browser."
echo -e "Default admin login: username=${BLUE}admin${NC} password=${BLUE}admin@123${NC}"
echo -e "IMPORTANT: Change the admin password after first login."

exit 0