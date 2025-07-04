# ChezMoi Documentation

This directory contains the MkDocs documentation for the ChezMoi dotfiles project.

## Quick Start

1. Initialize the documentation environment:
   ```bash
   ./scripts/docs-init.sh
   ```

2. Serve documentation locally:
   ```bash
   ./scripts/docs-serve.sh
   ```
   Then visit http://localhost:8000

3. Build static documentation:
   ```bash
   ./scripts/docs-build.sh
   ```

## Deployment to AWS CloudFront

1. Create your AWS infrastructure using Terraform (in a separate project)
2. Copy `.env.example` to `.env` and configure:
   ```bash
   cp .env.example .env
   # Edit .env with your S3 bucket and CloudFront distribution ID
   ```

3. Deploy to AWS:
   ```bash
   ./scripts/docs-deploy.sh
   ```

## Project Structure

- `docs/` - Documentation source files in Markdown
- `mkdocs.yml` - MkDocs configuration
- `pyproject.toml` - Python project configuration for uv
- `scripts/` - Build and deployment scripts
- `site/` - Generated static site (git-ignored)

## Writing Documentation

- Follow the existing structure in `docs/`
- Use Markdown with MkDocs Material extensions
- Add new pages to the navigation in `mkdocs.yml`
- Preview changes with the local development server