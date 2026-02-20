#!/bin/bash

# Temporal UI Server Docker Build and Push to ECR Script
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="ap-southeast-1"
ECR_REPOSITORY="temporalio-ui"

IMAGE_VERSION="${1:-v2.34.3}"
ECR_BASE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

echo "🔐 Logging into AWS ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "🏗️  Building and pushing multi-architecture Temporal UI Server image (${IMAGE_VERSION})..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ${ECR_BASE}:${IMAGE_VERSION} \
  --tag ${ECR_BASE}:latest \
  --push \
  -f "${SCRIPT_DIR}/Dockerfile" \
  "${SCRIPT_DIR}/"

echo "✅ Successfully built and pushed:"
echo "   ${ECR_BASE}:${IMAGE_VERSION}"
echo "   ${ECR_BASE}:latest"
