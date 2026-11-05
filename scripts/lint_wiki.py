#!/usr/bin/env python3
"""Wiki governance linter for docs/wiki/ (zero dependencies, Python 3.8+).

Enforces the "Wiki Standards & Conventions" in docs/wiki/README.md:

  1. naming   - lower_snake_case file and folder names (no uppercase, spaces
                or hyphens). Every file named README.md is exempt.
  2. links    - every relative link must resolve to a file that is tracked by
                git (exact, case-sensitive match against `git ls-files`).
                A link that resolves outside docs/wiki/ is an error (rule 5).
                A link to a folder passes only if that folder has a tracked
                README.md. The filesystem is never consulted, so the result is
                the same on macOS (case-insensitive) and Linux.
  3. anchors  - a #fragment must be lowercase (rule 4) and must match a heading
                slug in the target page.
  4. orphans  - every page except README.md needs an inbound link from another
                wiki page.
  5. banners  - pages in the primary spec folders need the three-line
                "Code Alignment Status" banner with an allowed status value.

Usage:
  python3 scripts/lint_wiki.py             # lint the repository containing this script
  python3 scripts/lint_wiki.py --self-test # check the linter's own helpers

Exit status: 0 = clean, 1 = errors found (or git unavailable).
The linter only reports. It never edits a page.
"""
import os
import posixpath
import re
import subprocess
import sys
from collections import defaultdict
from urllib.parse import unquote

WIKI = "docs/wiki"
ALLOWED_STATUS = ("DESIGN INTENT", "PARTIALLY IMPLEMENTED", "VERIFIED AGAINST CODE")
BANNER_DOMAIN_DIRS = {
    "astronomy", "design", "engineering", "infrastructure",
    "logistics", "markets", "technical",
}
BANNER_WINDOW = 40          # banner must start within the first N lines
SCHEME_RE = re.compile(r"^[A-Za-z][A-Za-z0-9+.\-]*:")
LINK_RE = re.compile(
    r"!?\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+(?:\"[^\"]*\"|'[^']*'))?\s*\)"
)
HEADING_RE = re.compile(r"^ {0,3}(#{1,6})[ \t]+(.+?)[ \t]*#*[ \t]*$")
FENCE_RE = re.compile(r"^ {0,3}(```|~~~)")
STATUS_RE = re.compile(r"^>\s*\*\*Code Alignment Status:\*\*\s*`([^`]*)`")
AUDITED_RE = re.compile(r"^>\s*\*Last Audited:\*\s*(\d{4}-\d{2}-\d{2})\b")
SUMMARY_RE = re.compile(r"^>\s*\*Audit Summary:\*\s*(\S.*)$")


class Report:
    def __init__(self):
        self.items = []  # (file, check, line, message)

    def error(self, file, check, line, message):
        self.items.append((file, check, line, message))


# ── Helpers ──────────────────────────────────────────────────────────
def repo_root():
    here = os.path.dirname(os.path.abspath(__file__))
    try:
        out = subprocess.check_output(
            ["git", "-C", here, "rev-parse", "--show-toplevel"],
            stderr=subprocess.DEVNULL)
    except (OSError, subprocess.CalledProcessError):
        sys.stderr.write("lint_wiki: not inside a git repository (git rev-parse failed)\n")
        sys.exit(1)
    return out.decode("utf-8").strip()


def tracked_paths(root):
    """Exact set of tracked paths, repo-relative, forward slashes."""
    try:
        raw = subprocess.check_output(["git", "-C", root, "ls-files", "-z"],
                                      stderr=subprocess.DEVNULL)
    except (OSError, subprocess.CalledProcessError):
        sys.stderr.write("lint_wiki: `git ls-files` failed\n")
        sys.exit(1)
    return {p.decode("utf-8") for p in raw.split(b"\x00") if p}


