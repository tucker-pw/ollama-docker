#!/usr/bin/env bash

# HuggingFace Model Download Script
# Downloads GGUF models from HuggingFace and imports them into Ollama
# This bypasses corporate VPN/certificate issues that affect Ollama registry downloads

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODEL=${1:-llama3.2:1b}

echo -e "${BLUE}HuggingFace Model Download${NC}"
echo -e "${YELLOW}Downloading $MODEL from HuggingFace (bypasses VPN/certificate issues)${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q ollama; then
    echo -e "${RED}Error: ollama container is not running${NC}"
    echo "Run: make start"
    exit 1
fi

# Map model names to HuggingFace URLs and sizes
case "$MODEL" in
    llama3.2:1b)
        HF_URL="https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf?download=true"
        GGUF_FILE="llama3.2-1b.gguf"
        SIZE="770MB"
        ;;
    llama3.2:3b)
        HF_URL="https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf?download=true"
        GGUF_FILE="llama3.2-3b.gguf"
        SIZE="2GB"
        ;;
    *)
        echo -e "${RED}Error: Model $MODEL not supported for HuggingFace download${NC}"
        echo -e "${YELLOW}Supported models:${NC}"
        echo "  - llama3.2:1b (~770MB)"
        echo "  - llama3.2:3b (~2GB)"
        echo ""
        echo -e "${YELLOW}For other models, try:${NC}"
        echo "  docker exec ollama ollama pull $MODEL"
        exit 1
        ;;
esac

echo -e "${BLUE}Downloading $MODEL ($SIZE) from HuggingFace...${NC}"
echo -e "${YELLOW}This may take several minutes depending on your connection${NC}"
echo ""

# Download GGUF model from HuggingFace
cd /tmp
if ! curl -L -o "$GGUF_FILE" "$HF_URL"; then
    echo -e "${RED}Download failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Download complete!${NC}"
echo -e "${BLUE}Creating Modelfile...${NC}"

# Create Modelfile for Ollama
cat > /tmp/Modelfile <<EOF
FROM /tmp/$GGUF_FILE

TEMPLATE """{{- if .System }}
<|system|>
{{ .System }}</s>
{{- end }}
<|user|>
{{ .Prompt }}</s>
<|assistant|>
"""

PARAMETER stop <|endoftext|>
PARAMETER stop <|eot_id|>
PARAMETER temperature 0.7
PARAMETER top_p 0.9
EOF

echo -e "${BLUE}Copying files to ollama container...${NC}"

# Copy files to container
docker cp "$GGUF_FILE" ollama:/tmp/
docker cp /tmp/Modelfile ollama:/tmp/

echo -e "${BLUE}Importing model into Ollama...${NC}"

# Import model into Ollama
if docker exec ollama ollama create "$MODEL" -f /tmp/Modelfile; then
    echo ""
    echo -e "${GREEN}Success! Model $MODEL is now available${NC}"
    echo -e "You can use it in the Web UI at ${BLUE}http://localhost:3000${NC}"
    echo ""
    echo -e "${BLUE}Cleaning up temporary files...${NC}"
    rm -f "/tmp/$GGUF_FILE" /tmp/Modelfile
    docker exec ollama rm -f "/tmp/$GGUF_FILE" /tmp/Modelfile 2>/dev/null || true
    echo -e "${GREEN}Done!${NC}"
else
    echo -e "${RED}Failed to import model${NC}"
    rm -f "/tmp/$GGUF_FILE" /tmp/Modelfile
    exit 1
fi