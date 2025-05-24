#!/usr/bin/env bash

export OLLAMA_HOST=10.1.200.123
export OLLAMA_API_BASE="http://${OLLAMA_HOST}:11434"
#       OLLAMA_API_BASE

# aider --model openrouter/deepseek/deepseek-r1
aider \
    --subtree-only \
    --model ollama_chat/deepseek-coder-v2:16b

# aider --model openrouter/meta-llama/llama-3-8b-instruct:free
# aider --model openrouter/openai/o1
# aider --model ollama/qwen2.5-coder:32b
