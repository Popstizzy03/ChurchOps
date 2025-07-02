#!/bin/bash
INPUT_DIR=~/ChurchOps/raw/audio
OUTPUT_DIR=~/ChurchOps/processed/audio

for file in "$INPUT_DIR"/*.wav; do
  filename=$(basename "$file" .wav)
  ffmpeg -i "$file" -af "loudnorm" "$OUTPUT_DIR/${filename}_normalized.mp3"
done

echo "🎧 All audio normalized."

