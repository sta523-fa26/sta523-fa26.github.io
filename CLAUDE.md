# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

Hugo-based academic course website for Sta 523L "Statistical Programming" (Fall 2026). Combines Hugo SSG for the main site with Quarto revealjs presentations for lecture slides.

This is a new version of the course that merges the R and Python content previously taught separately in Sta 523 (R) and Sta 663 (Python). Lectures generally cover both languages, often side by side.

Build pipeline: QMD → HTML (quarto render) → PDF (renderthis::to_pdf)

## Previous Course Materials

Slides from the two predecessor courses are kept in the repo as source material:

- `static/slides/prev_523/` - R content (previous Sta 523)
- `static/slides/prev_663/` - Python content (previous Sta 663)

When asked for lecture materials or content, pull from these directories with priority: R material from `prev_523`, Python material from `prev_663`. New lectures for this course are typically built by adapting and combining slides from both.

These directories are reference-only: they are not rendered by the Makefile (it only globs `static/slides/*.qmd`) and should not be published to `docs/`. The `prev_663` slides run Python chunks through knitr + reticulate, with shared knitr setup in `prev_663/_setup.R`.

## Development Commands

```bash
make build          # Build HTML slides, PDFs, and Hugo site
make open           # Build and open docs/index.html in browser
make push           # Build, commit, and push to git
make clean          # Remove all generated files
```

### Single slide workflow
```bash
quarto render static/slides/Lec01.qmd                    # Render one slide to HTML
Rscript -e "renderthis::to_pdf('static/slides/Lec01.html')"  # Convert HTML to PDF
```

## Slide Development

Slides live in `static/slides/*.qmd` using revealjs format with custom theme (`slides.scss`). Slides use the knitr engine; Python code is executed via reticulate in `{python}` chunks, so a single deck can mix R and Python.

Note: Sections titled "Example" are live-coded demonstrations done in class and intentionally have no content in the slides.

Note: Within a single slide, all code chunks should use the same size class (`.small`, `.xsmall`, etc.) whether applied via `.columns` or a standalone div. Mixing sizes on one slide is only acceptable for a specific, compelling design reason.

Note: When reviewing slides, do not review or comment on the content of exercises or examples (spelling and grammar checks are fine). These are meant to be external live-coded experiences for students, so the content will usually not be in the slides.

Note: Avoid ending a slide with a text statement revealed as a fragment (`. . .` followed by prose); this usually reads as a fact tacked on after the fact. Fold the point into the slide's intro text or an `::: {.aside}`, or drop it. Reserve end-of-slide text fragments for genuinely important punchlines, used sparingly.

Note: Use italics (`*text*`) and bold (`**text**`) very, very sparingly in slide prose. Emphasis should be rare enough that it stands out; most sentences and terms need none.

Note: Use `::: {.aside}` blocks judiciously. There is no point in having an aside on every slide; most slides should have none. An aside is for a genuinely useful footnote (a caveat, a pointer to docs, a gotcha), not a place to park every extra detail or a second explanation of the slide. If a point matters, put it in the slide text; if it does not, drop it.

Note: When a `#` section header introduces a package that has a hex sticker in `static/slides/imgs/` (`hex-*.png` or `hex_*.png`), use the sticker as the section slide instead of a plain name, e.g.

```
# {#tibble-logo data-menu-title="tibble" .nostretch}

![](imgs/hex-tibble.png){fig-align="center" width="32%"}
```

## Lecture Notes

Exercise solutions for each lecture live in `static/slides/notes/LecXX_notes.qmd`. Keep them minimal:

- One `# Exercise N` header per exercise, followed by the prompt restated in one or two sentences. Match the slide's wording and scope: if the slide asks for Python only, do not add an R solution.
- Then the code that solves it, and nothing else. No prose between chunks, no sub-headings for each step, no alternative or "more idiomatic" solutions, no comparisons to the other language, no follow-up notes or asides.
- A very short inline comment is acceptable only when needed to explain a non-obvious result (e.g. annotating a coercion outcome).
- For discussion exercises with no code answer, give a compact table or one line per item, with at most a few words of justification.

## Key Configuration

- `config.yaml`: Hugo site config, menu structure, course params (assignments, classroom info)
- `data/schedule.yaml`: Course schedule driving the schedule partial. Each entry has: `week`, `day`, `topic`, `lecture`, `slides` (filename without extension), `r_readings` (R readings), `py_readings` (Python readings)

## R Development Notes

- Use `=` for assignment (not `<-`)
- Prefer `pkg::function()` syntax over importing functions
- Minimize comments (only for "why", not "how")

## New Lecture Workflow

A new lecture deck is not published until it has been revised. When drafting a new `LecXX.qmd`, do not add or fill in its `data/schedule.yaml` entry (the `slides:` field is what links the deck from the course schedule); the user will say when the deck is ready to be scheduled and published.

## Python Environment

The uv project for the course's Python code lives in `static/slides/` (`pyproject.toml`, `uv.lock`, `.venv`), with `static/slides/notes` as a workspace member (`notes/.venv` is a symlink to `../.venv`). It sits there because reticulate only finds a `.venv` in the working directory of the document being rendered, so a plain `quarto render`/`quarto preview` from any launcher picks it up. Add Python dependencies with `uv add <pkg>` run inside `static/slides` (never `uv pip install`, which a later sync would undo); run ad hoc checks with `static/slides/.venv/bin/python`. `config.yaml` ignores `.venv` so Hugo does not copy it into `docs/`.
