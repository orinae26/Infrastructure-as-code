#!/bin/bash

# Update package index
apt-get update

# Install required packages for Docker
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add Docker repository
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package index again
apt-get update

# Install Docker
apt-get install -y docker-ce

# Start Docker service
systemctl start docker

# Enable Docker to start on boot
systemctl enable docker

# Verify Docker installation
docker --version