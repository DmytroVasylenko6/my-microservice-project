#!/bin/bash

# Script to build and push Django Docker image to ECR
# Usage: ./push_image_to_ecr.sh [tag]

set -e

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Default tag
TAG=${1:-latest}

# Get ECR repository URL from Terraform output
echo "Getting ECR repository URL from Terraform..."
cd "$SCRIPT_DIR"
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")

if [ -z "$ECR_URL" ]; then
    echo "Error: Could not get ECR repository URL. Make sure Terraform has been applied."
    echo "Run: terraform apply"
    exit 1
fi

echo "ECR Repository URL: $ECR_URL"

# Get AWS region from Terraform output (default to us-east-1)
REGION=$(terraform output -raw region 2>/dev/null || echo "us-east-1")

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_URL"

# Build Docker image
echo "Building Docker image..."
cd "$PROJECT_ROOT/web"
docker build -t django-app:"$TAG" .

# Tag image for ECR
echo "Tagging image for ECR..."
docker tag django-app:"$TAG" "$ECR_URL:$TAG"

# Push image to ECR
echo "Pushing image to ECR..."
docker push "$ECR_URL:$TAG"

echo "Successfully pushed django-app:$TAG to $ECR_URL:$TAG"

