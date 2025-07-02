# Church Media Ops - Automation System

> Transforming sermon production with powerful audio processing, smart metadata generation, and multi-platform distribution.

<div align="center">
  <img src="https://raw.githubusercontent.com/user/repo/main/assets/visualizer.gif" alt="Church Media Ops Visualizer" width="80%">
</div>

---

## 🎯 Purpose
This end-to-end automation system streamlines your entire sermon production workflow:
- Professional-grade audio normalization for broadcast quality
- Intelligent background music mixing with dynamic levels
- Automated metadata generation for digital platforms
- Multi-format export preparation (YouTube, radio, podcasts, streaming)

Optimized for **Samsung Galaxy Chromebook Go** running **Linux (Crostini)**, providing enterprise-level performance on lightweight hardware.

---

## 📂 Folder Structure
```bash
ChurchOps/
├── raw/audio/           # Source directory for original sermon recordings (.wav)
├── processed/audio/     # Destination for enhanced audio files
├── export/              # Platform-specific distribution files
│   ├── youtube/         # YouTube-ready content with thumbnails
│   ├── podcast/         # Podcast episodes with metadata
│   └── radio/           # Broadcast-ready audio files
├── assets/              # Resource files for production
│   ├── music/           # Background music tracks
│   ├── thumbnails/      # Custom thumbnail templates
│   └── branding/        # Logos and branding elements
├── metadata/            # Generated platform-specific metadata
├── scripts/             # Automation scripts
│   ├── batch_normalizer.sh
│   ├── metadata_generator.sh
│   └── platform_distributor.sh
├── config/              # Configuration files and settings
├── logs/                # Processing logs and diagnostics
└── README.md            # This documentation
```

---

## 🚀 Setup

### 🛠 Prerequisites
```bash
sudo apt update
sudo apt install ffmpeg shotcut audacity python3 python3-pip
pip3 install pydub google-api-python-client oauth2client
```

### ⚙️ Configuration
Create a personalized setup with the initialization script:
```bash
chmod +x init_church_media.sh
./init_church_media.sh --ministry-name="Gospel Mission Team UNZA" --output-quality=320k
```

### 🔁 Processing Workflow
```bash
cd ~/ChurchOps/scripts
chmod +x batch_normalizer.sh
./batch_normalizer.sh --normalize --add-music --generate-metadata
```

---

## 🧠 Core Features

### Audio Processing Pipeline
Each sermon recording undergoes a sophisticated processing chain:

1. **Audio Analysis** - Intelligent volume profiling and silence detection
2. **Normalization** - Industry-standard loudness normalization (EBU R128)
   ```bash
   ffmpeg -i input.wav -af loudnorm=I=-16:TP=-1.5:LRA=11 output.wav
   ```
3. **Music Integration** - Dynamically mixed background music with volume automation
4. **Multi-format Export** - Optimized files for each target platform

### Metadata Generation
Automatic creation of platform-specific metadata including:
- SEO-optimized titles and descriptions
- Smart tagging based on sermon content
- Custom thumbnail generation with templating
- Publishing schedules and distribution plans

---

## 📊 Analytics & Monitoring
- Processing logs with detailed diagnostics
- Audio quality metrics and validation reports
- Platform performance tracking (optional)

---

## ✨ Roadmap
- 🔊 Advanced audio ducking with AI-powered speech detection
- 🎬 Automated highlight clip generation for social media
- 🌐 One-click multi-platform distribution
- 🎨 Dynamic video generation with sermon quotes
- 📱 Mobile companion app for remote monitoring
- 🤖 AI-powered sermon transcription and indexing

---

