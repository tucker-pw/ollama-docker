#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    log_success "Docker is running"
}

# Wait for a service to be healthy
wait_for_service() {
    local service=$1
    local max_attempts=${2:-30}  # Default 30 attempts, but can be overridden
    local attempt=0

    log_info "Waiting for $service to be ready..."

    while [ $attempt -lt $max_attempts ]; do
        # Check if container is healthy using docker inspect
        if docker inspect "$service" --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; then
            log_success "$service is ready"
            return 0
        fi
        # If no health check, just verify it's running
        if [ -z "$(docker inspect "$service" --format='{{.State.Health.Status}}' 2>/dev/null)" ]; then
            if docker inspect "$service" --format='{{.State.Running}}' 2>/dev/null | grep -q "true"; then
                log_success "$service is running"
                return 0
            fi
        fi
        attempt=$((attempt + 1))
        sleep 2
    done

    log_error "$service failed to become ready after ${max_attempts} attempts"
    return 1
}

# Setup function
setup() {
    log_info "Setting up Ollama Docker Project..."

    check_docker

    # Start services
    log_info "Starting services..."
    docker compose up -d

    # Wait for services to be ready
    wait_for_service "ollama" || exit 1
    wait_for_service "kokoro-tts" || exit 1
    wait_for_service "ollama-webui" 60 || exit 1  # Web UI needs more time (2 minutes)

    # Download default model from HuggingFace (bypasses certificate issues)
    log_info "Downloading default model from HuggingFace (${OLLAMA_MODEL:-llama3.2:1b})..."
    log_info "This may take a few minutes depending on your internet connection..."

    # Use HuggingFace download script (works around corporate VPN/certificate issues)
    if bash scripts/download-model-hf.sh ${OLLAMA_MODEL:-llama3.2:1b} 2>&1; then
        log_success "Model downloaded and imported successfully"
    else
        log_warning "Model download failed"
        log_info "You can manually download models with: make pull-hf llama3.2:1b"
        log_info "Or try the Web UI at http://localhost:3000"
    fi

    log_success "Setup complete!"
    log_info "Services running:"
    log_info "  - Ollama API: http://localhost:11434"
    log_info "  - Web UI: http://localhost:3000"
    log_info ""
    log_info "Open your browser to http://localhost:3000 to start chatting!"
}

# Start function
start() {
    log_info "Starting services..."
    docker compose up -d
    log_success "Services started"
}

# Start with GPU function
start_gpu() {
    log_info "Starting services with GPU support..."
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
    log_success "Services started with GPU support"
}

# Setup with GPU function
setup_gpu() {
    log_info "Setting up Ollama Docker Project with GPU support..."

    check_docker

    # Start services with GPU
    log_info "Starting services with GPU support..."
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d

    # Wait for services to be ready
    wait_for_service "ollama" || exit 1
    wait_for_service "kokoro-tts" || exit 1
    wait_for_service "ollama-webui" 60 || exit 1  # Web UI needs more time (2 minutes)

    # Download default model from HuggingFace (bypasses certificate issues)
    log_info "Downloading default model from HuggingFace (${OLLAMA_MODEL:-llama3.2:1b})..."
    log_info "This may take a few minutes depending on your internet connection..."

    # Use HuggingFace download script (works around corporate VPN/certificate issues)
    if bash scripts/download-model-hf.sh ${OLLAMA_MODEL:-llama3.2:1b} 2>&1; then
        log_success "Model downloaded and imported successfully"
    else
        log_warning "Model download failed"
        log_info "You can manually download models with: make pull-hf llama3.2:1b"
        log_info "Or try the Web UI at http://localhost:3000"
    fi

    log_success "Setup complete with GPU support!"
    log_info "Services running:"
    log_info "  - Ollama API: http://localhost:11434"
    log_info "  - Web UI: http://localhost:3000"
    log_info ""
    log_info "Open your browser to http://localhost:3000 to start chatting!"
}

# Stop function
stop() {
    log_info "Stopping services..."
    docker compose down
    log_success "Services stopped"
}

# Logs function
logs() {
    docker compose logs -f
}

# Status function
status() {
    docker compose ps
}

# Help function
help() {
    echo "Usage: $0 {setup|setup-gpu|start|start-gpu|stop|logs|status|help}"
    echo ""
    echo "Commands:"
    echo "  setup       - Initial setup (CPU mode)"
    echo "  setup-gpu   - Initial setup with NVIDIA GPU support"
    echo "  start       - Start all services (CPU mode)"
    echo "  start-gpu   - Start all services with GPU support"
    echo "  stop        - Stop all services"
    echo "  logs        - Show logs from all services"
    echo "  status      - Show service status"
    echo "  help        - Show this help message"
    echo ""
    echo "After setup, visit http://localhost:3000 for the web interface"
}

# Main script
case "${1:-}" in
    setup)
        setup
        ;;
    setup-gpu)
        setup_gpu
        ;;
    start)
        start
        ;;
    start-gpu)
        start_gpu
        ;;
    stop)
        stop
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    help|--help|-h)
        help
        ;;
    *)
        log_error "Unknown command: ${1:-}"
        help
        exit 1
        ;;
esac
