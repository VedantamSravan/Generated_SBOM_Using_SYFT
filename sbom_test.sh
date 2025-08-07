#!/bin/bash
directories=(
    "/usr/local/FM"
    "/usr/local/FN"
    "/usr/local/nc/bin"
    "/usr/local/bin"
    "/usr/local/mongo"
    "/etc/elasticsearch"
    "/etc/kibana"
)

# Get current datetime in YYYY-MM-DD_HH-MM-SS format
datetime=$(date +"%Y-%m-%d_%H-%M-%S")

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        filename="nextcomputing_${dirname}_${datetime}-sbom.spdx.json"
        go run ./cmd/syft "$dir" -o spdx-json="${filename}"
        echo "Generated SBOM for $dir -> $filename"
    else
        echo "Directory $dir does not exist, skipping..."
    fi
done
