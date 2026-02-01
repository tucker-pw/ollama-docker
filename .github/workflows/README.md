# GitHub Actions Workflows

This directory contains CI/CD workflows for the Ollama Docker project.

## validation.yml

Lightweight validation workflow that ensures Docker Compose configurations are correct and project structure is sound.

### When It Runs

- **Pull requests** to main/develop branches
- **File changes** to: `docker-compose*.yml`, `scripts/**`, `Makefile`, `.env`

### What It Tests

**Documentation & Structure:**
- Required documentation files exist (`README.md`, `docs/`)
- All shell scripts have correct syntax and executable permissions
- Makefile syntax and available targets

**Docker Compose Validation:**
- YAML syntax validation for all compose files
- Service structure verification (ollama, webui, tts services exist)
- Port mapping validation (11434, 3000, 8880)
- Volume configuration checks
- GPU configuration detection (NVIDIA only - AMD support removed)

**Lightweight Service Testing:**
- Service connectivity simulation using nginx/httpd
- API endpoint structure validation
- Inter-service communication patterns
- Dependency chain verification

### Test Matrix

- **Base Config**: `docker-compose.yml` - validates main configuration (CPU mode)
- **GPU Override**: `docker-compose.gpu.yml` - validates NVIDIA GPU runtime configuration

### Validation Jobs

1. **validate-documentation** - Checks required files exist
2. **validate-scripts** - Tests shell script syntax and permissions  
3. **validate-compose-syntax** - Validates Docker Compose YAML files
4. **test-lightweight-services** - Simulates service connectivity
5. **validate-make-targets** - Tests Makefile target syntax

### Why Lightweight Testing?

This workflow prioritizes **fast, reliable validation** over comprehensive integration testing:

- ✅ **No large image downloads** (Ollama images are 1-4GB)
- ✅ **No GPU dependencies** (not available in CI runners)
- ✅ **Quick feedback** (~5 minutes vs 20+ minutes)
- ✅ **Reliable results** (no network timeouts or hardware issues)

### What It Validates

**Configuration Correctness:**
- Docker Compose files parse without errors
- All required services are defined
- Port mappings match expected values
- Volume configurations are present
- GPU settings are properly configured

**Code Quality:**
- Shell scripts have valid syntax
- Scripts have executable permissions
- Makefile targets are syntactically correct
- Documentation structure is complete

**Service Architecture:**
- Services can communicate (simulated)
- Dependency relationships are correct
- API endpoints are structured properly

### What It Doesn't Test

- **Actual GPU functionality** (requires specialized hardware)
- **Model downloading/loading** (too large/slow for CI)
- **Real Ollama inference** (resource intensive)
- **Audio/TTS generation** (requires audio hardware)
- **Full integration** (browser testing, complex workflows)

### Adding New Components

To add validation for new services or configurations:

1. **New compose file**: Add to `validate-compose-syntax` matrix
2. **New script**: Automatically tested if placed in `scripts/` directory
3. **New service**: Add port/health check to `test-lightweight-services`
4. **New documentation**: Add file check to `validate-documentation`

### Local Testing

Run similar validations locally:

```bash
# Validate Docker Compose syntax
docker compose -f docker-compose.yml config --quiet
docker compose -f docker-compose.gpu.yml config --quiet

# Check script syntax
bash -n scripts/*.sh

# Test Makefile
make -n help

# Verify file structure
ls docs/ scripts/ README.md
```

### Integration Testing Locally

For full integration testing with real services:

```bash
# CPU mode (default)
make setup
make status

# GPU mode (Linux with NVIDIA GPU only)
make setup-gpu
make status

# Test APIs
curl http://localhost:11434/api/tags
curl http://localhost:3000
curl http://localhost:8880/v1/models
```

### Debugging Failed Builds

Common failure patterns and solutions:

**YAML Syntax Errors:**
```bash
# Check locally
docker compose config
# Fix indentation, quotes, or structure
```

**Script Syntax Errors:**
```bash
# Check scripts locally
bash -n scripts/problematic-script.sh
# Fix shell syntax issues
```

**Missing Files:**
```bash
# Ensure required files exist
ls README.md docs/INSTALLATION.md docs/USAGE.md
ls scripts/setup.sh scripts/model-manager.sh scripts/cleanup.sh scripts/download-model-hf.sh
```

**Service Configuration Issues:**
```bash
# Validate service definitions
docker compose config --services
# Check port mappings and dependencies
```

### Workflow Philosophy

This workflow follows the principle of **"validate early, validate often"** by:

- Catching configuration errors before deployment
- Ensuring consistent project structure
- Validating service architecture without resource overhead
- Providing fast feedback to contributors
- Maintaining reliability across different environments

The workflow complements local testing rather than replacing it, giving you confidence that your configurations will work when deployed to real hardware.
