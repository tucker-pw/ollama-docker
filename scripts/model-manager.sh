#!/usr/bin/env bash

# Model Management Script for Ollama
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Available models with descriptions (format: "model|description")
MODELS=(
    "llama3.2:1b|Fastest, smallest (1B params, ~1GB VRAM, CPU-friendly)"
    "llama3.2:3b|Balanced option (3B params, ~2GB VRAM)"
    "llama3.2:11b|Highest quality (11B params, ~7GB VRAM, GPU recommended)"
    "codellama:3b|Code-focused (3B params, ~2GB VRAM)"
    "codellama:7b|Code-focused (7B params, ~4GB VRAM)"
    "mistral:3b|Alternative option (3B params, ~2GB VRAM)"
    "mistral:7b|Alternative option (7B params, ~4GB VRAM)"
    "qwen2.5-coder:3b|Qwen 2.5 Coder (3B params, ~2GB VRAM)"
    "qwen2.5-coder:7b|Qwen 2.5 Coder (7B params, ~4GB VRAM)"
    "gemma3:1b|Gemma 3 (1B params, ~1GB VRAM)"
    "gemma3:4b|Gemma 3 (4B params, ~3GB VRAM)"
)

# Get model description
get_model_description() {
    local model=$1
    for entry in "${MODELS[@]}"; do
        local m="${entry%%|*}"
        local desc="${entry##*|}"
        if [[ "$m" == "$model" ]]; then
            echo "$desc"
            return 0
        fi
    done
    echo "Unknown model"
    return 1
}

# Check if model exists
model_exists() {
    local model=$1
    for entry in "${MODELS[@]}"; do
        local m="${entry%%|*}"
        if [[ "$m" == "$model" ]]; then
            return 0
        fi
    done
    return 1
}

# Current model from .env
get_current_model() {
    grep "^OLLAMA_MODEL=" .env 2>/dev/null | cut -d'=' -f2 || echo "llama3.2:1b"
}

# Update .env file with new model
set_model() {
    local model=$1
    if [[ -f .env ]]; then
        # Update existing line (macOS compatible)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^OLLAMA_MODEL=.*/OLLAMA_MODEL=${model}/" .env
        else
            sed -i "s/^OLLAMA_MODEL=.*/OLLAMA_MODEL=${model}/" .env
        fi
    else
        # Create .env if it doesn't exist
        echo "OLLAMA_MODEL=${model}" > .env
    fi
    log_success "Set model to: $model"
}

# List available models
list_models() {
    local current=$(get_current_model)

    echo "Available models:"
    for entry in "${MODELS[@]}"; do
        local model="${entry%%|*}"
        local desc="${entry##*|}"
        if [[ "$model" == "$current" ]]; then
            echo -e "  ${GREEN}* $model${NC} - $desc (current)"
        else
            echo -e "    $model - $desc"
        fi
    done
}

# Pull a model
pull_model() {
    local model=$1

    # Check if ollama container is running
    if ! docker compose ps --services --filter status=running | grep -q ollama; then
        log_error "Ollama service is not running. Please start it first with 'make start'"
        exit 1
    fi

    log_info "Pulling model: $model"
    if docker compose exec ollama ollama pull "$model"; then
        log_success "Model $model downloaded"
    else
        log_error "Failed to download model $model"
        exit 1
    fi
}

# Switch to a model (pull if needed, update .env)
switch_model() {
    local model=$1

    # Check if model exists in our list
    if ! model_exists "$model"; then
        log_error "Unknown model: $model"
        echo ""
        list_models
        exit 1
    fi

    log_info "Switching to model: $model"

    # Pull model if not already downloaded
    pull_model "$model" || exit 1

    # Update .env file
    set_model "$model"

    log_success "Successfully switched to $model"
    log_info "Model is now available in the web UI at http://localhost:3000"
}

# Show current status
status() {
    local current=$(get_current_model)
    echo "Current model: $current"
    echo "Description: $(get_model_description "$current")"

    # Check if containers are running
    if docker compose ps --services --filter status=running | grep -q ollama; then
        echo "Status: Running"
    else
        echo "Status: Stopped"
    fi
}

# Show help
show_help() {
    echo "Ollama Model Manager"
    echo
    echo "Usage: $0 {list|switch|pull|status|help} [MODEL]"
    echo
    echo "Commands:"
    echo "  list                    - Show available models"
    echo "  switch <model>         - Switch to a model (pulls if needed)"
    echo "  pull <model>           - Download a model"
    echo "  status                 - Show current model and status"  
    echo "  help                   - Show this help"
    echo
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 switch llama3.2:1b"
    echo "  $0 pull codellama:7b"
}

# Main command handling
case "${1:-help}" in
    list)
        list_models
        ;;
    switch)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 switch <model>"
            list_models
            exit 1
        fi
        switch_model "$2"
        ;;
    pull)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 pull <model>"
            list_models
            exit 1
        fi
        pull_model "$2"
        ;;
    status)
        status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