## 💻 Web Visualizer
Deploy this interactive HTML visualizer to preview your sermon library:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Church Media Ops - Sermon Visualizer</title>
  <style>
    :root {
      --primary: #3a86ff;
      --secondary: #8338ec;
      --accent: #ff006e;
      --background: #0a1128;
      --text: #f8f9fa;
    }
    
    body {
      background: var(--background);
      color: var(--text);
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      min-height: 100vh;
    }
    
    header {
      text-align: center;
      padding: 2rem 1rem;
      width: 100%;
    }
    
    h1 {
      font-size: 2.5rem;
      margin-bottom: 0.5rem;
      background: linear-gradient(45deg, var(--primary), var(--secondary));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    
    .visualizer-container {
      width: 80%;
      max-width: 800px;
      background: rgba(255, 255, 255, 0.05);
      border-radius: 12px;
      padding: 2rem;
      margin: 1rem 0;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    }
    
    .bars-container {
      display: flex;
      align-items: flex-end;
      height: 150px;
      margin: 2rem 0;
    }
    
    .bar {
      flex: 1;
      margin: 0 2px;
      background: linear-gradient(180deg, var(--accent), var(--primary));
      border-radius: 4px 4px 0 0;
      transition: height 0.2s ease;
    }
    
    @keyframes equalize {
      0% { height: 40%; }
      10% { height: 80%; }
      20% { height: 60%; }
      30% { height: 90%; }
      40% { height: 50%; }
      50% { height: 70%; }
      60% { height: 30%; }
      70% { height: 85%; }
      80% { height: 45%; }
      90% { height: 75%; }
      100% { height: 40%; }
    }
    
    .playing .bar {
      animation: equalize 1.5s infinite;
      animation-delay: calc(var(--i) * 0.1s);
    }
    
    .controls {
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-top: 2rem;
    }
    
    .audio-player {
      width: 100%;
      margin-top: 1rem;
    }
    
    audio {
      width: 100%;
      border-radius: 8px;
    }
    
    .sermon-info {
      text-align: center;
      margin: 1rem 0;
    }
    
    .sermon-title {
      font-size: 1.5rem;
      font-weight: bold;
      margin-bottom: 0.5rem;
    }
    
    .sermon-details {
      font-size: 0.9rem;
      opacity: 0.8;
    }
    
    .responsive-info {
      width: 100%;
      text-align: center;
      margin-top: 2rem;
      font-size: 0.9rem;
      opacity: 0.7;
    }
    
    @media (max-width: 768px) {
      .visualizer-container {
        width: 95%;
        padding: 1rem;
      }
      
      .bars-container {
        height: 100px;
      }
      
      h1 {
        font-size: 1.8rem;
      }
    }
  </style>
</head>
<body>
  <header>
    <h1>Sermon Audio Visualizer</h1>
    <p>Experience the Word with enhanced audio quality</p>
  </header>
  
  <div class="visualizer-container">
    <div id="bars-container" class="bars-container">
      <!-- Bars generated by JavaScript -->
    </div>
    
    <div class="sermon-info">
      <div class="sermon-title">Walking in Faith</div>
      <div class="sermon-details">Pastor Johnson • July 2, 2025 • Sunday Service</div>
    </div>
    
    <div class="controls">
      <div class="audio-player">
        <audio id="sermon-audio" controls>
          <source src="processed/audio/example.mp3" type="audio/mpeg">
          Your browser does not support the audio element.
        </audio>
      </div>
    </div>
  </div>
  
  <div class="responsive-info">
    <p>Powered by Church Media Ops Automation System</p>
    <p>© 2025 Your Ministry Name</p>
  </div>

  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const barsContainer = document.getElementById('bars-container');
      const audio = document.getElementById('sermon-audio');
      
      // Create equalizer bars
      for (let i = 0; i < 32; i++) {
        const bar = document.createElement('div');
        bar.className = 'bar';
        bar.style.setProperty('--i', i);
        bar.style.height = `${Math.random() * 80 + 20}%`;
        barsContainer.appendChild(bar);
      }
      
      // Add animation class when audio plays
      audio.addEventListener('play', function() {
        barsContainer.classList.add('playing');
      });
      
      audio.addEventListener('pause', function() {
        barsContainer.classList.remove('playing');
      });
      
      audio.addEventListener('ended', function() {
        barsContainer.classList.remove('playing');
      });
    });
  </script>
</body>
</html>
```

---

## 🧠 Built By
**Rabboni** — System Architect & Audio Ops Enginner  
**Nyx** — Tactical AI Engineer  
**Claude** — Documentation & UX Enhancement Specialist

---

## 📞 Support & Contact
For technical support or custom implementation:
- 📧 Email: [Click Hear to send Email](mailto:kabongorabboni03@gmail.com)
- 💬 GitHub Issues: [Report a bug](https://github.com/your-username/church-media-ops/issues)

---

## ✅ License
MIT — Free to use, modify, and distribute for God's glory.

**Scriptural Foundation:**  
*"Let all things be done decently and in order."* — 1 Corinthians 14:40
