# rubicon_set_future_file_added_date

A tiny, focused macOS CLI that sets a file’s Finder **Date Added** (and aligns **Date Modified**) to a specified instant — useful for demos, data migration testing, and forensic reproducibility experiments.

> Works on macOS only. Requires Xcode Command Line Tools for a small helper build step.

## Features
- Set Finder **Date Added** to an exact timestamp
- Align filesystem **Date Modified** (mtime) accordingly and report any OS clamping
- Idempotent and chatty: prints before/after from both Spotlight (`mdls`) and filesystem (`stat`)
- No external deps beyond standard macOS toolchain

## Quickstart
```bash
# clone
git clone https://github.com/<org>/rubicon_set_future_file_added_date.git
cd rubicon_set_future_file_added_date

# run
./rubicon_set_future_file_added_date.sh /path/to/file --date "2035-11-06T14:29:09Z"
```

If `--date` is omitted, the script defaults to **10 years in the future**. **Needs Verification**: default policy alignment with your use case.

## Install (optional symlink)
```bash
sudo make install     # installs to /usr/local/bin (or /opt/homebrew/bin on Apple Silicon)
rubicon-set-date --help
```

## Usage
```bash
./rubicon_set_future_file_added_date.sh <file> [--date "<ISO8601>"]
```

- `--date` accepts ISO 8601, e.g. `2025-12-31T23:59:59Z`. Local times are parsed by macOS `date` and converted to UTC. **Needs Verification**: locales other than en_US.UTF-8.

### Behavior Notes
- macOS may clamp impossible future mtimes; the script reports the actual result.
- Spotlight metadata updates can be asynchronous; this script queries after changes to verify effective state.

## Badges
[![CI](https://github.com/<org>/rubicon_set_future_file_added_date/actions/workflows/ci.yml/badge.svg)](https://github.com/<org>/rubicon_set_future_file_added_date/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/<org>/rubicon_set_future_file_added_date)](https://github.com/<org>/rubicon_set_future_file_added_date/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/<org>/rubicon_set_future_file_added_date)](https://github.com/<org>/rubicon_set_future_file_added_date/commits)

Replace `<org>` with your GitHub org/user. **Needs Verification.**

## Development
```bash
# format & lint
make fmt
make lint

# run tests (smoke tests only)
make test
```

### Tooling
- **shfmt** for formatting
- **shellcheck** for static analysis
- **bats** for tests
- **release-please** for conventional-commit driven releases

Install on macOS:
```bash
brew install shellcheck shfmt bats-core
```

## Contributing
We use Conventional Commits and automated releases. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security
Please report vulnerabilities via the process in [SECURITY.md](SECURITY.md). No guarantees are made; see [LICENSE](LICENSE).

## License
MIT © 2025 Dax Davis

## Social Preview
Set a repository social preview image for better share cards. Suggested: a Finder window with a highlighted “Date Added” field and a forward arrow motif.
