#!/usr/bin/env bash
# Sync materials JSON onto the EasyStore work copy (data is gitignored — not GitHub).
set -euo pipefail

# Working tree in the git clone (edit if your clone path differs)
SRC="${SRC:-$HOME/Documents/git/galaxyGame/data/json-data/resources/materials}"

# EasyStore local path (Intel work files)
DEST="${DEST:-/Volumes/easystore/Backups/Intel - Work Files/galaxy_game/data/json-data/resources/materials}"

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: source not found: $SRC" >&2
  exit 1
fi
if [[ ! -d "/Volumes/easystore/Backups/Intel - Work Files/galaxy_game/data/json-data" ]]; then
  echo "ERROR: EasyStore path not mounted or missing" >&2
  exit 1
fi
mkdir -p "$DEST"

echo "Dry-run (set APPLY=1 to write):"
echo "  $SRC/  →  $DEST/"
rsync -avcn --delete --exclude '.DS_Store' "$SRC/" "$DEST/"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo
  echo "Dry-run only. To apply: APPLY=1 $0"
  exit 0
fi

rsync -avc --delete --exclude '.DS_Store' "$SRC/" "$DEST/"
echo "Done. EasyStore materials tree updated."