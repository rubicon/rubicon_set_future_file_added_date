# CLAUDE.md

Primary agent context for this repository. macOS-only Bash CLI that sets a file's
Finder **Date Added** (best-effort) and filesystem **Date Modified** (mtime) to a
target instant.

## Project Structure

- `rubicon_set_future_file_added_date.sh` — the only entry point. Parses args,
  computes the target date, and (unless `--no-added`) generates + compiles an inline
  C helper to set Date Added. Edit this script only; the helper source is emitted inline.
- `test/smoke.bats` — bats smoke tests.
- `Makefile` — canonical dev interface (see Commands).
- `.github/workflows/` — `ci.yaml` (lint/format/test) and `release.yaml` (release-please).
- Keep the root flat; put any future assets under a dedicated subdir (e.g. `docs/`).

## Commands

Prefer the `make` targets — they are the canonical interface used by CI:

```bash
make setup   # verify shellcheck, shfmt, bats are installed
make fmt     # shfmt -w .
make lint    # shellcheck rubicon_set_future_file_added_date.sh
make test    # bats -r test
make all     # fmt + lint + test
sudo make install   # install as `rubicon-set-date` to /opt/homebrew/bin (Apple Silicon) or /usr/local/bin
```

Install tools: `brew install shellcheck shfmt bats-core`

## Usage

```bash
./rubicon_set_future_file_added_date.sh <file> [--date "<ISO8601-UTC>"] [--no-added]
```

- `--date` — ISO 8601 UTC, e.g. `2035-11-06T14:29:09Z`. If omitted, defaults to **now + 10 years** (kept under 2038).
- `--no-added` — set only Date Modified (mtime); skip the Date Added helper (no compiler needed).

## Testing (manual smoke)

```bash
touch scratch.txt && ./rubicon_set_future_file_added_date.sh scratch.txt --date "2033-01-01T00:00:00Z"
mdls -name kMDItemDateAdded -name kMDItemContentModificationDate scratch.txt   # Spotlight view
stat -f '%m %Sm' scratch.txt                                                    # filesystem view
rm scratch.txt   # clean up to avoid Spotlight cache noise
```

Capture before/after `mdls`/`stat` output in PR notes.

## Code Style

- `#!/bin/bash`, `set -euo pipefail`, two-space indentation.
- Functions `lower_snake_case`; constants UPPERCASE. Quote variables unless they are numeric counters.
- Single-quoted here-docs for literal content (mirrors the embedded C block).
- Run `make fmt` (shfmt `-i 2 -ci`) and `make lint` before committing.

## Gotchas

- **Date Added is best-effort.** On modern macOS it is often blocked; the script reports the actual result. Note the macOS build in reports so OS regressions can be tracked.
- **C helper requires Xcode Command Line Tools** (`cc`). It is compiled on first run (unless `--no-added`) to `~/.cache/rubicon_set_future_file_added_date/rubicon_set_added_date_v2` and reused across runs. Missing toolchain is the most common early failure.
- **macOS may clamp impossible future mtimes**; the script reports the clamped value.
- **Spotlight updates are async**; the script runs `mdimport -f` to force reindex before verifying.
- Required tools checked at startup: `mdls`, `mdimport`, `touch`, `stat`, `date`.

## Commit & PR

- Conventional Commits, imperative mood; automated releases via release-please.
- Reference issues (e.g. `Refs #42`) and record the macOS version used for validation.
- PRs: summary, test commands with output snippets, observed limitations. See [CONTRIBUTING.md](CONTRIBUTING.md).
