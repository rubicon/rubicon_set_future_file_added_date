# Contributing

Thanks for pitching in! This repo is small, sharp, and safe by default.

## Workflow
- Fork → feature branch → PR into `main`.
- Use **Conventional Commits** (e.g., `feat:`, `fix:`, `docs:`).
- Include tests for behavior changes (bats).
- Update docs and `CHANGELOG.md` when user-visible.

## Dev Quickstart
```bash
brew install shellcheck shfmt bats-core
make setup   # optional: verifies tools
make test
```

## Commit Messages
- `feat:` new user-visible features
- `fix:` bug fixes
- `docs:` README etc.
- `chore:` CI, deps, no behavior change
- `refactor:` behavior preserved

## Code Style
- `shfmt` enforced
- `shellcheck` passes (use `# shellcheck disable=SCXXXX` sparingly, with a comment)

## Releases
Automated via release-please on merge to `main`. The bot proposes a release PR; merging creates a GitHub Release and bumps changelog.
