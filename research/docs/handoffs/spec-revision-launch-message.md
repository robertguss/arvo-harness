# Fresh-Session Launch Message — spec-revision

You are executing **spec-revision** (Revised Definitive
Specification) of **arvo-beam-harness-research**.

Start by reading
[`docs/handoffs/spec-revision-attachment-manifest.md`](spec-revision-attachment-manifest.md).
Then read every required-full artifact it lists.

The attached / on-disk files that govern this session:

1. `docs/prompts/15-specification-revision-prompt.md` — commission
2. `docs/00-program-blueprint.md` — accepted plan
3. `docs/01-research-charter.md` — accepted rules
4. `docs/specifications/01-definitive-specification.md` — proposed catalog (body to correct; not implementation authority)
5. `docs/reviews/01-specification-adversarial-review.md` — accepted findings `FND-001`…`FND-003` (proposed corrections)
6. `docs/reports/10-runtime-research-report.md` — accepted host nouns
7. `docs/reports/11-leftovers-research-report.md` — accepted cards
8. `docs/reports/12-score-harness-research-report.md` — accepted scoring methods
9. `docs/handoffs/spec-revision-attachment-manifest.md` — reading list
10. `docs/specifications/02-definitive-specification-revised.md` — skeleton to replace
11. `docs/validations/13-definitive-specification-validation.md` — mechanical Pass of the proposed spec
12. `docs/validations/14-specification-adversarial-review-validation.md` — mechanical Pass of the review
13. `program/contracts/definitive-specification.md`
14. `program/templates/requirement.md`
15. `AGENTS.md` (Exa REST)
16. `research-program.toml`

Blueprint and Charter are governing. The proposed specification
is the body you correct. The accepted review is proposed
corrections you must disposition. The three accepted reports
are evidence and recommendation (cite them; do not redesign
G-001…G-005 or promote Watch). This prompt commissions the
work. You write the revised specification.

Execute the complete task commissioned by
`docs/prompts/15-specification-revision-prompt.md`.

This session **does** write into the local repo. Produce the
complete standalone revised specification at:

`docs/specifications/02-definitive-specification-revised.md`

Use Exa **REST** (`EXA_API_KEY` in gitignored `.env`) only if a
load-bearing sentence on an already-cited official page is thin
in the revision’s use of it. Default: skip Exa. Do not harvest
new papers. Do not use Exa MCP.

Do not ask clarifying questions unless a true blocker exists
under the commissioning prompt.

Do not begin implementation-plan or any other stage.
Do not mark `spec-revision` accepted.
Do not run Harbor or boot Arvo.
Do not write Elixir.
Do not edit the proposed specification, the accepted review,
the Blueprint, or the Charter.

At the end provide:

1. The complete artifact on disk.
2. A brief plain-language summary for Robert (outside the artifact).
3. Any unmet requirement and why.
4. Any remaining blocker.
