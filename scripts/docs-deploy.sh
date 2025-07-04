#!/usr/bin/env bash
set -euo pipefail

# Deploy MkDocs documentation to AWS CloudFront
# This script assumes you have AWS CLI configured with appropriate credentials
# and that your Terraform infrastructure has been created in a separate project

cd "$(dirname "$0")/.."

# Configuration - these should be set via environment variables or command line args
BUCKET_NAME="${DOCS_S3_BUCKET:-}"
DISTRIBUTION_ID="${DOCS_CLOUDFRONT_DISTRIBUTION:-}"
AWS_PROFILE="${AWS_PROFILE:-default}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate requirements
if [[ -z "$BUCKET_NAME" ]]; then
    echo -e "${RED}Error: DOCS_S3_BUCKET environment variable is not set${NC}"
    echo "Please set the S3 bucket name created by your Terraform infrastructure"
    echo "Example: export DOCS_S3_BUCKET=my-docs-bucket"
    exit 1
fi

if [[ -z "$DISTRIBUTION_ID" ]]; then
    echo -e "${RED}Error: DOCS_CLOUDFRONT_DISTRIBUTION environment variable is not set${NC}"
    echo "Please set the CloudFront distribution ID created by your Terraform infrastructure"
    echo "Example: export DOCS_CLOUDFRONT_DISTRIBUTION=E1234567890ABC"
    exit 1
fi

# Check AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity --profile "$AWS_PROFILE" &> /dev/null; then
    echo -e "${RED}Error: AWS credentials are not configured or invalid${NC}"
    echo "Please configure AWS CLI with: aws configure --profile $AWS_PROFILE"
    exit 1
fi

# Build documentation
echo -e "${YELLOW}Building documentation...${NC}"
source .venv/bin/activate
mkdocs build --strict

# Sync to S3
echo -e "${YELLOW}Syncing documentation to S3...${NC}"
aws s3 sync ./site/ "s3://${BUCKET_NAME}/" \
    --delete \
    --profile "$AWS_PROFILE" \
    --cache-control "max-age=3600" \
    --exclude "*.map" \
    --exclude ".git/*"

# Set proper content types for specific files
echo -e "${YELLOW}Setting content types...${NC}"
aws s3 cp "s3://${BUCKET_NAME}/" "s3://${BUCKET_NAME}/" \
    --recursive \
    --profile "$AWS_PROFILE" \
    --metadata-directive REPLACE \
    --cache-control "max-age=3600" \
    --content-type "text/html" \
    --exclude "*" \
    --include "*.html"

aws s3 cp "s3://${BUCKET_NAME}/" "s3://${BUCKET_NAME}/" \
    --recursive \
    --profile "$AWS_PROFILE" \
    --metadata-directive REPLACE \
    --cache-control "max-age=31536000" \
    --content-type "text/css" \
    --exclude "*" \
    --include "*.css"

aws s3 cp "s3://${BUCKET_NAME}/" "s3://${BUCKET_NAME}/" \
    --recursive \
    --profile "$AWS_PROFILE" \
    --metadata-directive REPLACE \
    --cache-control "max-age=31536000" \
    --content-type "application/javascript" \
    --exclude "*" \
    --include "*.js"

# Invalidate CloudFront cache
echo -e "${YELLOW}Invalidating CloudFront cache...${NC}"
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$DISTRIBUTION_ID" \
    --paths "/*" \
    --profile "$AWS_PROFILE" \
    --query 'Invalidation.Id' \
    --output text)

echo -e "${GREEN}Deployment initiated!${NC}"
echo "Invalidation ID: $INVALIDATION_ID"
echo ""
echo "You can check the invalidation status with:"
echo "aws cloudfront get-invalidation --distribution-id $DISTRIBUTION_ID --id $INVALIDATION_ID --profile $AWS_PROFILE"
echo ""
echo -e "${GREEN}Documentation will be available at your CloudFront URL once the invalidation completes.${NC}"