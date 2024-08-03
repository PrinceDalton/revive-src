#!/bin/bash

# Variables
DOCKER_USERNAME="prinsoo"

# Define an associative array for microservices with their corresponding Dockerfile paths
declare -A MICROSERVICES
MICROSERVICES=(
    ["revive-checkout"]="checkout/Dockerfile"
    ["revive-checkout-db"]="checkout/Dockerfile-db"
    ["revive-orders"]="orders/Dockerfile"
    ["revive-orders-db"]="orders/Dockerfile-db"
    ["revive-ui"]="ui/Dockerfile"
    ["revive-assets"]="assets/Dockerfile"
    ["revive-rabbitmq"]="ui/Dockerfile-rabbitmq"
    ["revive-cart"]="cart/Dockerfile"
    ["revive-cart-db"]="cart/Dockerfile-dynamodb"
    ["revive-catalog"]="catalog/Dockerfile"
    ["revive-catalog-db"]="catalog/Dockerfile-db"

    # Add more services with their Dockerfile paths here
)

TAG="v1"

# Function to log in to DockerHub
docker_login() {
    echo "Logging in to DockerHub..."
    docker login -u "$DOCKER_USERNAME"
    if [ $? -ne 0 ]; then
        echo "Docker login failed. Please check your credentials."
        exit 1
    fi
}

# Function to build and push each microservice
build_and_push_microservice() {
    local service_name=$1
    local dockerfile_path=$2
    
    # Extract the directory and the Dockerfile name from the path
    local service_dir=$(dirname "$dockerfile_path")
    local dockerfile_name=$(basename "$dockerfile_path")
    
    echo "Building Docker image for $service_name using $dockerfile_name..."
    docker build -t "$DOCKER_USERNAME/$service_name:$TAG" -f "$dockerfile_path" "$service_dir"
    if [ $? -ne 0 ]; then
        echo "Docker build failed for $service_name."
        exit 1
    fi

    echo "Pushing Docker image for $service_name to DockerHub..."
    docker push "$DOCKER_USERNAME/$service_name:$TAG"
    if [ $? -ne 0 ]; then
        echo "Docker push failed for $service_name."
        exit 1
    fi

    echo "Docker image for $service_name built and pushed successfully."
}

# Main script execution
docker_login

for service_name in "${!MICROSERVICES[@]}"; do
    build_and_push_microservice "$service_name" "${MICROSERVICES[$service_name]}"
done

echo "All microservices have been built and pushed successfully."