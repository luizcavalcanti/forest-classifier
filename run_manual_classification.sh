#!/bin/bash
set -euo pipefail

ORIGINAL_IMAGES=database/ptv-mao
SAMPLES_PATH=tmp
CSV_PATH=segments.csv

if [ ! -d "$SAMPLES_PATH" ]; then
    echo "Samples directory not found. Please execute dataset preparation script first."
    exit 1
fi

# Utility to label samples
python preparation/label_samples.py "$ORIGINAL_IMAGES" "$SAMPLES_PATH" "$CSV_PATH"

# Remove samples path
echo "Removing samples dir..."
rm -rf "$SAMPLES_PATH"
