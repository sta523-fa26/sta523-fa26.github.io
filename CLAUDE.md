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

## Key Configuration

- `config.yaml`: Hugo site config, menu structure, course params (assignments, classroom info)
- `data/schedule.yaml`: Course schedule driving the schedule partial. Each entry has: `week`, `day`, `topic`, `lecture`, `slides` (filename without extension), `r_readings` (R readings), `py_readings` (Python readings)

## R Development Notes

- Use `=` for assignment (not `<-`)
- Prefer `pkg::function()` syntax over importing functions
- Minimize comments (only for "why", not "how")
