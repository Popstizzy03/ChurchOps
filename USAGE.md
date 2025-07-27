# Church Media Ops - Quick Start Guide

## 🚀 Quick Setup

1. **Initialize the workspace:**
   ```bash
   ./init_church_media.sh --ministry-name="Your Ministry Name"
   ```

2. **Add your sermon recordings:**
   - Place `.wav` files in `raw/audio/`
   - Recommended naming: `YYYY-MM-DD-SermonTitle.wav`

3. **Add background music (optional):**
   - Place `background.mp3` in `assets/music/`

4. **Process your sermons:**
   ```bash
   ./church_media_ops.sh --all
   ```

## 📋 Processing Options

| Command | Description |
|---------|-------------|
| `--all` | Enable all features (recommended) |
| `--normalize` | Apply professional audio normalization |
| `--add-music` | Mix background music |
| `--generate-metadata` | Create platform-specific metadata |
| `--force` | Overwrite existing processed files |
| `--verbose` | Enable detailed logging |

## 📁 Output Structure

After processing, files are organized as:

```
ChurchOps/
├── processed/audio/           # Master processed files
├── export/
│   ├── youtube/              # YouTube-ready MP3s
│   ├── podcast/              # Podcast episodes with metadata
│   └── radio/                # Broadcast-normalized audio
└── metadata/                 # Platform-specific descriptions and tags
```

## 🎯 Example Workflows

**Basic Processing:**
```bash
./church_media_ops.sh --normalize
```

**Full Production Pipeline:**
```bash
./church_media_ops.sh --all --verbose
```

**Reprocess Everything:**
```bash
./church_media_ops.sh --all --force
```

## 🛠️ Troubleshooting

**No files found?**
- Ensure `.wav` files are in `raw/audio/`
- Check file permissions

**Audio quality issues?**
- Adjust `OUTPUT_QUALITY` in `config/settings.conf`
- Use `--verbose` to see processing details

**Background music not working?**
- Ensure `assets/music/background.mp3` exists
- Check file format compatibility

## ⚙️ Configuration

Edit `config/settings.conf` to customize:
- Ministry information
- Audio quality settings
- Processing parameters
- Output formats

## 📞 Support

For technical issues or questions:
- Check logs in `logs/` directory
- Use `--verbose` for detailed output
- Contact: kabongorabboni03@gmail.com