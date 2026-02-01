# Usage Guide

This guide covers everything you need to know about using the Ollama Project effectively.
## Quick Commands

```bash
make                    # Show all commands
make web                # Show web interface URL
make switch MODEL       # Change AI model
make cpu/gpu/quality    # Quick model switches
make status             # Check services
make logs               # View service logs
```

## Interfaces

### Voice Conversations
1. Visit http://localhost:3000
2. Click microphone icon
3. Speak naturally
4. AI responds with voice

### Web Chat
- Text-based chat at http://localhost:3000
- File uploads and chat history
- Model switching via dropdown

## Model Selection

| Model | Best For | Speed | Resource Use |
|-------|----------|--------|--------------|
| llama3.2:1b | Quick questions, real-time voice | Fastest | Low (CPU-friendly) |
| llama3.2:3b | General conversation | Balanced | Medium |
| llama3.2:11b | Complex topics | Slower | High (GPU needed) |
| codellama:7b | Programming help | Medium | Medium (GPU preferred) |

```bash
make cpu       # llama3.2:1b
make gpu       # llama3.2:3b
make quality   # llama3.2:11b
make code      # codellama:7b
```

## Voice Features

### TTS Voices
Choose from 67+ voices in Admin Settings → Audio:

**Popular English:**
- `af_bella` - Warm, natural
- `af_alloy` - Professional
- `af_heart` - Expressive

**Other Languages:**
- `ja_*` - Japanese voices
- `zh_*` - Chinese voices
- `ko_*` - Korean voices

### Voice Tips
- Speak clearly and pause between thoughts
- Enable "Auto-playback" for automatic responses
- Use natural, conversational language
- Grant browser microphone permissions when prompted

## Common Workflows

### Learning Session
```bash
make quality  # Best explanations
# Voice: "Explain machine learning basics"
# Follow up with related questions
```

### Coding Help
```bash
make code     # Programming-focused model  
# Voice: "Help debug this Python function"
# Paste code, ask voice questions about it
```

### Quick Q&A
```bash
make cpu      # Fastest responses
# Voice: "What's the weather like today?"
# Good for rapid back-and-forth
```

## Configuration

### Web Interface Settings
- **Model selection**: Dropdown in web UI (switch between downloaded models)
- **Voice settings**: Admin Settings → Audio (optional, Linux recommended)
- **Chat history**: Automatically saved

### Model Downloads
Download additional models from HuggingFace (bypasses VPN/certificate issues):
```bash
make pull-hf llama3.2:3b    # Download from HuggingFace
make list-models            # List downloaded models
make switch llama3.2:3b     # Switch active model
```

### Environment Variables
Create `.env` file from `.env.example` for defaults:
```bash
cp .env.example .env
# Edit .env to set your preferred default model
OLLAMA_MODEL=llama3.2:1b  # or llama3.2:3b, etc.
OLLAMA_HOST=http://localhost:11434
```

### GPU Mode (Linux Only)
If you have NVIDIA GPU + nvidia-container-toolkit:
```bash
make setup-gpu    # Initial setup with GPU
make start-gpu    # Start with GPU support
```

## Maintenance

```bash
make status    # Check all services
make logs      # View service logs
make restart   # Restart everything
make stop      # Stop all services
make start     # Start services (CPU mode)
make start-gpu # Start with GPU (Linux only)
make clean     # Remove containers, volumes, networks
make reset     # Full reset (with confirmation)
```

## Platform-Specific Notes

### macOS (Including Apple Silicon)
- Use CPU mode (`make setup`)
- Apple Silicon (M1/M2/M3) performs excellently with smaller models
- Voice features have limitations; text chat works perfectly
- Models automatically download from HuggingFace during setup

### Linux
- Both CPU and GPU modes supported
- GPU mode requires NVIDIA GPU + nvidia-container-toolkit
- All features including voice work well
- Use `make setup-gpu` for GPU acceleration

### Windows
- Use CPU mode via Docker Desktop
- Voice features have limitations; text chat works perfectly
- WSL2 backend recommended for better performance

For installation issues, see [INSTALLATION.md](./INSTALLATION.md).
