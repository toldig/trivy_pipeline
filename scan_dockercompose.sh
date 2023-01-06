#!/bin/bash

# Start docker and wait 5 seconds 
dockerd &
sleep 5
# Update database
trivy image --download-db-only
# Build images and scan them with trivy
mkdir /tmp/trivy_scans
for image in $(yq e '.services' docker-compose.yml | grep -oP '\K^\w+'); do
    echo "Building image $image"
    docker compose build $image
    echo "Image build complete"
    docker tag $(docker images --quiet) $image
    echo "Running trivy scan for $image image"
    trivy image $image:latest --format template --template "@/html.tpl" -o /tmp/trivy_scans/$image.html
    echo "Remove image $image"
    docker rmi $(docker images --quiet) -f
done
# Create artifact
zip report.zip /tmp/trivy_scans/* -j
