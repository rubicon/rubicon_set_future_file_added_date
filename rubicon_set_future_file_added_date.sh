#!/bin/bash
# rubicon_set_future_file_added_date.sh
# macOS: Set Finder "Date Added" (best-effort) and "Date Modified" to a target date.
# Default: now + 10 years (keeps us under 2038).
#
# Usage:
#   rubicon_set_future_file_added_date.sh <file> [--date "YYYY-MM-DDTHH:MM:SSZ"] [--no-added]
#
# Behavior:
# - Always sets filesystem "Date Modified" (mtime) to the target instant.
# - Best-effort set for Finder "Date Added"; on modern macOS, this is often blocked.
# - Forces Spotlight to refresh so mdls reflects changes.
#
set -euo pipefail
die() {
  echo "Error: $*" >&2
  exit 1
}

[[ $# -ge 1 ]] || die "Usage: $0 <file> [--date ISO8601_UTC] [--no-added]"
FILE=$1
shift || true
TRY_ADDED=1
TARGET_ISO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --date)
    shift
    TARGET_ISO="${1:-}"
    [[ -n "$TARGET_ISO" ]] || die "--date requires an ISO8601 UTC like 2035-11-06T14:29:09Z"
    ;;
  --no-added) TRY_ADDED=0 ;;
  *) die "Unknown arg: $1" ;;
  esac
  shift || true
done

for cmd in mdls mdimport touch stat date; do
  command -v "$cmd" >/dev/null || die "$cmd is required"
done
[[ -e "$FILE" ]] || die "'$FILE' not found"

# ---------- Target Time ----------
if [[ -z "$TARGET_ISO" ]]; then
  TARGET_ISO="$(date -u -v+10y '+%Y-%m-%dT%H:%M:%SZ')"
fi
TARGET_EPOCH="$(date -u -j -f '%Y-%m-%dT%H:%M:%SZ' "$TARGET_ISO" '+%s' 2>/dev/null || true)"
[[ -n "$TARGET_EPOCH" ]] || die "Failed to parse target ISO datetime: $TARGET_ISO"
TARGET_TOUCH_LOCAL="$(date -r "$TARGET_EPOCH" '+%Y%m%d%H%M.%S')"

echo "Target (UTC):  $TARGET_ISO"
echo "Target epoch:  $TARGET_EPOCH"
echo "File:          $FILE"
echo ""

# ---------- Date Modified ----------
touch -mt "$TARGET_TOUCH_LOCAL" "$FILE" || true
mdimport -f "$FILE" >/dev/null 2>&1 || true

# ---------- Date Added (best effort) ----------
if [[ "$TRY_ADDED" -eq 1 ]]; then
  HELPER_DIR="${HOME}/.cache/rubicon_set_future_file_added_date"
  HELPER="${HELPER_DIR}/rubicon_set_added_date_v2"
  HELPER_SRC="${HELPER_DIR}/rubicon_set_added_date_v2.c"
  mkdir -p "$HELPER_DIR"
  if [[ ! -x "$HELPER" ]]; then
    command -v cc >/dev/null || die "C compiler (cc) required; install Xcode Command Line Tools"
    cat >"$HELPER_SRC" <<'C_EOF'
#include <CoreServices/CoreServices.h>
#include <sys/attr.h>
#include <sys/stat.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

/* Minimal setter for Finder "Date Added" (ATTR_CMN_ADDEDTIME)
 * Usage: rubicon_set_added_date_v2 <path> <unix_epoch_seconds>
 * Returns 0 on success, non-zero on failure.
 * Note: On recent macOS releases this may be blocked (EPERM/EINVAL).
 */
int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <path> <unix_epoch_seconds>\n", argv[0]);
        return 2;
    }
    const char *path = argv[1];
    char *end = NULL;
    errno = 0;
    long long epoch = strtoll(argv[2], &end, 10);
    if (errno != 0 || end == argv[2] || *end != '\0') {
        fprintf(stderr, "Invalid epoch seconds: %s\n", argv[2]);
        return 2;
    }

    struct attrlist request;
    memset(&request, 0, sizeof(request));
    request.bitmapcount = ATTR_BIT_MAP_COUNT;
#ifdef ATTR_CMN_ADDEDTIME
    request.commonattr = ATTR_CMN_ADDEDTIME;
#else
    /* Older SDKs may lack the macro; bail. */
    fprintf(stderr, "This SDK does not define ATTR_CMN_ADDEDTIME\n");
    return 1;
#endif

    struct {
        struct timespec added;
    } __attribute__((aligned(4), packed)) reqbuf;

    reqbuf.added.tv_sec = (time_t)epoch;
    reqbuf.added.tv_nsec = 0;

    if (setattrlist(path, &request, &reqbuf, sizeof(reqbuf), 0) != 0) {
        perror("setattrlist(ATTR_CMN_ADDEDTIME) failed");
        return 1;
    }
    return 0;
}
C_EOF
    cc -O2 -Wall -Wextra -framework CoreServices -o "$HELPER" "$HELPER_SRC" || die "compile failed"
  fi

  if "$HELPER" "$FILE" "$TARGET_EPOCH"; then
    # Reindex and attempt verification via mdls (Spotlight)
    mdimport -f "$FILE" >/dev/null 2>&1 || true
    RAW_ADDED="$(mdls -raw -name kMDItemDateAdded "$FILE" 2>/dev/null || true)"
    # RAW example: 2025-11-06 14:44:30 +0000
    if [[ -n "$RAW_ADDED" && "$RAW_ADDED" != "(null)" ]]; then
      ADDED_EPOCH="$(date -j -f '%Y-%m-%d %H:%M:%S %z' "$RAW_ADDED" '+%s' 2>/dev/null || true)"
      if [[ -n "$ADDED_EPOCH" ]]; then
        DIFF=$((ADDED_EPOCH - TARGET_EPOCH))
        [[ $DIFF -lt 0 ]] && DIFF=$((-DIFF))
        if [[ $DIFF -le 2 ]]; then
          echo "✔ Date Added set (Spotlight agrees)."
        else
          echo "⚠ Date Added write returned success, but Spotlight shows '$RAW_ADDED'."
        fi
      else
        echo "⚠ Date Added write returned success, but could not parse Spotlight value: $RAW_ADDED"
      fi
    else
      echo "⚠ Date Added write returned success, but Spotlight returned empty/null."
    fi
  else
    echo "⚠ Date Added could not be set (OS refused)."
  fi
else
  echo "Skipping Date Added per --no-added"
fi

# ---------- Report ----------
ACTUAL_EPOCH="$(stat -f %m "$FILE")"
if [[ "$ACTUAL_EPOCH" != "$TARGET_EPOCH" ]]; then
  echo "⚠ Date Modified was clamped to $(date -ur "$ACTUAL_EPOCH" '+%Y-%m-%dT%H:%M:%SZ')."
fi

echo ""
echo "Spotlight (mdls):"
mdls -name kMDItemDateAdded -name kMDItemContentModificationDate "$FILE" | sed 's/^/  /'
echo ""
echo "Filesystem (stat):"
echo "  mtime (epoch): $ACTUAL_EPOCH"
echo "  mtime (UTC) : $(date -ur "$ACTUAL_EPOCH" '+%Y-%m-%dT%H:%M:%SZ')"
