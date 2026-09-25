#!/usr/bin/env bash
# Sync data/json-data/ TO the EasyStore network share (Intel work files).
# Use this when you want to push local changes to the shared backup.
set -euo pipefail

# Source: local project json-data
SRC="${SRC:-$HOME/Documents/git/galaxyGame/data}"

# Destination: EasyStore network share
DEST="${DEST:-/Volumes/easystore/Backups/Intel - Work Files/galaxy_game/data}"

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: source not found: $SRC" >&2
  exit 1
fi
if [[ ! -d "/Volumes/easystore" ]]; then
  echo "ERROR: EasyStore not mounted at /Volumes/easystore" >&2
  exit 1
fi

mkdir -p "$DEST"

if [[ "${APPLY:-0}" != "1" ]]; then
  echo "Dry-run (set APPLY=1 to write):"
  echo "  $SRC/  →  $DEST/"
  rsync -avn --exclude '.DS_Store' --exclude 'bundle/' --exclude 'node_modules/' --exclude 'logs/' "$SRC/" "$DEST/"
  echo
  echo "Dry-run only. To apply: APPLY=1 $0"
  exit 0
fi

echo "Syncing (actual transfer):"
echo "  $SRC/  →  $DEST/"
rsync -av --exclude '.DS_Store' --exclude 'bundle/' --exclude 'node_modules/' --exclude 'logs/' "$SRC/" "$DEST/"
echo "Done. EasyStore data tree updated."
