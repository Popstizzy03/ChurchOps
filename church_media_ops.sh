#!/bin/bash

# === CHURCH MEDIA OPS - COMPREHENSIVE AUTOMATION SYSTEM ===
# Author: Rabboni Kabongo
# Purpose: Professional audio processing pipeline for sermons
# Features: Normalization, music mixing, metadata generation, parallel processing
# Requirements: ffmpeg, bash 4.0+

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# === CONFIGURATION ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/settings.conf"

# Load configuration with error handling
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    echo "Please run ./init_church_media.sh first"
    exit 1
fi

source "$CONFIG_FILE"

# === COMMAND LINE ARGUMENTS ===
NORMALIZE=false
ADD_MUSIC=false
GENERATE_METADATA=false
FORCE_OVERWRITE=false
VERBOSE=false

show_help() {
    cat << EOF
Church Media Ops - Professional Sermon Audio Processing

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --normalize         Apply audio normalization (EBU R128)
    --add-music         Mix background music with sermon
    --generate-metadata Create platform-specific metadata
    --force             Overwrite existing processed files
    --verbose           Enable detailed logging
    --all               Enable all processing features
    --help              Show this help message

EXAMPLES:
    $0 --all                    # Process with all features
    $0 --normalize --add-music  # Normalize and add music only
    $0 --force --verbose        # Reprocess files with detailed output

CONFIG FILE: $CONFIG_FILE
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --normalize)
            NORMALIZE=true
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
        --all)
            NORMALIZE=true
            ADD_MUSIC=true
            GENERATE_METADATA=true
            shift
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            DEBUG_MODE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# If no processing flags specified, enable all
if [[ "$NORMALIZE" == "false" && "$ADD_MUSIC" == "false" && "$GENERATE_METADATA" == "false" ]]; then
    NORMALIZE=true
    ADD_MUSIC=true
    GENERATE_METADATA=true
fi

# === UTILITY FUNCTIONS ===
log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_warning() {
    echo "⚠️  $1"
}

log_error() {
    echo "❌ $1" >&2
}

