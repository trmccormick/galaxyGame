#!/usr/bin/env bash
# Restore data/ FROM the EasyStore network share.
# Use this when you want to pull shared changes back to your local project.
set -euo pipefail

# Source: EasyStore network share
SRC="${SRC:-/Volumes/easystore/Backups/Intel - Work Files/galaxy_game/data}"

# Destination: local project data
DEST="${DEST:-$HOME/Documents/git/galaxyGame/data}"

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

echo "Restoring (actual transfer):"
echo "  $SRC/  →  $DEST/"
rsync -av --exclude '.DS_Store' --exclude 'bundle/' --exclude 'node_modules/' --exclude 'logs/' "$SRC/" "$DEST/"
echo "Done. Local data tree restored from EasyStore."
