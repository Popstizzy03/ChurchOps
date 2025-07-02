#!/bin/bash

# === CHURCH MEDIA OPS AUTOMATION ===
# Author: Rabboni + ChatGPT
# Purpose: Normalize sermon audio, apply background music, generate YouTube metadata
# Requirements: ffmpeg, bash, basic folder structure initialized with init_church_media.sh

# === CONFIG ===
INPUT_DIR=~/ChurchOps/raw/audio
OUTPUT_DIR=~/ChurchOps/processed/audio
EXPORT_DIR=~/ChurchOps/export/youtube
ASSETS_DIR=~/ChurchOps/assets/music
META_DIR=~/ChurchOps/metadata

BACKGROUND_TRACK="$ASSETS_DIR/background.mp3" # replace with actual file

mkdir -p "$META_DIR"

# === NORMALIZE + MIX AUDIO ===
echo "🎛️ Normalizing and mixing sermons..."

for file in "$INPUT_DIR"/*.wav; do
  [ -e "$file" ] || continue  # skip if no .wav files exist

  filename=$(basename "$file" .wav)
  normalized="$OUTPUT_DIR/${filename}_normalized.wav"
  mixed="$OUTPUT_DIR/${filename}_final.mp3"

  # Step 1: Normalize sermon audio
  ffmpeg -y -i "$file" -af "loudnorm" "$normalized"

  # Step 2: Mix with background music (ducking not implemented yet)
  ffmpeg -y -i "$normalized" -i "$BACKGROUND_TRACK" -filter_complex \
    "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=2" \
    -c:a libmp3lame -q:a 4 "$mixed"

  echo "✅ Processed: $filename"

  # Step 3: Generate metadata
  echo "📦 Generating metadata..."
  title="Sermon: ${filename//_/ }"
  desc="Listen to this inspiring sermon titled '$title'.\n\nStay connected:\nSubscribe, like, and share.\n#Gospel #Sermon #Faith"
  tags="Sermon, Faith, Gospel, Jesus, Church"

  echo -e "Title: $title\nDescription:\n$desc\nTags: $tags" > "$META_DIR/$filename.meta.txt"
  echo "📝 Metadata created: $filename.meta.txt"

done

echo "🚀 All sermons processed and metadata generated."

