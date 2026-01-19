#!/bin/bash
# Setup script to configure TamperMonkey scripts with values from .env

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

echo "TamperMonkey Scripts Configuration"
echo "==================================="
echo ""

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found at $ENV_FILE"
    echo ""
    echo "Please create a .env file from .env.example:"
    echo "  cp .env.example .env"
    echo "  # Then edit .env with your values"
    exit 1
fi

# Source .env file
set -a
source "$ENV_FILE"
set +a

# Check required variables
REQUIRED_VARS=("GITLAB_URL" "COMPANY_NAME" "AUTHOR_NAME" "STORAGE_KEY_PREFIX")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Missing required environment variables:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "Please set these in your .env file"
    exit 1
fi

# Sanitize values
GITLAB_URL=$(echo "$GITLAB_URL" | sed 's|^https\?://||' | sed 's|/$||')
COMPANY_NAME_LOWER=$(echo "$COMPANY_NAME" | tr '[:upper:]' '[:lower:]')
STORAGE_KEY_PREFIX_LOWER=$(echo "$STORAGE_KEY_PREFIX" | tr '[:upper:]' '[:lower:]')

echo "Configuration:"
echo "  GitLab URL: $GITLAB_URL"
echo "  Company Name: $COMPANY_NAME"
echo "  Author: $AUTHOR_NAME"
echo "  Storage Prefix: $STORAGE_KEY_PREFIX_LOWER"
echo ""

# Function to replace placeholders in a file
configure_script() {
    local template_file="$1"
    local output_file="$2"
    
    if [ ! -f "$template_file" ]; then
        echo "⚠️  Template not found: $template_file"
        return 1
    fi
    
    # Create backup if output file exists and is different from template
    if [ -f "$output_file" ] && ! cmp -s "$template_file" "$output_file"; then
        cp "$output_file" "$output_file.bak"
        echo "  Created backup: $output_file.bak"
    fi
    
    # Replace placeholders
    sed -e "s|{{GITLAB_URL}}|$GITLAB_URL|g" \
        -e "s|{{COMPANY_NAME}}|$COMPANY_NAME|g" \
        -e "s|{{COMPANY_NAME_LOWER}}|$COMPANY_NAME_LOWER|g" \
        -e "s|{{AUTHOR_NAME}}|$AUTHOR_NAME|g" \
        -e "s|{{STORAGE_KEY_PREFIX}}|$STORAGE_KEY_PREFIX_LOWER|g" \
        "$template_file" > "$output_file"
    
    echo "✅ Configured: $(basename "$output_file")"
}

# Configure each script
echo "Configuring scripts..."
echo ""

configure_script "$SCRIPT_DIR/GitLab-File-Tree.js.template" "$SCRIPT_DIR/GitLab-File-Tree.js"
configure_script "$SCRIPT_DIR/GitLab-Issue-MR.js.template" "$SCRIPT_DIR/GitLab-Issue-MR.js"
configure_script "$SCRIPT_DIR/ActiTime-AutoFill.js.template" "$SCRIPT_DIR/ActiTime-AutoFill.js"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open Tampermonkey dashboard in your browser"
echo "  2. Install each configured script from:"
echo "     - $SCRIPT_DIR/GitLab-File-Tree.js"
echo "     - $SCRIPT_DIR/GitLab-Issue-MR.js"
echo "     - $SCRIPT_DIR/ActiTime-AutoFill.js"
echo ""
echo "To reconfigure, run this script again after updating .env"
