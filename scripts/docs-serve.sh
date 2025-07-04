#!/usr/bin/env bash
set -euo pipefail

# Serve MkDocs documentation locally using uv

cd "$(dirname "$0")/.."

echo "Starting MkDocs development server..."
source .venv/bin/activate
mkdocs serve --dev-addr 0.0.0.0:8000