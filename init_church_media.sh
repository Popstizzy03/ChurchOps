#!/bin/bash
# init_church_media.sh - Initialize the Church Media Ops system
# Usage: ./init_church_media.sh [--ministry-name="Your Church"] [--output-quality=320k]

# Default values
MINISTRY_NAME="Church Media Ops"
OUTPUT_QUALITY="192k"

# Parse arguments
for i in "$@"; do
  case $i in
    --ministry-name=*)
      MINISTRY_NAME="${i#*=}"
      shift
      ;;
    --output-quality=*)
      OUTPUT_QUALITY="${i#*=}"
      shift
      ;;
    *)
      # unknown option
      ;;
  esac
done

echo "🙏 Initializing $MINISTRY_NAME Media Operations System..."

# Create directory structure
mkdir -p ~/ChurchOps/raw/audio
mkdir -p ~/ChurchOps/processed/audio
mkdir -p ~/ChurchOps/export/youtube
mkdir -p ~/ChurchOps/export/podcast
mkdir -p ~/ChurchOps/export/radio
mkdir -p ~/ChurchOps/assets/music
mkdir -p ~/ChurchOps/assets/thumbnails
mkdir -p ~/ChurchOps/assets/branding
mkdir -p ~/ChurchOps/metadata
mkdir -p ~/ChurchOps/scripts
mkdir -p ~/ChurchOps/config
mkdir -p ~/ChurchOps/logs

# Create configuration file
cat > ~/ChurchOps/config/settings.conf << EOF
# Church Media Ops Configuration
MINISTRY_NAME="$MINISTRY_NAME"
OUTPUT_QUALITY="$OUTPUT_QUALITY"
NORMALIZE_LEVEL="-16"
TARGET_PEAK="-1.5"
MUSIC_VOLUME="0.15"
GENERATE_THUMBNAILS=true
EOF

# Copy scripts
cp batch_normalizer.sh ~/ChurchOps/scripts/
cp metadata_generator.sh ~/ChurchOps/scripts/
cp platform_distributor.sh ~/ChurchOps/scripts/

# Make scripts executable
chmod +x ~/ChurchOps/scripts/*.sh

echo "✅ Setup complete! Your $MINISTRY_NAME Media Operations System is ready."
echo "📂 System installed at: ~/ChurchOps"
echo ""
echo "Next steps:"
echo "1. Place your sermon audio files in ~/ChurchOps/raw/audio"
echo "2. Add background music to ~/ChurchOps/assets/music"
echo "3. Run processing with: cd ~/ChurchOps/scripts && ./batch_normalizer.sh"