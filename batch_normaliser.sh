#!/bin/bash
# batch_normalizer.sh - Process sermon audio files
# Usage: ./batch_normalizer.sh [--normalize] [--add-music] [--generate-metadata]

# Load configuration
source ~/ChurchOps/config/settings.conf

# Default flags
DO_NORMALIZE=false
ADD_MUSIC=false
GENERATE_METADATA=false

# Parse arguments
for i in "$@"; do
  case $i in
    --normalize)
      DO_NORMALIZE=true
      shift
      ;;
    --add-music)
      ADD_MUSIC=true
      shift
      ;;
    --generate-metadata)
      GENERATE_METADATA=true
      shift
      ;;
    *)
      # unknown option
      ;;
  esac
done

# If no flags specified, enable all
if [[ "$DO_NORMALIZE" == "false" && "$ADD_MUSIC" == "false" && "$GENERATE_METADATA" == "false" ]]; then
  DO_NORMALIZE=true
  ADD_MUSIC=true
  GENERATE_METADATA=true
fi

# Set up logging
LOG_FILE=~/ChurchOps/logs/processing_$(date +"%Y%m%d_%H%M%S").log
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🎙️ Church Media Ops - Audio Processor"
echo "Started: $(date)"
echo "--------------------------------------"

# Check for files
SERMON_COUNT=$(find ~/ChurchOps/raw/audio -name "*.wav" | wc -l)

if [ $SERMON_COUNT -eq 0 ]; then
  echo "❌ No .wav files found in ~/ChurchOps/raw/audio"
  echo "Please add your sermon recordings and try again."
  exit 1
fi

echo "Found $SERMON_COUNT sermon files to process"

# Process each file
find ~/ChurchOps/raw/audio -name "*.wav" | while read file; do
  filename=$(basename "$file")
  basename="${filename%.*}"
  
  echo "Processing: $filename"
  
  # Normalize audio
  if [ "$DO_NORMALIZE" = true ]; then
    echo "  ↪ Normalizing audio..."
    ffmpeg -i "$file" -af "loudnorm=I=${NORMALIZE_LEVEL}:TP=${TARGET_PEAK}:LRA=11" \
      -ar 44100 ~/ChurchOps/processed/audio/"${basename}_normalized.wav" -y
  else
    cp "$file" ~/ChurchOps/processed/audio/"${basename}_normalized.wav"
  fi
  
  # Add background music
  if [ "$ADD_MUSIC" = true ]; then
    echo "  ↪ Adding background music..."
    
    # Check if background music exists
    if [ -f ~/ChurchOps/assets/music/background.mp3 ]; then
      ffmpeg -i ~/ChurchOps/processed/audio/"${basename}_normalized.wav" \
        -i ~/ChurchOps/assets/music/background.mp3 \
        -filter_complex "[1:a]volume=${MUSIC_VOLUME}[music];[0:a][music]amix=inputs=2:duration=longest" \
        ~/ChurchOps/processed/audio/"${basename}_final.wav" -y
    else
      echo "    ⚠️ No background music found. Skipping music addition."
      cp ~/ChurchOps/processed/audio/"${basename}_normalized.wav" \
         ~/ChurchOps/processed/audio/"${basename}_final.wav"
    fi
  else
    cp ~/ChurchOps/processed/audio/"${basename}_normalized.wav" \
       ~/ChurchOps/processed/audio/"${basename}_final.wav"
  fi
  
  # Export as MP3
  echo "  ↪ Exporting as MP3..."
  ffmpeg -i ~/ChurchOps/processed/audio/"${basename}_final.wav" \
    -codec:a libmp3lame -b:a ${OUTPUT_QUALITY} \
    ~/ChurchOps/processed/audio/"${basename}.mp3" -y
    
  # Generate metadata
  if [ "$GENERATE_METADATA" = true ]; then
    echo "  ↪ Generating metadata..."
    
    # Extract date from filename (assuming format: YYYY-MM-DD-SermonTitle.wav)
    DATE_PART=$(echo "$basename" | grep -oP '^\d{4}-\d{2}-\d{2}' || echo "")
    
    if [ -n "$DATE_PART" ]; then
      TITLE_PART=$(echo "$basename" | sed "s/$DATE_PART-//")
      FORMATTED_DATE=$(date -d "$DATE_PART" +"%B %d, %Y" 2>/dev/null || echo "")
      
      # Create metadata file
      cat > ~/ChurchOps/metadata/"${basename}.txt" << EOF
Title: ${TITLE_PART//-/ } - $MINISTRY_NAME - $FORMATTED_DATE
Description: Join us for "$MINISTRY_NAME" as we explore "${TITLE_PART//-/ }". 
This powerful message was recorded on $FORMATTED_DATE.

SUBSCRIBE for more inspiring messages!

Visit our website: https://yourchurch.org
Follow us on social media: @yourchurch

#Sermon #Faith #Church #$MINISTRY_NAME
EOF
      
      echo "    ✓ Metadata saved to ~/ChurchOps/metadata/${basename}.txt"
    else
      echo "    ⚠️ Could not extract date from filename. Using simplified metadata."
      
      # Create simplified metadata
      cat > ~/ChurchOps/metadata/"${basename}.txt" << EOF
Title: ${basename//-/ } - $MINISTRY_NAME
Description: Join us for "$MINISTRY_NAME" as we explore "${basename//-/ }".

SUBSCRIBE for more inspiring messages!

Visit our website: https://yourchurch.org
Follow us on social media: @yourchurch

#Sermon #Faith #Church #$MINISTRY_NAME
EOF
    fi
  fi
  
  # Create export copies
  echo "  ↪ Creating platform-specific exports..."
  cp ~/ChurchOps/processed/audio/"${basename}.mp3" ~/ChurchOps/export/youtube/
  cp ~/ChurchOps/processed/audio/"${basename}.mp3" ~/ChurchOps/export/podcast/
  cp ~/ChurchOps/processed/audio/"${basename}.mp3" ~/ChurchOps/export/radio/
  
  echo "  ✅ Completed processing: $filename"
  echo ""
done

echo "--------------------------------------"
echo "🎉 Processing complete!"
echo "Processed $SERMON_COUNT sermon files"
echo "Ended: $(date)"
echo ""
echo "📁 Your processed files are available at:"
echo "  - ~/ChurchOps/processed/audio/ (master files)"
echo "  - ~/ChurchOps/export/ (platform-specific files)"
echo ""
echo "📝 Metadata files are available at:"
echo "  - ~/ChurchOps/metadata/"