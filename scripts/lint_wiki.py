#!/usr/bin/env python3
"""scripts/lint_wiki.py

Lightweight, zero-dependency Python 3 script that enforces wiki governance rules.
Run from repo root:  python3 scripts/lint_wiki.py
Exit codes: 0 = clean, 1 = errors detected.

Checks:
  1. Filename hygiene (lower_snake_case for files and directories)
  2. Relative link integrity (resolve against git ls-files or filesystem)
  3. Code Alignment Status banner presence on primary spec pages
"""

import os
import re
import subprocess
from pathlib import Path


# ── Configuration ────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent.parent
WIKI_DIR = ROOT / "docs" / "wiki"

SKIP_FILES = {"README.md", "migration-log.md", "status-and-gaps.md"}
BANNER_DOMAIN_DIRS = {
    "logistics",
    "engineering",
    "markets",
    "infrastructure",
    "technical",
    "astronomy",
    "design",
}


# ── Helpers ───────────────────────────────────────────────────────────
class Issue:
    """A linting issue attached to a file."""
    def __init__(self, filepath: str, check_type: str, message: str):
        self.filepath = Path(filepath) if isinstance(filepath, str) else filepath
        self.check_type = check_type
        self.message = message

    @property
    def rel_path(self) -> str:
        return self.filepath.relative_to(WIKI_DIR).as_posix()


class Collector:
    """Accumulates errors and warnings."""
    def __init__(self):
        self.errors: list[Issue] = []
        self.warnings: list[Issue] = []

    def add_error(self, file_path: str, check_type: str, message: str) -> None:
        self.errors.append(Issue(file_path, check_type, message))

    def add_warning(self, file_path: str, check_type: str, message: str) -> None:
        self.warnings.append(Issue(file_path, check_type, message))


def collect_markdown_files() -> list[Path]:
    """Return all .md files under docs/wiki/ sorted by path."""
    # Use git ls-files to get wiki md files, or fallback to glob
    try:
        raw = subprocess.check_output(
            ["git", "-C", str(ROOT), "ls-files", "--", "docs/wiki/**/*.md"],
            stderr=subprocess.DEVNULL
        ).decode().splitlines()
    except (subprocess.CalledProcessError, FileNotFoundError):
        pattern = os.path.join(str(WIKI_DIR), "**", "*.md")
        raw = glob.glob(pattern)

    files = []
    for p in raw:
        # Strip quotes that git may add for special characters
        p_stripped = p.strip('"').strip("'").strip()
        if p_stripped and os.path.isfile(os.path.join(str(ROOT), p_stripped)):
            files.append(Path(os.path.join(str(ROOT), p_stripped)).resolve())
    return sorted(files)


def is_git_tracked(filepath: Path) -> bool:
    """Check if a path is tracked by git."""
    try:
        subprocess.run(
            ["git", "-C", str(ROOT), "ls-files", "--quiet", "--", str(filepath)],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True
        )
        return True
    except subprocess.CalledProcessError:
        return False


def is_local_file(path: Path) -> bool:
    """Check if a path exists on the local filesystem."""
    return path.exists()


# ── Check 1: Filename hygiene ────────────────────────────────────────
def check_filename_hygiene(collector: Collector, all_files: list[Path]) -> None:
    print("=== Check 1: Filename hygiene (lower_snake_case) ===")

    for file_path in all_files:
        bname = file_path.name
        if bname in SKIP_FILES:
            continue

        # Directory path components — check each for uppercase
        rel_parts = file_path.relative_to(WIKI_DIR).parts
        for part in rel_parts:
            if part == ".":
                continue
            if re.search(r"[A-Z]", part):
                collector.add_error(str(file_path), "hygiene",
                                    f"dir: {part} contains uppercase characters")

        # Filename patterns
        violations = []
        if re.search(r"[A-Z]", bname):
            violations.append(f"{bname}: contains uppercase letters")
        if " " in bname:
            violations.append(f"{bname}: contains spaces")
        if bname.count("-") > 1:
            collector.add_warning(str(file_path), "hygiene",
                                  f"{bname}: multiple hyphens — consider underscores")

        for v in violations:
            collector.add_error(str(file_path), "hygiene", v)

    hygiene_errors = [i for i in collector.errors if i.check_type == "hygiene"]
    hygiene_warnings = [i for i in collector.warnings if i.check_type == "hygiene"]

    if not hygiene_errors and not hygiene_warnings:
        print("  ✓ All files and directories use lower_snake_case.")
    else:
        if hygiene_errors:
            print("\n  Errors:")
            for i in hygiene_errors:
                print(f"    ✗ {i.rel_path}: {i.message}")
        if hygiene_warnings:
            print("\n  Warnings:")
            for i in hygiene_warnings:
                print(f"    ~ {i.rel_path}: {i.message}")
    print()


