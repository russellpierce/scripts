ollama > /dev/null 2>&1 || alias ollama='docker exec -it ollama ollama'
ollama pull gemma3n:latest
ollama pull llama3.2:1b
ollama pull gemma3:1b
ollama pull gemma3n:e2b