# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

Hugo-based academic course website for Sta 523L "Statistical Programming" (Fall 2026). Combines Hugo SSG for the main site with Quarto revealjs presentations for lecture slides.

**Build pipeline**: QMD → HTML (quarto render) → PDF (renderthis::to_pdf)

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

Slides live in `static/slides/*.qmd` using revealjs format with custom theme (`slides.scss`). Each slide uses knitr engine for R code execution.

**Note:** Sections titled "Example" are live-coded demonstrations done in class and intentionally have no content in the slides.

**Note:** When reviewing slides, do not review or comment on the content of exercises or examples (spelling and grammar checks are fine). These are meant to be external live-coded experiences for students, so the content will usually not be in the slides.

## Key Configuration

- `config.yaml`: Hugo site config, menu structure, course params (assignments, classroom info)
- `data/schedule.yaml`: Course schedule driving the schedule partial. Each entry has: `week`, `day`, `topic`, `lecture`, `slides` (filename without extension), `r_readings` (R readings), `py_readings` (Python readings)

## R Development Notes

- Use `=` for assignment (not `<-`)
- Prefer `pkg::function()` syntax over importing functions
- Minimize comments (only for "why", not "how")