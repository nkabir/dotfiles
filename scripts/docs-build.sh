#!/usr/bin/env bash
set -euo pipefail

# Build MkDocs documentation using uv

cd "$(dirname "$0")/.."

echo "Building MkDocs documentation..."
source .venv/bin/activate
mkdocs build --strict

echo "Documentation built in ./site/"