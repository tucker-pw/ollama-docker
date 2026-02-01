# Ollama Project Makefile
# Usage: make <command> [arguments]

.PHONY: help setup start stop restart status logs chat clean reset
.PHONY: list-models pull switch
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[36m
GREEN := \033[32m  
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Get additional arguments (for model names, etc.)
ARGS := $(filter-out $@,$(MAKECMDGOALS))

# Prevent make from treating arguments as targets
%:
	@:

help: ## Show this help message
	@printf "$(BLUE)Ollama Project$(RESET)\n"
	@printf "======================\n"
	@printf "$(GREEN)Setup & Control:$(RESET)\n"
	@printf "  $(YELLOW)make setup$(RESET)          - Initial setup (CPU mode)\n"
	@printf "  $(YELLOW)make setup-gpu$(RESET)      - Initial setup with NVIDIA GPU\n"
	@printf "  $(YELLOW)make start$(RESET)          - Start services (CPU mode)\n"
	@printf "  $(YELLOW)make start-gpu$(RESET)      - Start with GPU support\n"
	@printf "  $(YELLOW)make stop$(RESET)           - Stop all services\n"
	@printf "  $(YELLOW)make restart$(RESET)        - Restart all services\n"
	@printf "  $(YELLOW)make status$(RESET)         - Show service status\n"
	@printf "  $(YELLOW)make logs$(RESET)           - Show service logs\n"
	@printf "\n"
	@printf "$(GREEN)Model Management:$(RESET)\n"
	@printf "  $(YELLOW)make list-models$(RESET)    - List available models\n"
	@printf "  $(YELLOW)make switch MODEL$(RESET)   - Switch to a model (e.g., make switch llama3.2:1b)\n"
	@printf "  $(YELLOW)make pull MODEL$(RESET)     - Download a model\n"
	@printf "  $(YELLOW)make pull-hf MODEL$(RESET)  - Download from HuggingFace (bypasses VPN/cert issues)\n"
	@printf "\n"
	@printf "$(GREEN)Usage:$(RESET)\n"
	@printf "  $(YELLOW)make web$(RESET)            - Open web UI (http://localhost:3000)\n"
	@printf "\n"
	@printf "$(GREEN)Model Shortcuts:$(RESET)\n"
	@printf "  $(YELLOW)make cpu$(RESET)            - CPU-optimized model (llama3.2:1b - default)\n"
	@printf "  $(YELLOW)make gpu$(RESET)            - GPU-optimized model (llama3.2:3b)\n"
	@printf "  $(YELLOW)make quality$(RESET)        - Best quality (llama3.2:11b - requires GPU)\n"
	@printf "  $(YELLOW)make code$(RESET)           - Code-focused (codellama:7b - requires GPU)\n"
	@printf "\n"
	@printf "$(GREEN)Cleanup:$(RESET)\n"
	@printf "  $(YELLOW)make clean$(RESET)          - Clean up project containers/volumes\n"
	@printf "  $(YELLOW)make reset$(RESET)          - Full reset (with confirmation)\n"
	@printf "\n"
	@printf "$(GREEN)Examples:$(RESET)\n"
	@printf "  make setup\n"
	@printf "  make switch llama3.2:11b\n"
	@printf "  make web\n"

# Setup & Control Commands
setup: ## Initial setup and start (CPU mode)
	@printf "$(BLUE)Setting up Ollama Project (CPU mode)...$(RESET)\n"
	@bash scripts/setup.sh setup

setup-gpu: ## Initial setup with NVIDIA GPU support
	@printf "$(BLUE)Setting up Ollama Project (GPU mode)...$(RESET)\n"
	@printf "$(YELLOW)Note: Requires NVIDIA GPU + nvidia-container-toolkit$(RESET)\n"
	@bash scripts/setup.sh setup-gpu

start: ## Start all services (CPU mode)
	@printf "$(BLUE)Starting services...$(RESET)\n"
	@bash scripts/setup.sh start

start-gpu: ## Start all services with GPU support
	@printf "$(BLUE)Starting services with GPU support...$(RESET)\n"
	@bash scripts/setup.sh start-gpu

stop: ## Stop all services
	@printf "$(BLUE)Stopping services...$(RESET)\n"
	@bash scripts/setup.sh stop

restart: ## Restart all services
	@printf "$(BLUE)Restarting services...$(RESET)\n"
	@docker compose restart

status: ## Show service status
	@printf "$(BLUE)Service Status:$(RESET)\n"
	@bash scripts/setup.sh status
	@printf "\n"
	@printf "$(BLUE)Current Model:$(RESET)\n"
	@bash scripts/model-manager.sh status

logs: ## Show service logs
	@bash scripts/setup.sh logs

# Model Management Commands  
list-models: ## List available models
	@bash scripts/model-manager.sh list

pull: ## Download a model (usage: make pull llama3.2:1b)
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		printf "$(RED)Error: Please specify a model$(RESET)\n"; \
		printf "Usage: make pull <model>\n"; \
		printf "Example: make pull llama3.2:1b\n"; \
		bash scripts/model-manager.sh list; \
	else \
		bash scripts/model-manager.sh pull $(filter-out $@,$(MAKECMDGOALS)); \
	fi

pull-hf: ## Download from HuggingFace (bypasses VPN/cert issues)
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		printf "$(RED)Error: Please specify a model$(RESET)\n"; \
		printf "Usage: make pull-hf <model>\n"; \
		printf "Example: make pull-hf llama3.2:1b\n"; \
		printf "$(YELLOW)Currently supported: llama3.2:1b, llama3.2:3b$(RESET)\n"; \
	else \
		bash scripts/download-model-hf.sh $(filter-out $@,$(MAKECMDGOALS)); \
	fi

switch: ## Switch to a model (usage: make switch llama3.2:11b)
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		printf "$(RED)Error: Please specify a model$(RESET)\n"; \
		printf "Usage: make switch <model>\n"; \
		printf "Example: make switch llama3.2:11b\n"; \
		bash scripts/model-manager.sh list; \
	else \
		bash scripts/model-manager.sh switch $(filter-out $@,$(MAKECMDGOALS)); \
	fi

# Usage Commands
web: ## Show web UI URL
	@printf "$(BLUE)Web UI available at:$(RESET)\n"
	@printf "$(GREEN)http://localhost:3000$(RESET)\n"
	@printf "\n"
	@printf "$(YELLOW)Make sure services are running first (make start)$(RESET)\n"

# Cleanup Commands
clean: ## Clean up project containers and volumes
	@printf "$(BLUE)Cleaning up project...$(RESET)\n"
	@bash scripts/cleanup.sh quick
	@printf "$(BLUE)Removing unused networks...$(RESET)\n"
	@docker network prune -f
	@printf "$(GREEN)Cleanup complete$(RESET)\n"

reset: ## Full reset with confirmation
	@printf "$(YELLOW)This will completely reset your project!$(RESET)\n"
	@bash scripts/cleanup.sh reset

# Development shortcuts
dev: start web ## Start services and show web UI link

quick-switch: ## Quick switch to llama3.2:3b (balanced model)
	@bash scripts/model-manager.sh switch llama3.2:3b

# Check if required files exist
check-setup:
	@if [ ! -f "scripts/setup.sh" ] || [ ! -f "scripts/model-manager.sh" ] || [ ! -f "scripts/cleanup.sh" ]; then \
		echo "$(RED)Error: Required script files not found in scripts/ directory$(RESET)"; \
		exit 1; \
	fi

# Make scripts executable
fix-permissions: ## Make all scripts executable
	@echo "$(BLUE)Making scripts executable...$(RESET)"
	@chmod +x scripts/*.sh
	@echo "$(GREEN)Done!$(RESET)"

# Popular model shortcuts (for convenience)
default: ## Switch to default model (llama3.2:1b - CPU friendly)
	@bash scripts/model-manager.sh switch llama3.2:1b

cpu: ## Switch to CPU-optimized model (llama3.2:1b)
	@bash scripts/model-manager.sh switch llama3.2:1b

gpu: ## Switch to GPU-optimized model (llama3.2:3b)  
	@bash scripts/model-manager.sh switch llama3.2:3b

quality: ## Switch to highest quality model (llama3.2:11b - requires GPU)
	@bash scripts/model-manager.sh switch llama3.2:11b

code: ## Switch to code-focused model (codellama:7b - requires GPU)
	@bash scripts/model-manager.sh switch codellama:7b

# Legacy shortcuts (for backward compatibility)
fast: cpu ## Alias for cpu (backward compatibility)

balanced: gpu ## Alias for gpu (backward compatibility)

demo: start web ## Start services and show web UI link
	@printf "$(GREEN)Demo ready! Services starting...$(RESET)\n"

# Show current configuration
config: ## Show current configuration
	@printf "$(BLUE)Current Configuration:$(RESET)\n"
	@echo "Model: $(grep OLLAMA_MODEL .env 2>/dev/null | cut -d'=' -f2 || echo 'Not set')"
	@echo "Host: $(grep OLLAMA_HOST .env 2>/dev/null | cut -d'=' -f2 || echo 'Not set')"
	@echo ""
	@bash scripts/setup.sh status 2>/dev/null || echo "Services not running"
