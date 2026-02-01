# Installation Guide

## Prerequisites

- **Docker & Docker Compose**
- **8GB+ RAM, 15GB disk space**
- **Microphone** (for voice features)

## 1. Install Docker

### Linux
```bash
# Ubuntu/Debian
sudo apt install docker.io docker-compose-v2
sudo usermod -aG docker $USER

# Arch/CachyOS  
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

### macOS/Windows
Install Docker Desktop from docker.com

**Important**: Log out and back in after adding yourself to docker group.

## 2. NVIDIA GPU Support (Optional, Linux Only)

For better performance with larger models, install NVIDIA Container Toolkit:

```bash
# Linux with NVIDIA GPU only
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
echo "deb [arch=amd64] https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update && sudo apt install nvidia-container-toolkit
sudo systemctl restart docker
```

**Important Notes**:
- GPU support only works on Linux with NVIDIA GPUs
- macOS (including Apple Silicon) and Windows users should use CPU mode
- CPU-only mode works great for smaller models (1B-3B parameters)
- Apple Silicon (M1/M2/M3) performs very well in CPU mode

## 3. Project Setup

```bash
# Clone or download project
git clone https://github.com/TuckerWarlock/ollama-docker
cd ollama-docker

# First-time setup - CPU mode (recommended for most users)
make setup

# OR if you have NVIDIA GPU + nvidia-container-toolkit (Linux only)
make setup-gpu
```

**That's it!** The setup will:
1. Download Docker images (~3GB)
2. Start all services
3. Automatically download the default model (llama3.2:1b ~770MB) from HuggingFace
4. Import the model into Ollama
5. Your Web UI will be ready at http://localhost:3000

**Note**: Models are downloaded from HuggingFace by default, which bypasses corporate VPN/certificate issues that affect direct Ollama registry downloads.

## 4. Download Additional Models

After setup, you can download more models using HuggingFace:

```bash
# Download from HuggingFace (recommended - bypasses VPN/cert issues)
make pull-hf llama3.2:3b

# List available models in your Ollama instance
make list-models

# Switch between downloaded models
make switch llama3.2:3b
```

**Recommended Models**:
- **llama3.2:1b** (~770MB) - Perfect for CPU, Apple Silicon M1/M2/M3
- **llama3.2:3b** (~2GB) - Great balance for most systems
- **llama3.2:11b** (~7GB) - Highest quality (GPU recommended)

## 5. Voice Configuration (Optional, Linux Recommended)

Voice features work best on Linux but can be configured on any platform:

1. Open http://localhost:3000
2. Go to **Admin Settings → Audio**
3. Configure TTS:
   - **Text-to-Speech Engine**: OpenAI
   - **API Base URL**: `http://kokoro-tts:8880/v1`
   - **API Key**: `not-needed`
   - **TTS Model**: `kokoro`
   - **TTS Voice**: `af_bella` (or choose from 67+ voices)
4. Grant microphone permissions when prompted
5. Save settings

**Note**: macOS/Windows users may experience limitations with voice features. Text chat works perfectly on all platforms.

## 6. Verification

```bash
make status    # All services should be running
make web       # Shows http://localhost:3000
```

Open http://localhost:3000 in your browser and start chatting!

## Troubleshooting

### Common Issues

**Permission denied with Docker**:
```bash
sudo usermod -aG docker $USER
# Then logout and login again
```

**Port conflicts** (ports 3000, 11434, 8880 already in use):
```bash
docker compose down
lsof -i :3000  # Check what's using the port
```

**Services won't start**:
```bash
make logs      # Check service logs
make restart   # Try restarting
make clean     # Clean rebuild
```

**Model download issues**:
The setup automatically downloads models from HuggingFace, which bypasses certificate issues. If you still have problems:
```bash
make pull-hf llama3.2:1b    # Manually trigger HuggingFace download
```

**GPU not working** (Linux):
- Verify nvidia-container-toolkit is installed
- Use `make setup-gpu` instead of `make setup`
- Check: `docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi`

**Voice features not working**:
- Voice works best on Linux systems
- macOS/Windows: Use text chat instead (works perfectly)
- Check browser microphone permissions
- Verify TTS configuration in Admin Settings → Audio

### Clean Start
```bash
make reset     # Complete reset (removes all data)
make setup     # Fresh installation
```

For detailed logs: `make logs`