def read_text(root, rel):
    try:
        with open(os.path.join(root, rel), encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None


def prose_lines(text):
    """Yield (line_number, line) outside fenced code blocks, inline code removed."""
    in_fence = False
    for n, line in enumerate(text.splitlines(), 1):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        yield n, re.sub(r"`[^`]*`", "", line)


def slug(heading_text):
    """Approximation of GitHub heading anchors: strip formatting, lowercase,
    drop punctuation (including em/en dashes), turn each space into a hyphen
    without collapsing hyphens."""
    t = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", heading_text)
    t = re.sub(r"<[^>]+>", "", t)
    t = re.sub(r"[`*~]", "", t)
    t = t.strip().lower()
    t = re.sub(r"[^\w\- ]", "", t)
    return t.replace(" ", "-")


def heading_slugs(text):
    seen = defaultdict(int)
    slugs = set()
    for _, line in prose_lines_raw(text):
        m = HEADING_RE.match(line)
        if not m:
            continue
        base = slug(m.group(2))
        n = seen[base]
        slugs.add(base if n == 0 else "%s-%d" % (base, n))
        seen[base] += 1
    return slugs


def prose_lines_raw(text):
    """Like prose_lines but keeps inline code (headings may contain backticks)."""
    in_fence = False
    for n, line in enumerate(text.splitlines(), 1):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if not in_fence:
            yield n, line


# ── Check 1: naming ──────────────────────────────────────────────────
def check_naming(tracked, report):
    flagged = set()
    for p in sorted(tracked):
        if not p.startswith(WIKI + "/"):
            continue
        parts = p[len(WIKI) + 1:].split("/")
        for i, part in enumerate(parts):
            if part == "README.md":
                continue
            problems = []
            if re.search(r"[A-Z]", part):
                problems.append("uppercase")
            if " " in part:
                problems.append("space")
            if "-" in part:
                problems.append("hyphen")
            if problems:
                where = "/".join([WIKI] + parts[:i + 1])
                if where in flagged:
                    continue
                flagged.add(where)
                kind = "folder" if i < len(parts) - 1 else "file"
                report.error(where, "naming", 0,
                             "%s name has %s (README rule 1: lower_snake_case)"
                             % (kind, " and ".join(problems)))


# ── Checks 2-4: links, anchors, orphans ──────────────────────────────
def check_links(root, tracked, report):
    md_files = sorted(p for p in tracked if p.startswith(WIKI + "/") and p.endswith(".md"))
    dirs = set()
    for p in tracked:
        d = posixpath.dirname(p)
        while d:
            dirs.add(d)
            d = posixpath.dirname(d)

    texts = {}
    slug_cache = {}
    for f in md_files:
        t = read_text(root, f)
        if t is None:
            report.error(f, "links", 0, "tracked file could not be read from disk")
            continue
        texts[f] = t

    def slugs_for(rel):
        if rel not in slug_cache:
            slug_cache[rel] = heading_slugs(texts[rel]) if rel in texts else set()
        return slug_cache[rel]

    inbound = defaultdict(int)
    for src, text in texts.items():
        for lineno, line in prose_lines(text):
            for m in LINK_RE.finditer(line):
                target = m.group(1)
                if SCHEME_RE.match(target):
                    continue  # http:, https:, mailto: ...
                path_part, _, frag = target.partition("#")
                path_part = unquote(path_part)
                if path_part:
                    resolved = posixpath.normpath(
                        posixpath.join(posixpath.dirname(src), path_part))
                else:
                    resolved = src  # fragment-only link: same page
                shown = target

                if resolved == ".." or resolved.startswith("../") or \
                        not (resolved == WIKI or resolved.startswith(WIKI + "/")):
                    report.error(src, "links", lineno,
                                 "outward link '%s' -> %s (README rule 5: wiki links only to wiki pages)"
                                 % (shown, resolved))
                    continue

                # folder link
                if resolved in dirs and resolved not in tracked:
                    if (resolved + "/README.md") in tracked:
                        target_file = resolved + "/README.md"
                    else:
                        report.error(src, "links", lineno,
                                     "folder link '%s' has no README.md in that folder" % shown)
                        continue
                elif resolved in tracked:
                    target_file = resolved
                else:
                    report.error(src, "links", lineno,
                                 "target not found: '%s' -> %s (case-sensitive match against git ls-files)"
                                 % (shown, resolved))
                    continue

                if target_file != src and target_file.endswith(".md"):
                    inbound[target_file] += 1

                if frag and target_file.endswith(".md") and target_file in texts:
                    if frag != frag.lower():
                        report.error(src, "anchors", lineno,
                                     "anchor '#%s' has uppercase letters (README rule 4)" % frag)
                    elif frag not in slugs_for(target_file):
                        report.error(src, "anchors", lineno,
                                     "anchor '#%s' not found in %s" % (frag, target_file))

    for f in md_files:
        if os.path.basename(f) == "README.md":
            continue
        if inbound[f] == 0:
            report.error(f, "orphans", 0,
                         "no inbound link from any other wiki page")


# ── Check 5: banners ─────────────────────────────────────────────────
def check_banners(root, tracked, report):
    for f in sorted(tracked):
        if not (f.startswith(WIKI + "/") and f.endswith(".md")):
            continue
        parts = f[len(WIKI) + 1:].split("/")
        if len(parts) < 2 or parts[0] not in BANNER_DOMAIN_DIRS:
            continue
        if parts[-1] == "README.md":
            continue
        text = read_text(root, f)
        if text is None:
            continue
        lines = text.splitlines()[:BANNER_WINDOW + 3]
        idx = None
        value = None
        for i, line in enumerate(lines[:BANNER_WINDOW]):
            m = STATUS_RE.match(line)
            if m:
                idx, value = i, m.group(1).strip()
                break
        if idx is None:
            report.error(f, "banners", 0,
                         "missing Code Alignment Status banner in the first %d lines" % BANNER_WINDOW)
            continue
        if value not in ALLOWED_STATUS:
            report.error(f, "banners", idx + 1,
                         "status '%s' is not one of: %s" % (value, ", ".join(ALLOWED_STATUS)))
        follow = lines[idx + 1: idx + 4]
        if not any(AUDITED_RE.match(l) for l in follow):
            report.error(f, "banners", idx + 1, "banner missing '> *Last Audited:* YYYY-MM-DD'")
        if not any(SUMMARY_RE.match(l) for l in follow):
            report.error(f, "banners", idx + 1, "banner missing '> *Audit Summary:*' text")


# ── Output ───────────────────────────────────────────────────────────
def print_report(report, tracked):
    items = report.items
    if not items:
        print("lint_wiki: OK - no errors.")
    else:
        by_file = defaultdict(list)
        for it in items:
            by_file[it[0]].append(it)
        for f in sorted(by_file):
            print(f)
            for _, check, line, msg in sorted(by_file[f], key=lambda x: (x[1], x[2])):
                loc = (":%d" % line) if line else ""
                print("  [%s]%s %s" % (check.upper(), loc, msg))
        print()
    counts = defaultdict(int)
    for it in items:
        counts[it[1]] += 1
    order = ["naming", "links", "anchors", "orphans", "banners"]
    print("Summary: %d error(s)  (%s)" % (
        len(items), ", ".join("%s %d" % (c, counts[c]) for c in order)))
    covered = BANNER_DOMAIN_DIRS
    wiki_dirs = {p[len(WIKI) + 1:].split("/")[0] for p in tracked
                 if p.startswith(WIKI + "/") and "/" in p[len(WIKI) + 1:]}
    uncovered = sorted(wiki_dirs - covered)
    if uncovered:
        print("Note: banner check does not cover folders: %s" % ", ".join(uncovered))


# ── Self-test ────────────────────────────────────────────────────────
def self_test():
    ok = True

    def expect(label, got, want):
        nonlocal ok
        good = got == want
        ok = ok and good
        print("  %s %s" % ("PASS" if good else "FAIL", label))
        if not good:
            print("      got:  %r\n      want: %r" % (got, want))

    print("slug():")
    expect("em dash leaves a double hyphen",
           slug("ESTABLISHED INTENT — Player Independence: Staying Put Is Valid Play"),
           "established-intent--player-independence-staying-put-is-valid-play")
    expect("en dash without spaces is dropped", slug("Venus–Mars"), "venusmars")
    expect("backticks and parentheses", slug("`Foo` bar (real-world)"), "foo-bar-real-world")
    expect("duplicate headings",
           sorted(heading_slugs("# Setup\n\n## Setup\n\n```\n# not a heading\n```\n")),
           ["setup", "setup-1"])
    print("case sensitivity (against this repository's git index):")
    root = repo_root()
    tracked = tracked_paths(root)
    expect("docs/wiki/README.md is tracked", (WIKI + "/README.md") in tracked, True)
    expect("docs/wiki/readme.md (wrong case) is NOT found", (WIKI + "/readme.md") in tracked, False)
    print("naming:")
    r = Report()
    check_naming({"docs/wiki/a-b.md", "docs/wiki/Ok.md", "docs/wiki/x/README.md",
                  "docs/wiki/fine_name.md"}, r)
    expect("hyphen and uppercase flagged, README and snake_case pass",
           sorted(i[0] for i in r.items), ["docs/wiki/Ok.md", "docs/wiki/a-b.md"])
    print("self-test: %s" % ("PASS" if ok else "FAIL"))
    return 0 if ok else 1


def main(argv):
    if "--self-test" in argv:
        sys.exit(self_test())
    root = repo_root()
    tracked = tracked_paths(root)
    report = Report()
    check_naming(tracked, report)
    check_links(root, tracked, report)
    check_banners(root, tracked, report)
    print_report(report, tracked)
    sys.exit(1 if report.items else 0)


if __name__ == "__main__":
    main(sys.argv[1:])
