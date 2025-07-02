# Church Media Ops - Automation System

> Automate, enhance, and deploy sermon audio content with precision and reproducibility.

![Visualizer](https://raw.githubusercontent.com/user/repo/main/assets/visualizer.gif)

---

## 🎯 Purpose
This project is designed to automate the sermon production pipeline:
- Normalize sermon audio
- Mix with background music
- Generate metadata for YouTube uploads
- Prepare audio for platforms like YouTube, radio, podcast, etc.

Built for **Samsung Galaxy Chromebook Go** running **Linux (Crostini)**, lightweight and production-grade.

---

## 📂 Folder Structure
```bash
ChurchOps/
├── raw/audio/           # Drop original .wav sermon recordings here
├── processed/audio/     # Auto-processed audio ends up here
├── export/youtube/      # Ready-to-upload files go here (optional)
├── assets/music/        # Your background music (background.mp3)
├── metadata/            # Generated YouTube metadata
├── scripts/             # Bash scripts for processing
│   └── batch_normalizer.sh
├── README.md            # This file
```

---

## 🚀 Setup

### 🛠 Requirements
```bash
sudo apt update
sudo apt install ffmpeg shotcut audacity
```

### ✅ Init Command
Run the provided setup script to initialize everything:
```bash
chmod +x init_church_media.sh
./init_church_media.sh
```

### 🔁 Process Sermons
```bash
cd ~/ChurchOps/scripts
chmod +x batch_normalizer.sh
./batch_normalizer.sh
```

---

## 🧠 What It Does

Each `.wav` file in `raw/audio/` is:
1. Normalized (using `ffmpeg -af loudnorm`)
2. Mixed with your background music (`assets/music/background.mp3`)
3. Exported as `.mp3` into `processed/audio/`
4. Auto-generated YouTube metadata stored in `metadata/`

---

## ✨ Coming Soon
- 🔊 Sidechain ducking (so music drops behind speech)
- 🎬 Auto clip generation (for social reels)
- 🌐 Auto YouTube uploads (via YouTube API)
- 📈 Audio visualizer HTML for GitHub Pages

---

## 💻 GitHub Pages Preview
Want to create a website to preview or share your sermons? Use this:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ChurchOps Audio Visualizer</title>
  <style>
    body { background: #111; color: #eee; font-family: monospace; text-align: center; }
    .bar { height: 10px; background: lime; margin: 2px 0; animation: pulse 1s infinite; }
    @keyframes pulse {
      0% { width: 30%; }
      50% { width: 80%; }
      100% { width: 40%; }
    }
  </style>
</head>
<body>
  <h1>🎧 Now Playing: Sermon Audio</h1>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <audio controls autoplay>
    <source src="processed/audio/example.mp3" type="audio/mpeg">
    Your browser does not support the audio tag.
  </audio>
</body>
</html>
```

---

## 🧠 Built By
**Rabboni Kabongo** – System Architect & Audio Ops Commander  
**ChatGPT** – Tactical AI Engineer

---

## ✅ License
MIT — Steal it, scale it, sanctify it.
