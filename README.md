# Ollama Project

A Docker-based setup for running large language models locally with voice conversation capabilities.
Uses the WebUI from this project: https://github.com/open-webui/open-webui

## Features

- **Local AI models** - Complete privacy, no cloud dependencies
- **Voice conversations** - Speech-to-text and text-to-speech
- **Multiple interfaces** - Web UI with voice support
- **GPU acceleration** - NVIDIA GPU support (CPU fallback available)
- **67+ TTS voices** - Multiple languages via Kokoro TTS
- **Simple commands** - `make` commands instead of complex Docker
- **VSCode integration** - Use as coding agent via Continue extension

## Quick Start

```bash
make setup    # First-time setup - automatically downloads llama3.2:1b from HuggingFace
```

That's it! The setup will:
1. Start all Docker containers
2. Download the default model (llama3.2:1b ~770MB) from HuggingFace
3. Import it into Ollama
4. Open http://localhost:3000 in your browser and start chatting!

**Note**: The HuggingFace download bypasses corporate VPN/certificate issues that affect direct Ollama registry downloads.

**Recommended Models**:
- **llama3.2:1b** (~770MB) - Fastest, great for CPU, default
- **llama3.2:3b** (~2GB) - Balanced performance
- **llama3.2:11b** (~7GB) - Highest quality (GPU recommended)

Download additional models with:
```bash
make pull-hf llama3.2:3b    # Download from HuggingFace
```

### GPU Support (Optional)

If you have an NVIDIA GPU with nvidia-container-toolkit installed (Linux only):

```bash
make setup-gpu  # Setup with GPU acceleration
```

### Apple Container (Experimental)

On macOS 26+ (Tahoe) with Apple Silicon, you can run Ollama natively without Docker using [Apple Container](https://github.com/apple/container):

```bash
make apple-container              # Run with llama3.2:1b
make apple-container llama3.2:3b  # Run with a different model
```

This provides:
- No Docker Desktop required
- Native Apple Silicon performance
- Sub-second container startup
- VM-level isolation per container

**Requirements**: macOS 26+, Apple Silicon, [Apple Container CLI](https://github.com/apple/container/releases)

**Cleanup**:
```bash
container stop ollama-test           # Stop the container
container delete ollama-test         # Remove the container
container image rm ollama/ollama     # Remove the image (reclaims ~18GB)
```

**Note**: This is a standalone Ollama setup. For the full experience with Web UI and voice features, use the Docker Compose setup (`make setup`).

## Available Models

- **llama3.2:1b** - Fastest, CPU-friendly (default)
- **llama3.2:3b** - Balanced performance
- **llama3.2:11b** - Highest quality (GPU recommended)
- **codellama:7b** - Code-focused
- **mistral:7b** - Alternative option

Switch models: `make switch llama3.2:3b`

## Requirements

- **Docker & Docker Compose**
- **8GB+ RAM** (16GB+ recommended for larger models)
- **10GB+ disk space** for models
- **NVIDIA GPU** (optional, for GPU acceleration on Linux)
  - Requires nvidia-container-toolkit
  - Use `make setup-gpu` instead of `make setup`

**Note**: CPU-only mode works great on Apple Silicon (M1/M2/M3) and modern CPUs for smaller models (1B-3B parameters)

## Commands

```bash
# Setup & Control
make setup              # Initial setup (CPU mode)
make setup-gpu          # Setup with NVIDIA GPU support
make start              # Start services (CPU mode)
make start-gpu          # Start with GPU support
make stop               # Stop all services
make restart            # Restart services
make status             # Show service status
make logs               # View service logs

# Model Management
make list-models        # List available models
make switch MODEL       # Switch model (e.g., make switch llama3.2:3b)
make pull MODEL         # Download a specific model
make pull-hf MODEL      # Download from HuggingFace (bypasses VPN/cert issues)

# Quick Model Shortcuts
make cpu                # Switch to llama3.2:1b (fastest)
make gpu                # Switch to llama3.2:3b (balanced)
make quality            # Switch to llama3.2:11b (best quality)
make code               # Switch to codellama:7b (code-focused)

# Web Interface
make web                # Show Web UI URL

# Cleanup
make clean              # Clean up containers/volumes
make reset              # Full reset (removes all data)

# Experimental
make apple-container    # Run Ollama via Apple Container (macOS 26+)
```

## Voice Features (Pre-configured)

Text-to-speech is **pre-configured** with Kokoro TTS! Just click the speaker icon to hear responses.

**Default voice**: `af_bella` (warm, natural English)

**To change voices**:
1. Visit http://localhost:3000
2. Go to **Settings → Audio**
3. Select a different voice from the dropdown (67+ voices available)

**Available voice options**:
- English: `af_bella`, `af_alloy`, `af_heart`, `af_nicole`, `af_sarah`
- Other languages: Japanese, Chinese, Korean, Spanish, French, and more

**Note**: Voice features work best on Linux. macOS/Windows users can still use voice, but text chat is more reliable.

## Architecture

- **Ollama**: AI model runtime
- **Open WebUI**: Chat interface with Whisper STT
- **Kokoro TTS**: Local text-to-speech (67 voices)

## Documentation

- [INSTALLATION.md](./docs/INSTALLATION.md) - Detailed setup instructions
- [USAGE.md](./docs/USAGE.md) - Usage examples and tips

## VSCode Integration

Use your local models as coding agents in VSCode with the [Continue extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue):

1. Install the Continue extension in VSCode
2. Copy [continue-config.yml](./continue-config.yml) to your Continue config directory
3. Start using your local models for code assistance

The included config provides access to all models running in your local Ollama instance.
