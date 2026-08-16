# Fresh-Session Launch Message — spec-review

You are executing **spec-review** (Specification Adversarial
Review) of **arvo-beam-harness-research**.

Start by reading
[`docs/handoffs/spec-review-attachment-manifest.md`](spec-review-attachment-manifest.md).
Then read every required-full artifact it lists.

The attached / on-disk files that govern this session:

1. `docs/prompts/14-specification-adversarial-review-prompt.md` — commission
2. `docs/00-program-blueprint.md` — accepted plan
3. `docs/01-research-charter.md` — accepted rules
4. `docs/specifications/01-definitive-specification.md` — proposed catalog (subject; not implementation authority)
5. `docs/reports/10-runtime-research-report.md` — accepted host nouns
6. `docs/reports/11-leftovers-research-report.md` — accepted cards
7. `docs/reports/12-score-harness-research-report.md` — accepted scoring methods
8. `docs/handoffs/spec-review-attachment-manifest.md` — reading list
9. `docs/reviews/01-specification-adversarial-review.md` — skeleton to replace
10. `docs/validations/13-definitive-specification-validation.md` — mechanical Pass
11. `program/contracts/adversarial-review.md`
12. `program/templates/finding.md`
13. `AGENTS.md` (Exa REST)
14. `research-program.toml`

Blueprint and Charter are governing. The proposed specification
is the subject. The three accepted reports are evidence and
recommendation (cite them; do not redesign G-001…G-005 or
promote Watch). This prompt commissions the work. You write
the review.

Execute the complete task commissioned by
`docs/prompts/14-specification-adversarial-review-prompt.md`.

This session **does** write into the local repo. Produce the
complete standalone review at:

`docs/reviews/01-specification-adversarial-review.md`

Use Exa **REST** (`EXA_API_KEY` in gitignored `.env`) only if a
load-bearing sentence on an already-cited official page is thin
in the specification’s use of it. Default: skip Exa. Do not
harvest new papers. Do not use Exa MCP.

Do not ask clarifying questions unless a true blocker exists
under the commissioning prompt.

Do not begin spec-revision or any other stage.
Do not mark `spec-review` accepted.
Do not run Harbor or boot Arvo.
Do not write Elixir.
Do not edit the proposed specification.

At the end provide:

1. The complete artifact on disk.
2. A brief plain-language summary for Robert (outside the artifact).
3. Any unmet requirement and why.
4. Any remaining blocker.
