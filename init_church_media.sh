#!/bin/bash

# === CHURCH MEDIA OPS INITIALIZATION SCRIPT ===
# Enhanced setup with complete directory structure and configuration

set -euo pipefail

ROOT="$HOME/ChurchOps"
MINISTRY_NAME="Gospel Mission Team"
OUTPUT_QUALITY="320k"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ministry-name=*)
            MINISTRY_NAME="${1#*=}"
            shift
            ;;
        --output-quality=*)
            OUTPUT_QUALITY="${1#*=}"
            shift
            ;;
        --help)
            echo "Church Media Ops Initialization"
            echo "Usage: $0 [--ministry-name=NAME] [--output-quality=BITRATE]"
            echo "  --ministry-name=NAME     Set ministry name (default: Gospel Mission Team)"
            echo "  --output-quality=BITRATE Set audio quality (default: 320k)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🏗️  Setting up Church Media Ops workspace..."
echo "Location: $ROOT"
echo "Ministry: $MINISTRY_NAME"
echo "Quality: $OUTPUT_QUALITY"
echo ""

# Create complete directory structure
mkdir -p "$ROOT"/{raw/{audio,video},processed/{audio,video},assets/{intros,music,ambience,sfx},archive,export/{youtube,radio,podcast},scripts,config,logs,metadata,thumbnails}

# Create sample background music placeholder
cat > "$ROOT/assets/music/README.md" << 'EOF'
# Background Music Assets

Place your background music files here:
- `background.mp3` - Default background track for sermons
- `intro.mp3` - Intro music (optional)
- `outro.mp3` - Outro music (optional)

**Recommended formats:** MP3, WAV
**Licensing:** Ensure you have proper licensing for all music used
EOF

# Create sample assets
echo "🎵 Setting up sample assets..."

# Create .gitkeep files for empty directories
touch "$ROOT"/{raw/audio,raw/video,processed/audio,processed/video,archive,export/youtube,export/radio,export/podcast,logs,metadata,thumbnails}/.gitkeep

# Make scripts executable
chmod +x "$ROOT/scripts/batch_normalizer.sh" 2>/dev/null || true
chmod +x "$ROOT/church_media_ops.sh" 2>/dev/null || true

echo "✅ Directory structure created successfully!"
echo ""
echo "📂 Your workspace is ready:"
echo "  📁 $ROOT/raw/audio/        - Place your sermon recordings here (.wav files)"
echo "  📁 $ROOT/assets/music/     - Add background music files"
echo "  📁 $ROOT/processed/audio/  - Processed files will be saved here"
echo "  📁 $ROOT/export/           - Platform-specific exports"
echo "  📁 $ROOT/config/           - Configuration files"
echo ""
echo "🚀 Next steps:"
echo "  1. Add your sermon .wav files to: $ROOT/raw/audio/"
echo "  2. Add background music to: $ROOT/assets/music/background.mp3"
echo "  3. Run: cd $ROOT && ./church_media_ops.sh --all"
echo ""
echo "💡 For help: ./church_media_ops.sh --help"
echo ""
echo "🎉 Ready to process sermons! Go dominate."

