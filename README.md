# Rubicon: Set Future File Added Date

A tiny, focused macOS CLI that sets a file’s Finder **Date Added** (and aligns **Date Modified**) to a specified instant — useful for demos, metadata control, Dock behavior tuning, and automation workflows.

> Works on macOS only. Requires Xcode Command Line Tools for a small helper build step.

## Features

- Set Finder **Date Added** to an exact timestamp
- Align filesystem **Date Modified** (mtime) accordingly and report any OS clamping
- Idempotent and chatty: prints before/after from both Spotlight (`mdls`) and filesystem (`stat`)
- No external deps beyond standard macOS toolchain

## Common Use Cases

- **Dock Overlay Icons** — Set file “Date Added” timestamps to control the sort order and overlay indicators in your **Downloads stack** or Dock folders. Perfect for showcasing files at the top without renaming them.
- **Demo Preparation** — Stage datasets, screenshots, or project assets so they appear freshly added.
- **Data Migration Testing** — Validate timestamp preservation or system behavior with future or synthetic dates.
- **Forensics & Metadata Research** — Explore how macOS stores and displays time-based metadata across versions.

## Quickstart

```bash
# clone
git clone https://github.com/rubicon/rubicon_set_future_file_added_date.git
cd rubicon_set_future_file_added_date

# run
./rubicon_set_future_file_added_date.sh /path/to/file --date "2035-11-06T14:29:09Z"
```

If `--date` is omitted, the script defaults to **10 years in the future**.  
**Needs Verification:** confirm the default offset matches your version of macOS.

## Install (optional symlink)

```bash
sudo make install     # installs to /usr/local/bin (or /opt/homebrew/bin on Apple Silicon)
rubicon-set-date --help
```

## Usage

```bash
./rubicon_set_future_file_added_date.sh <file> [--date "<ISO8601>"]
```

- `--date` accepts ISO 8601, e.g. `2025-12-31T23:59:59Z`.  
  Local times are parsed by macOS `date` and converted to UTC.  
  **Needs Verification:** locale handling for non-`en_US.UTF-8`.

### Behavior Notes

- macOS may clamp impossible future mtimes; the script reports the actual result.
- Spotlight metadata updates can be asynchronous; this script reindexes and verifies the final state.

## Badges

[![CI](https://github.com/rubicon/rubicon_set_future_file_added_date/actions/workflows/ci.yml/badge.svg)](https://github.com/rubicon/rubicon_set_future_file_added_date/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/rubicon/rubicon_set_future_file_added_date)](https://github.com/rubicon/rubicon_set_future_file_added_date/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/rubicon/rubicon_set_future_file_added_date)](https://github.com/rubicon/rubicon_set_future_file_added_date/commits)

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
- **bats** for lightweight testing
- **release-please** for automated versioning and changelog updates

Install tools on macOS:

```bash
brew install shellcheck shfmt bats-core
```

## Contributing

We use Conventional Commits and automated releases.  
See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Security

Please report vulnerabilities responsibly through [SECURITY.md](SECURITY.md).  
No guarantees are made; see [LICENSE](LICENSE) for terms.

## License

MIT © 2025 Dax Davis

## Social Preview

For better share cards, set a repository social preview image — for example,  
a Finder window with a highlighted **Date Added** column and a subtle forward arrow motif.
