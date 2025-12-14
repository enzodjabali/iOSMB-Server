#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Prompt for version
read -p "Enter version number (e.g., 0.1.0): " NEW_VERSION

# Validate version format (basic check for x.y.z format)
if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Please use x.y.z format (e.g., 0.6.6)${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Setting version to: ${NEW_VERSION}${NC}"
echo ""

# Array to track updated files
UPDATED_FILES=()

# Find and update all control files
CONTROL_FILES=(
    "iOSMB-Server/Package/DEBIAN/control"
    "libiosmb/control"
)

for FILE in "${CONTROL_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        # Check if file contains a Version line
        if grep -q "^Version:" "$FILE"; then
            # Get current version
            CURRENT_VERSION=$(grep "^Version:" "$FILE" | awk '{print $2}')
            
            # Update the version
            sed -i "s/^Version:.*/Version: $NEW_VERSION/" "$FILE"
            
            echo -e "${GREEN}✓${NC} Updated $FILE"
            echo -e "  ${CURRENT_VERSION} → ${NEW_VERSION}"
            UPDATED_FILES+=("$FILE")
        else
            echo -e "${YELLOW}⚠${NC} Skipped $FILE (no Version field found)"
        fi
    else
        echo -e "${RED}✗${NC} File not found: $FILE"
    fi
done

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}Version update complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Updated ${#UPDATED_FILES[@]} file(s) to version ${NEW_VERSION}"
echo ""
echo "Files updated:"
for FILE in "${UPDATED_FILES[@]}"; do
    echo "  • $FILE"
done
echo ""
echo -e "${YELLOW}Run ./build-docker.sh to build the package with the new version${NC}"
