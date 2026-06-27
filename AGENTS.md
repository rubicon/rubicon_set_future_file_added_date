# Repository Guidelines

## Project Structure & Module Organization
- `rubicon_set_future_file_added_date.sh` is the primary entry point. It orchestrates argument parsing, target-date calculation, and embedded helper compilation.
- The on-demand helper binary is emitted to `~/.cache/set_added_date/` and reused across runs. Touch this script only; the helper source is generated inline.
- Place any future scripts beside the main file and keep auxiliary assets under a dedicated subdirectory (for example, `assets/` or `docs/`) to preserve a flat, discoverable root.

## Build, Test, and Development Commands
- `./rubicon_set_future_file_added_date.sh ./sample.txt`  
  Runs the script against a test file, building the helper if missing.
- `./rubicon_set_future_file_added_date.sh ./sample.txt --date "2035-11-06T14:29:09Z"`  
  Uses an explicit ISO-8601 UTC timestamp; helpful for repeatable tests.
- `shellcheck rubicon_set_future_file_added_date.sh`  
  Lints the Bash source; address warnings before opening a review.

## Coding Style & Naming Conventions
- Bash files use `#!/bin/bash`, `set -euo pipefail`, and two-space indentation.
- Functions are lower_snake_case (`die`, `CURRENT_STATE` stays uppercase for constants). Quote variables unless they are numeric counters.
- Prefer here-docs with single quotes for literal content, mirroring the embedded C block.
- Run `shfmt -i 2 -ci -w rubicon_set_future_file_added_date.sh` before submitting substantial shell edits.

## Testing Guidelines
- Manual smoke test: `touch scratch.txt && ./rubicon_set_future_file_added_date.sh scratch.txt --date "2033-01-01T00:00:00Z"`.
- Verify Finder metadata: `mdls -name kMDItemDateAdded -name kMDItemContentModificationDate scratch.txt`.
- Confirm filesystem view: `stat -f '%m %Sm' scratch.txt`. Capture before/after output in PR notes.
- Remove temporary artefacts after testing to avoid Spotlight cache noise.

## Commit & Pull Request Guidelines
- Write commits in imperative mood (`update helper verification`, `document testing flow`). Group unrelated changes into separate commits.
- Reference associated issues (e.g., `Refs #42`) and document the macOS version used for validation.
- PR description should include: summary, test commands with output snippets, and any observed limitations (e.g., Date Added refusal on recent macOS builds).
- Attach screenshots of Finder’s "Get Info" panel when demonstrating UI-visible changes.

## Configuration & Security Tips
- Ensure Xcode Command Line Tools (`cc`) are installed before running the script; failures early in CI often trace back to missing toolchains.
- The helper binary inherits user permissions; avoid running the script against files requiring elevated privileges.
- If Date Added updates are blocked, note the macOS build in your report so we can track OS regressions.
