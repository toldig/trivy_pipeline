#!/bin/bash

# Start docker and wait 5 seconds 
dockerd &
sleep 5
# Update database
trivy image --download-db-only
# Build image
echo "Building image"
docker build .
# Scan image
mkdir /tmp/trivy_scans
echo "Running trivy scan $image"
trivy image $(docker images --quiet) --format template --template "@/html.tpl" -o /tmp/trivy_scans/report.html
# Create artifact
zip report.zip /tmp/trivy_scans/* -j
