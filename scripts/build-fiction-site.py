#!/usr/bin/env python3
"""Build static HTML fiction pages for GitHub Pages (docs/ folder)."""

from __future__ import annotations

import re
import sys
from pathlib import Path

import markdown
from markdown.extensions.tables import TableExtension

ROOT = Path(__file__).resolve().parents[1]
FICTION_SRC = ROOT / "docs" / "fiction"
FICTION_OUT = ROOT / "docs" / "fiction"
STYLES_HREF = "../styles.css"

md = markdown.Markdown(
    extensions=["fenced_code", "nl2br", TableExtension()],
    output_format="html5",
)


def slugify(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[*_`]", "", text)
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return text.strip("-")


def extract_title(header_line: str) -> tuple[str, str]:
    """Return (code_or_num, title) from a section header."""
    # ### Story 1 — *Title*
    m = re.match(r"^#{2,3}\s+(?:Story\s+)?([\w-]+)\s+—\s+\*?(.+?)\*?\s*$", header_line)
    if m:
        return m.group(1).lower().replace(" ", ""), m.group(2).strip("* ")
    # ## I-M01 — *Title*
    m = re.match(r"^##\s+([\w-]+)\s+—\s+\*?(.+?)\*?", header_line)
    if m:
        return m.group(1).lower(), m.group(2).strip("* ")
    return "page", header_line.lstrip("# ").strip()


def split_sections(content: str, pattern: str) -> list[tuple[str, str, str]]:
    """Split markdown on ## headers matching pattern. Returns (code, title, body)."""
    parts = re.split(r"(?=^## )", content, flags=re.MULTILINE)
    sections: list[tuple[str, str, str]] = []
    for part in parts:
        part = part.strip()
        if not part or not part.startswith("## "):
            continue
        first_line, _, body = part.partition("\n")
        if not re.match(pattern, first_line):
            continue
        code, title = extract_title(first_line)
        sections.append((code, title, part))
    return sections


def split_spine_stories(content: str) -> list[tuple[str, str, str]]:
    """Split SHORT_STORY_SERIES on ### Story headers."""
    parts = re.split(r"(?=^### Story )", content, flags=re.MULTILINE)
    sections: list[tuple[str, str, str]] = []
    for part in parts:
        part = part.strip()
        if not part.startswith("### Story "):
            continue
        first_line, _, body = part.partition("\n")
        code, title = extract_title(first_line.replace("### ", "## "))
        sections.append((code, title, part))
    return sections


def render_page(
    title: str,
    body_html: str,
    *,
    styles_href: str,
    nav_label: str = "Fiction",
    nav_href: str = "index.html",
    subtitle: str | None = None,
) -> str:
    sub = f'<p class="lead">{subtitle}</p>' if subtitle else ""
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title} — Avasia Fiction</title>
  <meta name="description" content="{title} — Avasia saga fiction spec.">
  <link rel="stylesheet" href="{styles_href}">
</head>
<body>
  <main class="prose">
    <nav class="breadcrumb" aria-label="Breadcrumb">
      <a href="HOME_PLACEHOLDER">Avasia</a>
      <span aria-hidden="true"> / </span>
      <a href="{nav_href}">{nav_label}</a>
      <span aria-hidden="true"> / </span>
      <span aria-current="page">{title}</span>
    </nav>
    {sub}
    <article>
      {body_html}
    </article>
    <footer>
      <p><a href="{nav_href}">← Back to fiction index</a></p>
      <p>Author working material — not final published prose.</p>
    </footer>
  </main>
</body>
</html>
"""


def fix_breadcrumb_href(html: str, styles_href: str, nav_href: str) -> str:
    """Fix home link based on depth."""
    depth = styles_href.count("..")
    home = "/".join([".."] * depth) + "/index.html" if depth else "index.html"
    return html.replace("HOME_PLACEHOLDER", home)


def write_page(path: Path, html: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(html, encoding="utf-8")


def convert_md_to_html(text: str) -> str:
    md.reset()
    return md.convert(text)


def page_filename(code: str, title: str) -> str:
    return f"{slugify(code)}-{slugify(title)}.html"


def build_single_md(src: Path, dest: Path, page_title: str, styles_href: str) -> None:
    content = src.read_text(encoding="utf-8")
    html_body = convert_md_to_html(content)
    html = render_page(
        page_title,
        html_body,
        styles_href=styles_href,
        subtitle="Saga overview for collaborators",
    )
    html = fix_breadcrumb_href(html, styles_href, "index.html")
    write_page(dest, html)


def main() -> int:
    catalog: dict[str, list[tuple[str, str, str]]] = {
        "overview": [],
        "spine": [],
        "bridge": [],
        "margin-i": [],
        "margin-ii": [],
        "commodity": [],
        "world": [],
        "bibles": [],
    }

    # Overview
    brief_src = FICTION_SRC / "STORY_BRIEF_FOR_COLLABORATOR.md"
    brief_dest = FICTION_OUT / "story-brief.html"
    build_single_md(brief_src, brief_dest, "Story Brief", STYLES_HREF)
    catalog["overview"].append(("story-brief.html", "Story Brief", "Main beats, world rules, Commodity Era ideas"))

    # Spine stories
    spine_src = FICTION_SRC / "SHORT_STORY_SERIES.md"
    spine_content = spine_src.read_text(encoding="utf-8")
    spine_dir = FICTION_OUT / "spine"
    for code, title, body in split_spine_stories(spine_content):
        fname = page_filename(code, title)
        rel = f"spine/{fname}"
        html_body = convert_md_to_html(body)
        html = render_page(title, html_body, styles_href="../../styles.css", nav_href="../index.html")
        html = fix_breadcrumb_href(html, "../../styles.css", "../index.html")
        write_page(spine_dir / fname, html)
        catalog["spine"].append((rel, f"Story {code} — {title}", ""))

    # Margin + bridge + world from spec files
    spec_groups = [
        ("bridge", FICTION_SRC / "specs" / "volume-bridge.md", r"^## B-\d+", "../../styles.css", "bridge"),
        ("margin-i", FICTION_SRC / "specs" / "volume-i.md", r"^## I-M\d+", "../../styles.css", "margin-i"),
        ("margin-ii", FICTION_SRC / "specs" / "volume-ii.md", r"^## II-M\d+", "../../styles.css", "margin-ii"),
        ("commodity", FICTION_SRC / "specs" / "volume-iii.md", r"^## III-M\d+", "../../styles.css", "commodity"),
        ("world", FICTION_SRC / "WORLD_BUILDING.md", r"^## W-\d+", "../../styles.css", "world"),
    ]

    for group_key, src_path, pattern, styles, cat_key in spec_groups:
        if not src_path.exists():
            continue
        content = src_path.read_text(encoding="utf-8")
        out_dir = FICTION_OUT / group_key
        for code, title, body in split_sections(content, pattern):
            fname = page_filename(code, title)
            rel = f"{group_key}/{fname}"
            html_body = convert_md_to_html(body)
            html = render_page(
                f"{code.upper()} — {title}",
                html_body,
                styles_href=styles,
                nav_href="../index.html",
            )
            html = fix_breadcrumb_href(html, styles, "../index.html")
            write_page(out_dir / fname, html)
            catalog[cat_key].append((rel, f"{code.upper()} — {title}", ""))

    # Full bibles (single pages)
    bibles = [
        ("characters.html", "Characters", FICTION_SRC / "CHARACTERS.md", "Key cast — wants, wounds, voice"),
        ("world-building.html", "World Building", FICTION_SRC / "WORLD_BUILDING.md", "Institutions, cultures, economy"),
        ("ofkelos.html", "Ofelos", FICTION_SRC / "OFKELOS.md", "Neutral city bible"),
        ("thekia.html", "Thekia", FICTION_SRC / "THEKIA_GROUND_HOUSE.md", "Ground house — Stories 2b, 4b, 9b"),
    ]
    for fname, title, src, desc in bibles:
        if not src.exists():
            continue
        dest = FICTION_OUT / fname
        build_single_md(src, dest, title, STYLES_HREF)
        catalog["bibles"].append((fname, title, desc))

    # Fiction index
    index_html = build_index(catalog)
    write_page(FICTION_OUT / "index.html", index_html)

    total = sum(len(v) for v in catalog.values())
    print(f"Built {total} fiction pages under {FICTION_OUT.relative_to(ROOT)}")
    return 0


def build_index(catalog: dict[str, list[tuple[str, str, str]]]) -> str:
    def section(title: str, items: list[tuple[str, str, str]], note: str = "") -> str:
        if not items:
            return ""
        note_html = f'<p class="section-note">{note}</p>' if note else ""
        links = "\n".join(
            f'        <li><a href="{href}">{label}</a>'
            + (f'<span class="desc">{desc}</span>' if desc else "")
            + "</li>"
            for href, label, desc in items
        )
        return f"""
    <section class="card catalog-section">
      <h2>{title}</h2>
      {note_html}
      <ul class="story-list">
{links}
      </ul>
    </section>"""

    body = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Fiction — Avasia</title>
  <meta name="description" content="Avasia saga story overviews, beats, and short story specs.">
  <link rel="stylesheet" href="../styles.css">
</head>
<body>
  <main class="prose">
    <h1>Avasia Fiction</h1>
    <p class="lead">Story overviews, saga beats, and short story specs for the Age era and beyond.</p>

    <nav aria-label="Site">
      <ul class="site-nav">
        <li><a href="../index.html">Home</a></li>
        <li><a href="story-brief.html">Story Brief</a></li>
        <li><a href="index.html" aria-current="page">Fiction Index</a></li>
      </ul>
    </nav>
{section("Overview", catalog["overview"], "Start here — main beats and world building for collaborators.")}
{section("Saga Spine", catalog["spine"], "Stories 1–20 in chronological order — the full Age-era anthology spine.")}
{section("Seven-Year Bridge", catalog["bridge"], "Between King of Nacastrum and Blade of Courage.")}
{section("Margin Stories — Volume I", catalog["margin-i"], "KoN-era side stories (I-M01–I-M12).")}
{section("Margin Stories — Volume II", catalog["margin-ii"], "SoC-era side stories (II-M01–II-M10).")}
{section("Commodity Era — Volume III", catalog["commodity"], "Game 3 era sketches (III-M01–III-M09).")}
{section("Geography & Anchor Myths", catalog["world"], "Places and anchor-law stories (W-01–W-12).")}
{section("Bibles", catalog["bibles"], "Character, world, city, and mentor deep dives.")}

    <footer>
      <p>Author working material — regenerate with <code>python3 scripts/build-fiction-site.py</code></p>
      <p>Last built June 2026</p>
    </footer>
  </main>
</body>
</html>"""
    return body


if __name__ == "__main__":
    sys.exit(main())