# ── Check 2: Relative link integrity ──────────────────────────────────
def check_relative_links(collector: Collector, all_files: list[Path]) -> None:
    print("=== Check 2: Relative link integrity ===")

    # Markdown relative link pattern: [text](path)
    md_link_re = re.compile(r'\[([^\]]+)\]\(([^)]+)\)')

    for file_path in all_files:
        bname = file_path.name
        if bname in SKIP_FILES:
            continue

        content = file_path.read_text(encoding="utf-8", errors="replace")

        for label, target in md_link_re.findall(content):
            # Skip external URLs, mailto
            if target.startswith(("http://", "https://", "mailto:")):
                continue

            # Split path from anchor
            parts = target.split("#", 1)
            raw_target = parts[0]
            
            # If there's no path component (pure anchor like "#section"), skip
            if not raw_target or raw_target.startswith("#"):
                continue
            
            # Resolve relative to the source file's directory, stripping anchors
            resolved = (file_path.parent / raw_target).resolve()

            # Only check paths within wiki root or git-tracked docs
            try:
                str_resolved = str(resolved)
                if not (str_resolved.startswith(str(WIKI_DIR)) or
                        "docs/architecture" in str_resolved or
                        "docs/developer" in str_resolved):
                    continue
            except Exception:
                collector.add_error(str(file_path), "link",
                                    f"{target!r}: could not resolve path")
                continue

            # Verify target exists (git-tracked or local file)
            if is_git_tracked(resolved) or is_local_file(resolved):
                pass  # OK
            else:
                collector.add_error(str(file_path), "link",
                                    f"{target!r} → target not found (git or disk)")

    link_errors = [i for i in collector.errors if i.check_type == "link"]

    if not link_errors:
        print("  ✓ All relative links resolve successfully.")
    else:
        for i in link_errors:
            print(f"  ✗ {i.rel_path}: {i.message}")
    print()


# ── Check 3: Code Alignment Status banners ───────────────────────────
def check_code_alignment_banners(collector: Collector, all_files: list[Path]) -> None:
    """Check that primary spec pages have the standard 3-line banner."""
    print("=== Check 3: Code Alignment Status banners (primary specs) ===")

    checked_count = 0
    banner_re = re.compile(r"^> \*\*Code Alignment Status:\*\*")
    audited_re = re.compile(r"^> \*Last Audited:\*")
    summary_re = re.compile(r"^> \*Audit Summary:\*")

    for file_path in all_files:
        rel = file_path.relative_to(WIKI_DIR)
        # Only enforce banners on core domain directories
        if rel.parts[0] not in BANNER_DOMAIN_DIRS:
            continue
        bname = file_path.name
        if bname in SKIP_FILES:
            continue

        checked_count += 1
        content = file_path.read_text(encoding="utf-8", errors="replace")
        lines = content.splitlines()

        # Search within first 30 lines for the banner
        banner_found = False
        max_line = min(len(lines) - 1, 29)

        for i in range(max_line + 1):
            line = lines[i]
            if banner_re.match(line):
                banner_found = True
                # Check that Last Audited and Audit Summary follow within next few lines
                has_audited = False
                has_summary = False
                for j in [i + 1, i + 2]:
                    if j >= len(lines):
                        break
                    txt = lines[j].strip()
                    if audited_re.match(txt):
                        has_audited = True
                    if summary_re.match(txt):
                        has_summary = True

                if not (has_audited and has_summary):
                    collector.add_error(str(file_path), "banner",
                                        "incomplete banner — missing Last Audited or Audit Summary")
                break

        if not banner_found:
            collector.add_error(str(file_path), "banner",
                                "missing Code Alignment Status banner")

    banner_errors = [i for i in collector.errors if i.check_type == "banner"]

    if not banner_errors:
        print(f"  ✓ All {checked_count} primary spec pages have valid banners.")
    else:
        for i in banner_errors:
            print(f"  ✗ {i.rel_path}: {i.message}")
    print()


# ── Report formatting ────────────────────────────────────────────────
def print_report(collector: Collector, checked_count: int) -> None:
    total_errors = len(collector.errors)
    total_warnings = len(collector.warnings)

    print("=" * 70)
    print("Wiki Governance Lint Report")
    print(f"Repository root: {ROOT}")
    print(f"Checked files (with banners): {checked_count} (+ others checked)")
    print("=" * 70)

    if not collector.errors and not collector.warnings:
        print("\n✓ All checks passed — no issues detected.")
        return

    if collector.errors:
        print(f"\n--- ERRORS ({total_errors}) ---")
        by_file: dict[str, list] = {}
        for i in collector.errors:
            key = i.rel_path
            by_file.setdefault(key, []).append(i)
        for fpath, issues in sorted(by_file.items()):
            print(f"\n  {fpath}:")
            for i in issues:
                print(f"    [{i.check_type.upper()}] {i.message}")

    if collector.warnings:
        print(f"\n--- WARNINGS ({total_warnings}) ---")
        by_file: dict[str, list] = {}
        for i in collector.warnings:
            key = i.rel_path
            by_file.setdefault(key, []).append(i)
        for fpath, issues in sorted(by_file.items()):
            print(f"\n  {fpath}:")
            for i in issues:
                print(f"    [{i.check_type.upper()}] {i.message}")

    total = total_errors + total_warnings
    print(f"\nTotal: {total_errors} error(s), {total_warnings} warning(s)")


# ── Entry point ───────────────────────────────────────────────────────
def main() -> None:
    all_md = collect_markdown_files()

    if not all_md:
        print("No .md files found under docs/wiki/. Nothing to lint.")
        return

    collector = Collector()

    # Run all three checks
    check_filename_hygiene(collector, all_md)
    check_relative_links(collector, all_md)
    check_code_alignment_banners(collector, all_md)

    # Count checked files (for banner report)
    checked_count = 0
    for file_path in all_md:
        bname = file_path.name
        if bname not in SKIP_FILES:
            checked_count += 1

    print_report(collector, checked_count)

    # Exit code
    exit(1 if collector.errors else 0)


if __name__ == "__main__":
    main()
