#!/usr/bin/env bash
set -euo pipefail

# Initialize MkDocs documentation environment using uv

cd "$(dirname "$0")/.."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Initializing MkDocs documentation environment...${NC}"

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed"
    echo "Please install uv: https://github.com/astral-sh/uv"
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}Installing dependencies with uv...${NC}"
uv venv
uv pip install -r requirements-docs.txt

# Create .env.example for deployment configuration
cat > .env.example << 'EOF'
# AWS Configuration for documentation deployment
# Copy this to .env and fill in your values

# S3 bucket name created by Terraform
DOCS_S3_BUCKET=your-docs-bucket-name

# CloudFront distribution ID created by Terraform
DOCS_CLOUDFRONT_DISTRIBUTION=E1234567890ABC

# AWS Profile to use (optional, defaults to 'default')
AWS_PROFILE=default
EOF

echo -e "${GREEN}Documentation environment initialized!${NC}"
echo ""
echo "Next steps:"
echo "1. To serve docs locally: ./scripts/docs-serve.sh"
echo "2. To build docs: ./scripts/docs-build.sh"
echo "3. To deploy to AWS:"
echo "   a. Copy .env.example to .env and fill in your AWS infrastructure details"
echo "   b. Run: ./scripts/docs-deploy.sh"