#!/bin/bash
echo "in models.sh"
# aliases don't work in the same shell in which they are defined (maybe)
if ! command -v ollama >/dev/null 2>&1; then
  OLLAMA_CMD='docker exec -it ollama ollama'
else
  OLLAMA_CMD='ollama'
fi

$OLLAMA_CMD pull gemma3n:latest
$OLLAMA_CMD pull llama3.2:1b
$OLLAMA_CMD pull gemma3:1b
$OLLAMA_CMD pull gemma3n:e2b
