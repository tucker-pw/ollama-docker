# Changelog

## Cleanup & Optimization (2025-10-27)

### Summary

This release focuses on reliability, cross-platform compatibility, and user experience improvements. The biggest change is **HuggingFace becomes the default model source**, solving certificate/VPN issues that affected many users. Setup is now truly one command across all platforms.

**Key Improvements:**
- One-command setup that actually works on all platforms
- HuggingFace downloads bypass corporate VPN/certificate issues
- Web UI health checks prevent premature access
- Removed AMD support to simplify codebase
- Cleaner, more maintainable code

### Breaking Changes
- **Removed AMD GPU support** - Simplified to NVIDIA GPU only (Linux) or CPU mode
- **Changed default mode to CPU** - Works on all platforms including macOS/Windows
- **GPU mode now requires explicit flag** - Use `make setup-gpu` instead of `make setup`
- **HuggingFace is now default** - `make setup` automatically downloads models from HuggingFace instead of Ollama registry

### Added
- **HuggingFace model downloads** - New `make pull-hf` command and `scripts/download-model-hf.sh`
  - Bypasses corporate VPN/certificate issues
  - Works reliably on all platforms
  - Default behavior for `make setup` and `make setup-gpu`
- **Open WebUI health check** - Python-based health check ensures Web UI is ready before use
- **CPU-first architecture** - Default CPU mode works on all platforms
- **Optional GPU support** - `docker-compose.gpu.yml` override for NVIDIA GPUs (Linux only)
- **New commands**:
  - `make setup-gpu` - Setup with GPU acceleration (Linux only)
  - `make start-gpu` - Start services with GPU
  - `make pull-hf MODEL` - Download models from HuggingFace (bypasses VPN/cert issues)
- **Better health checks** - Uses native commands instead of curl/wget
- **`.env.example`** - Template for environment configuration
- **`.gitignore`** - Proper git ignore patterns

### Changed
- **macOS compatible** - Fixed `sed` compatibility, echo formatting
- **Bash 3.2 compatible** - Refactored scripts for older Bash versions
- **Improved error handling** - Better validation and error messages
- **Updated all documentation** - README, INSTALLATION.md, USAGE.md fully updated
- **Simplified Docker config** - Removed Linux-specific audio mounts for cross-platform compatibility
- **Model definitions consolidated** - Single source of truth for available models

### Removed
- `docker-compose-amd.yml` - AMD GPU configuration
- `scripts/setup-amd.sh` - AMD setup script
- `docs/AMD-GPU-SUPPORT.md` - AMD documentation
- `docs/MACOS-SETUP.md` - No longer needed with HuggingFace default downloads
- Linux-specific audio device mounts (commented out, can be re-enabled)

### Fixed
- **macOS `echo -e` issue** - Replaced with `printf` for cross-platform compatibility
- **Health check failures** - Using commands that exist in containers
- **Audio device errors on macOS** - Made audio devices optional
- **Certificate errors** - Added troubleshooting for macOS TLS issues
- **Model list compatibility** - Works on Bash 3.2+ (macOS default)

## Migration Guide

### From Previous Version

**If you were using CPU mode:**
```bash
# Old
make setup

# New (same command, but now explicitly CPU mode)
make setup
```

**If you were using NVIDIA GPU (Linux):**
```bash
# Old
make setup

# New
make setup-gpu
```

**If you were using AMD GPU:**
AMD GPU support has been removed. Use CPU mode:
```bash
make setup
```

### Environment Setup
Create `.env` file from template:
```bash
cp .env.example .env
# Edit .env to customize
```

### Existing Installations
To upgrade, clean and reinstall:
```bash
make clean      # Or make reset for complete clean
make setup      # Or make setup-gpu for GPU mode
```

## Platform Support

- **macOS**: CPU mode (excellent performance on Apple Silicon)
- **Linux**: CPU mode or GPU mode (NVIDIA only)
- **Windows**: CPU mode via Docker Desktop

## Coming Next

Planned features for future releases:
- MCP franken-server implementation (multi-model orchestration)
- Enhanced model management
- Performance optimizations
