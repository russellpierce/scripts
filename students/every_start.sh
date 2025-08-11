#!/bin/bash

OLLAMA_COUNT=$(ps aux | awk '{  print $1 }' | grep 'ollama' | wc -l)

if [ "$OLLAMA_COUNT" -ne 1 ]; then
    if [ "$OLLAMA_COUNT" -gt 1 ]; then
        pkill ollama || echo "Was unable to kill ollama"
    fi
    ollama serve || echo "Was unable to start ollama"
else
    echo "ollama is already running"
fi