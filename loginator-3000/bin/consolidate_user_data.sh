#!/bin/bash

OUTPUT_FILE="../data/all_users.json"
USERS_DIR="../data"

echo "Consolidating all user data into $OUTPUT_FILE"

# Start the JSON structure
cat > "$OUTPUT_FILE" << EOL
{
  "export_date": "$(date '+%Y-%m-%d %H:%M:%S')",
  "all_users": [
EOL

# Add all registered users
FIRST=true
for USER_FILE in "$USERS_DIR"/users_*.json "$USERS_DIR"/user_export_*.json; do
    if [ -f "$USER_FILE" ]; then
        # Extract users from the file
        USERS=$(cat "$USER_FILE" | grep -o -P '"users":\s*\[\s*\{.*?\}\s*\]' | sed 's/"users":\s*\[//' | sed 's/\]\s*$//')
        
        if [ ! -z "$USERS" ]; then
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo "," >> "$OUTPUT_FILE"
            fi
            
            # Add the users to the output file
            echo "$USERS" >> "$OUTPUT_FILE"
        fi
    fi
done

# Close the JSON structure
cat >> "$OUTPUT_FILE" << EOL
  ],
  "export_timestamp": $(date +%s)
}
EOL

echo "Consolidation complete. Output saved to $OUTPUT_FILE"
