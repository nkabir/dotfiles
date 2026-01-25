# Seed
_Repeatable Developer Environments_

* [Documentation](https://tinyurl.com/cwid-seed-reference)

These settings must only apply to a user and their development
host. Settings for realms and repositories must be configured in those
environments directly.

**This is not intended to be run in constrained, air-gapped
environments.**

## Roots

* blackbox - open source resource
* sandbox - experiments that are regularly cleared

## Forking and layering

Goal: keep a private personal layer on top of a shared base, pull upstream
updates safely, and still contribute changes back.

### Key constraint
GitHub does not allow a private fork of a public repo. Use a private repo
for personal changes and a public fork only for PRs.

### Recommended structure
1) Public fork for PRs
   - Fork `cwiq-seed/dotfiles` to `nkabir/dotfiles` (public).
   - This repo stays clean and only contains changes to upstream.

2) Private layered repo (primary chezmoi source)
   - Create a private repo that tracks the shared base as `upstream`.
   - Keep all personal changes here.

```bash
git clone git@github.com:cwiq-seed/dotfiles.git ~/src/dotfiles-private
cd ~/src/dotfiles-private

git remote rename origin upstream
git remote add public git@github.com:nkabir/dotfiles.git
```

3) Branch strategy
   - `upstream/*` tracks the shared base.
   - `personal` holds private changes.
   - `contrib/*` is used for PR-ready changes.

```bash
git fetch upstream
git switch -c personal upstream/develop   # or main if base uses main
```

When the base updates:

```bash
git fetch upstream
git rebase upstream/develop
```

When you want to contribute:

```bash
git switch -c contrib/some-change upstream/develop
git cherry-pick <commit(s)-from-personal>
git push public contrib/some-change
```

### Chezmoi layering tips
- Keep shared content and personal content separate by directory naming
  or prefixes (for example, personal content under `blackbox/dot_local/gig`).
- Use `private_` and age encryption for sensitive files so they never leak
  in PRs.
- If you want hard separation, keep `shared/` vs `personal/` subtrees and
  use `.chezmoiignore` to control what gets committed where.

## Suggested layout (shared vs personal)
This keeps personal content isolated so it is easy to exclude from PRs.

```
blackbox/
  shared/                     # Upstream-compatible content
    dot_config/
    dot_local/
    dot_scripts/
  personal/                   # Private overrides and additions
    dot_config/
    dot_local/
    dot_scripts/
    private_dot_ssh/
```

Conventions:
- Only submit changes under `blackbox/shared` to the public fork.
- Keep private changes under `blackbox/personal`.
- Use `private_` prefixes in `blackbox/personal` for secrets.
- Use `.chezmoiignore` to exclude `blackbox/personal` from public PRs.

## Git hook to block private pushes
The pre-push hook blocks pushes to the public fork if private paths or
secret-prefixed files are staged.

Setup:
```bash
git config core.hooksPath .githooks
```