log_debug() {
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "🔍 $1"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate dependencies
validate_dependencies() {
    local missing_deps=()
    
    if ! command_exists ffmpeg; then
        missing_deps+=("ffmpeg")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo apt update && sudo apt install ${missing_deps[*]}"
        exit 1
    fi
}

# Create directory structure
setup_directories() {
    local dirs=(
        "$INPUT_DIR" "$OUTPUT_DIR" "$EXPORT_DIR/youtube" 
        "$EXPORT_DIR/podcast" "$EXPORT_DIR/radio" 
        "$META_DIR" "$LOG_DIR" "$ASSETS_DIR/music"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_debug "Created directory: $dir"
        fi
    done
}

# Process single audio file
process_audio_file() {
    local input_file="$1"
    local filename=$(basename "$input_file")
    local basename="${filename%.*}"
    
    log_info "Processing: $filename"
    
    # Define output files
    local normalized_file="$OUTPUT_DIR/${basename}_normalized.wav"
    local mixed_file="$OUTPUT_DIR/${basename}_mixed.wav"
    local final_mp3="$OUTPUT_DIR/${basename}.mp3"
    
    # Skip if already processed and not forcing
    if [[ -f "$final_mp3" && "$FORCE_OVERWRITE" == "false" ]]; then
        log_warning "Skipping $filename (already processed, use --force to overwrite)"
        return 0
    fi
    
    # Step 1: Audio Normalization
    if [[ "$NORMALIZE" == "true" ]]; then
        log_debug "  → Normalizing audio (Target: ${NORMALIZE_LEVEL} LUFS)"
        
        if ! ffmpeg -i "$input_file" \
            -af "loudnorm=I=${NORMALIZE_LEVEL}:TP=${TARGET_PEAK}:LRA=11:measured_I=-23:measured_LRA=7:measured_TP=-5:measured_thresh=-34:offset=0.47:linear=true:print_format=summary" \
            -ar "$SAMPLE_RATE" \
            "$normalized_file" -y >/dev/null 2>&1; then
            log_error "Failed to normalize $filename"
            return 1
        fi
    else
        cp "$input_file" "$normalized_file"
    fi
    
    # Step 2: Background Music Mixing
    if [[ "$ADD_MUSIC" == "true" ]]; then
        local bg_music="$ASSETS_DIR/music/background.mp3"
        
        if [[ -f "$bg_music" ]]; then
            log_debug "  → Adding background music (Volume: ${MUSIC_VOLUME})"
            
            if ! ffmpeg -i "$normalized_file" -i "$bg_music" \
                -filter_complex "[1:a]volume=${MUSIC_VOLUME},aloop=loop=-1:size=2e+09[bg];[0:a][bg]amix=inputs=2:duration=first:dropout_transition=2" \
                -c:a pcm_s16le \
                "$mixed_file" -y >/dev/null 2>&1; then
                log_warning "Failed to add background music, using normalized audio"
                cp "$normalized_file" "$mixed_file"
            fi
        else
            log_warning "Background music not found: $bg_music"
            cp "$normalized_file" "$mixed_file"
        fi
    else
        cp "$normalized_file" "$mixed_file"
    fi
    
    # Step 3: Export as high-quality MP3
    log_debug "  → Exporting MP3 (${OUTPUT_QUALITY})"
    
    if ! ffmpeg -i "$mixed_file" \
        -codec:a libmp3lame -b:a "$OUTPUT_QUALITY" \
        -metadata title="${basename//_/ }" \
        -metadata artist="$MINISTRY_NAME" \
        -metadata album="Sermons" \
        -metadata genre="Speech" \
        "$final_mp3" -y >/dev/null 2>&1; then
        log_error "Failed to export MP3 for $filename"
        return 1
    fi
    
    # Step 4: Generate Metadata
    if [[ "$GENERATE_METADATA" == "true" ]]; then
        generate_metadata "$basename"
    fi
    
    # Step 5: Create platform exports
    create_platform_exports "$basename" "$final_mp3"
    
    # Cleanup intermediate files
    rm -f "$normalized_file" "$mixed_file"
    
    log_success "Completed: $filename"
    return 0
}

# Generate metadata for platforms
generate_metadata() {
    local basename="$1"
    local metadata_file="$META_DIR/${basename}.txt"
    
    log_debug "  → Generating metadata"
    
    # Extract date from filename if present (YYYY-MM-DD format)
    local date_part=""
    local title_part="$basename"
    
    if [[ "$basename" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.+)$ ]]; then
        date_part="${BASH_REMATCH[1]}"
        title_part="${BASH_REMATCH[2]}"
        
        # Format date for display
        if command_exists date; then
            local formatted_date=$(date -d "$date_part" +"%B %d, %Y" 2>/dev/null || echo "")
        fi
    fi
    
    # Clean up title (replace underscores/hyphens with spaces)
    local clean_title="${title_part//_/ }"
    clean_title="${clean_title//-/ }"
    
    # Generate YouTube metadata
    cat > "$metadata_file" << EOF
TITLE: $clean_title - $MINISTRY_NAME${formatted_date:+ - $formatted_date}

DESCRIPTION:
Join us for an inspiring message: "$clean_title"
${formatted_date:+Recorded on $formatted_date}

🙏 STAY CONNECTED:
▶️ Subscribe for more inspiring messages
👍 Like if this blessed you
💬 Share your thoughts in the comments
🔔 Turn on notifications

🌐 CONNECT WITH US:
Website: $MINISTRY_WEBSITE
Social Media: $MINISTRY_SOCIAL

#Sermon #Faith #Church #Gospel #$MINISTRY_NAME #ChristianMessage

TAGS: Sermon, Faith, Gospel, Jesus, Church, Christian, Ministry, $MINISTRY_NAME, Inspiration, Bible

CATEGORY: $YOUTUBE_CATEGORY
EOF
    
    log_debug "    ✓ Metadata saved: $(basename "$metadata_file")"
}

# Create platform-specific exports
create_platform_exports() {
    local basename="$1"
    local source_file="$2"
    
    log_debug "  → Creating platform exports"
    
    # YouTube (high quality)
    cp "$source_file" "$EXPORT_DIR/youtube/${basename}.mp3"
    
    # Podcast (with additional metadata)
    ffmpeg -i "$source_file" \
        -codec:a libmp3lame -b:a "$OUTPUT_QUALITY" \
        -metadata title="${basename//_/ }" \
        -metadata artist="$MINISTRY_NAME" \
        -metadata album="Sermon Podcast" \
        -metadata genre="Podcast" \
        -metadata date="$(date +%Y)" \
        "$EXPORT_DIR/podcast/${basename}.mp3" -y >/dev/null 2>&1
    
    # Radio (normalized for broadcast)
    ffmpeg -i "$source_file" \
        -af "loudnorm=I=-23:TP=-2:LRA=7" \
        -codec:a libmp3lame -b:a 192k \
        "$EXPORT_DIR/radio/${basename}.mp3" -y >/dev/null 2>&1
}

# Process files in parallel
process_files_parallel() {
    local files=("$@")
    local pids=()
    local active_jobs=0
    local max_jobs="$PROCESSING_THREADS"
    
    for file in "${files[@]}"; do
        # Wait if we've reached max parallel jobs
        while [[ $active_jobs -ge $max_jobs ]]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                    unset "pids[$i]"
                    ((active_jobs--))
                fi
            done
            sleep 0.1
        done
        
        # Start new background job
        process_audio_file "$file" &
        pids+=($!)
        ((active_jobs++))
    done
    
    # Wait for all jobs to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# === MAIN EXECUTION ===
main() {
    echo "🎙️  Church Media Ops - Professional Audio Processing"
    echo "=================================================="
    echo "Ministry: $MINISTRY_NAME"
    echo "Processing Mode: ${NORMALIZE:+Normalize }${ADD_MUSIC:+Music }${GENERATE_METADATA:+Metadata}"
    echo "Started: $(date)"
    echo ""
    
    # Setup logging
    local log_file="$LOG_DIR/processing_$(date +"%Y%m%d_%H%M%S").log"
    if [[ "$VERBOSE" == "true" ]]; then
        exec > >(tee -a "$log_file") 2>&1
    else
        exec 2>>"$log_file"
    fi
    
    # Validate environment
    validate_dependencies
    setup_directories
    
    # Find audio files
    local audio_files=()
    while IFS= read -r -d '' file; do
        audio_files+=("$file")
    done < <(find "$INPUT_DIR" -name "*.wav" -type f -print0)
    
    if [[ ${#audio_files[@]} -eq 0 ]]; then
        log_error "No .wav files found in $INPUT_DIR"
        log_info "Please add your sermon recordings and try again"
        exit 1
    fi
    
    log_info "Found ${#audio_files[@]} audio file(s) to process"
    echo ""
    
    # Process files
    if [[ "$ENABLE_PARALLEL" == "true" && ${#audio_files[@]} -gt 1 ]]; then
        log_info "Processing files in parallel (max $PROCESSING_THREADS concurrent)"
        process_files_parallel "${audio_files[@]}"
    else
        log_info "Processing files sequentially"
        for file in "${audio_files[@]}"; do
            process_audio_file "$file"
        done
    fi
    
    # Summary
    echo ""
    echo "=================================================="
    log_success "Processing Complete!"
    echo "Processed: ${#audio_files[@]} file(s)"
    echo "Ended: $(date)"
    echo ""
    echo "📁 Output locations:"
    echo "  • Master files: $OUTPUT_DIR"
    echo "  • YouTube: $EXPORT_DIR/youtube"
    echo "  • Podcast: $EXPORT_DIR/podcast"
    echo "  • Radio: $EXPORT_DIR/radio"
    echo "  • Metadata: $META_DIR"
    echo ""
    echo "🎉 Ready for distribution!"
}

# Execute main function
main "$@"