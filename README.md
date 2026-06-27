# Set Future Finder Dates

This repository provides a macOS helper script for adjusting Finder metadata on files. It focuses on setting both the "Date Added" (when permitted by the operating system) and "Date Modified" timestamps to a desired future instant.

## Quick Start

```bash
./rubicon_set_future_file_added_date.sh /path/to/file \
  --date "2035-11-06T14:29:09Z"
```

If no `--date` flag is supplied, the script defaults to 10 years in the future.

## Requirements

- macOS with Xcode Command Line Tools (`cc`)
- `mdls`, `mdimport`, `touch`, `stat`, and `date` available in `$PATH`

When run, the script compiles a small helper binary into `~/.cache/set_added_date/` that attempts to change the Finder "Date Added" attribute.
