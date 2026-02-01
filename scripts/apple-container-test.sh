#!/bin/bash
# Apple Container Test Script - Run Ollama natively on macOS
# Requires: macOS 26 (Tahoe) + Apple Silicon + Apple Container installed

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

MODEL="${1:-llama3.2:1b}"
CONTAINER_NAME="ollama-test"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       Apple Container + Ollama Test                        ║"
echo "║       Running LLMs natively on macOS (no Docker!)          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
print_step "Checking prerequisites..."

# Check for Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    print_error "Apple Silicon required. This Mac uses $(uname -m)."
    exit 1
fi
print_success "Apple Silicon detected"

# Check macOS version
macos_version=$(sw_vers -productVersion)
major_version=$(echo "$macos_version" | cut -d. -f1)
if [[ "$major_version" -lt 26 ]]; then
    print_error "macOS 26 (Tahoe) or later required. You have macOS $macos_version"
    echo ""
    echo "Apple Container requires macOS 26. Options:"
    echo "  1. Wait for macOS 26 public release"
    echo "  2. Use Docker Desktop (current setup): make setup"
    echo ""
    exit 1
fi
print_success "macOS $macos_version detected"

# Check if container CLI is installed
if ! command -v container &> /dev/null; then
    print_error "Apple Container CLI not found"
    echo ""
    echo "Install from: https://github.com/apple/container/releases"
    echo "  1. Download the latest .pkg installer"
    echo "  2. Double-click to install"
    echo "  3. Run: container system start"
    echo ""
    exit 1
fi
print_success "Apple Container CLI found ($(container system version 2>/dev/null || echo 'version unknown'))"

# Check if container service is running
print_step "Checking container service status..."

# Check if kernel is installed
if ! container system version 2>&1 | grep -q "container API Server"; then
    print_warning "Container API server not running"
    echo ""
    echo "First-time setup required. Run these commands manually:"
    echo ""
    echo "  1. Start the container system (will prompt to install kernel):"
    echo "     container system start"
    echo ""
    echo "  2. When prompted, press Y to install the Kata containers kernel"
    echo ""
    echo "  3. Then re-run this script:"
    echo "     make apple-container"
    echo ""
    exit 1
fi
print_success "Container service ready"

# Create volume for model persistence
print_step "Creating volume for Ollama models..."
container volume create ollama-models 2>/dev/null || true
print_success "Volume 'ollama-models' ready"

# Check if container already running
if container list 2>/dev/null | grep -q "$CONTAINER_NAME"; then
    print_warning "Container '$CONTAINER_NAME' already running"
    echo ""
    read -p "Stop and restart? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        container stop "$CONTAINER_NAME" 2>/dev/null || true
        container delete "$CONTAINER_NAME" 2>/dev/null || true
    else
        echo ""
        echo "Connect to existing container:"
        echo "  container exec -i -t $CONTAINER_NAME ollama run $MODEL"
        exit 0
    fi
fi

# Pull Ollama image
print_step "Pulling Ollama image..."
container image pull ollama/ollama:latest
print_success "Ollama image ready"

# Run Ollama container with enough memory for models
print_step "Starting Ollama container..."
container run -d \
    --name "$CONTAINER_NAME" \
    --memory 4G \
    --cpus 4 \
    --volume ollama-models:/root/.ollama \
    ollama/ollama:latest

print_success "Ollama container started"

# Wait for Ollama to be ready
print_step "Waiting for Ollama to initialize..."
sleep 3

# Get container IP
CONTAINER_IP=$(container inspect "$CONTAINER_NAME" --format '{{.NetworkSettings.IPAddress}}' 2>/dev/null || echo "")
if [[ -n "$CONTAINER_IP" ]]; then
    print_success "Ollama API available at: http://$CONTAINER_IP:11434"
fi

# Pull the model
print_step "Pulling model: $MODEL (this may take a few minutes)..."
container exec "$CONTAINER_NAME" ollama pull "$MODEL"
print_success "Model '$MODEL' ready"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Setup Complete!                                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Start chatting:"
echo "  container exec -i -t $CONTAINER_NAME ollama run $MODEL"
echo ""
echo "Or use the API:"
if [[ -n "$CONTAINER_IP" ]]; then
    echo "  curl http://$CONTAINER_IP:11434/api/generate -d '{"
    echo "    \"model\": \"$MODEL\","
    echo "    \"prompt\": \"Hello!\""
    echo "  }'"
fi
echo ""
echo "Other commands:"
echo "  container logs $CONTAINER_NAME     # View logs"
echo "  container stop $CONTAINER_NAME     # Stop container"
echo "  container rm $CONTAINER_NAME       # Remove container"
echo ""
echo "To chat now, run:"
echo -e "  ${GREEN}container exec -i -t $CONTAINER_NAME ollama run $MODEL${NC}"
echo ""

# Offer to start chat immediately
read -p "Start chatting now? (Y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    container exec -i -t "$CONTAINER_NAME" ollama run "$MODEL"
fi
