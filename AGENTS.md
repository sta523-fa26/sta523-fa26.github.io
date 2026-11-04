# Project instructions

## Version control

- Do not run any Git (`git`) or GitButler (`but`) command unless the user explicitly requests version-control work. This includes read-only inspection (`status`, `diff`, `log`, etc.), help/version commands, setup, branching, staging, committing, pushing, and history edits. Ordinary requests to review, edit, fix, or test files do not authorize version-control commands. Do not invoke Git indirectly through scripts or other tools to bypass this rule.
- Once version-control work is explicitly requested, use the project's configured choice of plain Git or GitButler. Determine the choice from existing project instructions or configuration files without running Git or GitButler commands. If the choice is absent, unclear, or the selected tool is not configured for the project, ask whether to use plain Git or GitButler and wait for the answer before running either tool. Do not silently fall back, initialize, migrate, or configure version control.
- A project's tool preference selects the tool; it is not standing permission to run version-control commands. Keep commands within the explicitly requested work. Do not proactively ask to use version control during unrelated editing tasks.
- The workflow guidance below applies only after explicit authorization and tool selection. GitButler-specific recipes apply only when GitButler is the selected tool; use plain Git when plain Git is selected.
- Assume multiple agents may be working in this repository. Do not move, amend, squash, discard, commit, push, or otherwise modify another agent's work unless the user asks.
- For commit just/only/specific changes on a new branch (selected-change requests), use the two-command fast path from the GitButler skill: `but diff`, then `but commit -b <branch> -m "message" <id> <id>`.
- For that fast path, after the commit succeeds, stop and summarize; do not run separate branch, staging, status, or diff commands unless the commit output is missing information you need.
- When using GitButler, use the installed GitButler skill for command recipes and syntax before guessing flags, using `--help`, or translating Git habits directly.
- GitButler mutation commands report their result without appending workspace status. Add `--status-after` only when the next step needs resulting workspace IDs or details; otherwise do not rerun status or diff to verify success.
- Do not create session branches automatically. Create branches only when authorized by the requested version-control work, using the selected tool. Commit only changes that belong to the requested task.
- Do not push or open pull requests unless the user asks.
- Keep commit messages and pull request descriptions succinct: explain what changed, why it changed, and any important decision.

### Amend local fixes into the right commits

- For small cleanup or follow-up fixes, amend an unpublished local commit when the change clearly belongs with that commit's intent.
- Do not create tiny fixup commits unless the user asks.
- Use the selected version-control tool to move the relevant changes into the commit where they belong.
- Ask before rewriting pushed, reviewed, shared, or ambiguous history.

### Split unrelated changes into separate commits

- If one file contains unrelated changes, split them by hunk instead of committing the whole file.
- Keep tests with the behavior they verify.
- Split generated output, docs-only edits, or mechanical cleanup into separate commits when each commit remains coherent on its own.
- If the split is ambiguous, summarize the options before committing.

## Lecture slides and pedagogy

### Explicit instructor preference

- Do not suggest or add introductory agenda, overview, learning-objective,
  roadmap, or "what we will cover" slides for lecture material. The lecture
  title and assigned readings provide that orientation. Do not reintroduce
  the same material under another heading.

### Defaults for reviewing and editing slides

- Follow the instructor's existing teaching approach. Generic presentation
  advice is not sufficient justification for a change. These rules apply
  to suggestions as well as direct edits.

- Treat the slides as material for an instructor-led class. A short prompt,
  unexplained output, or question without an immediate written answer is
  not automatically incomplete. Consider surrounding slides, fragments,
  exercises, and separate solutions before proposing additions.

- Preserve the timing of discovery. Do not move conclusions ahead of
  examples, reveal exercise answers, or add explanatory titles and comments
  that give away what students are meant to predict or discuss. Preserve
  existing fragment boundaries unless there is a concrete reason to change
  them.

- Preserve teaching through executable examples and their actual output.
  Closely related examples, small variations, and repeated code can support
  comparison. Do not remove them merely to reduce repetition or word count.

- Treat deliberate errors, warnings, surprising results, and unsuccessful
  first attempts as potential teaching devices. Check their role before
  correcting or suppressing them. Distinguish an example that demonstrates
  failure from an unintended defect.

- Preserve technical depth. Object representations, language semantics,
  dispatch, evaluation, storage, and execution details are often the point
  of the lesson. Do not automatically classify them as tangents, advanced
  material, or appendix content.

- Preserve useful comparisons within a slide, including code/output pairs
  and R/Python or package comparisons. Do not impose a one-example-per-slide
  rule or split material solely because it looks dense in the source.

- Evaluate layout in the rendered presentation. Existing columns, smaller
  text classes, tabs, and scrollable output are established tools. Identify
  actual clipping or readability problems before recommending restructuring.

- Keep teaching examples focused on the concept being demonstrated.
  Do not automatically expand them into production implementations with
  validation, abstractions, fallback paths, or exhaustive edge-case handling.
  Correct material inaccuracies with the smallest sufficient change.

- Match the local voice: direct technical prose, short topic or question
  titles, and concrete examples. Do not systematically add motivational
  framing, analogies, transitions, checkpoints, or repeated takeaways.
  Preserve existing uses where they serve the lesson.

- Respect the course sequence and assumed prior knowledge. Check earlier
  material before recommending another explanation of a prerequisite.
  Preserve recurring datasets and examples that connect lectures.

- Make review comments specific: identify the slide, the concrete problem,
  and how the proposed change helps within this teaching approach. Do not
  present a personal pedagogical preference as a correctness issue.

- Existing slides are evidence of style, not proof that every passage is
  endorsed. Prefer recurring patterns over isolated wording, particularly
  where previous AI edits may be present. Explicit instructor preferences
  take precedence.
