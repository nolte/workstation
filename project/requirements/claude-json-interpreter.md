# Requirements — Robust interpreter selection for the `.claude.json` modify_ script

<!--
Produced via the `requirements-elicit` skill, following
spec/project/requirements-elicitation/ (canonical source read from the
upstream nolte-shared plugin; the spec is not yet vendored into this repo's
spec/ tree — see the open risk below).
`c_d` is an uncertainty proxy (self-consistency-derived), not a calibrated
probability. A requirement is `confirmed` only after an explicit teach-back or
an authoritative operator answer.
-->

## Bounded context

- **What:** Make the chezmoi `modify_` script `chezmoi_config/modify_dot_claude.json`
  reliably inject the `mcpServers.github` entry into `~/.claude.json` on any
  provisioned machine, without depending on an asdf-shimmed interpreter that
  exit-126s in chezmoi's minimal execution environment.
- **For whom:** Operators/developers who provision a workstation via
  `chezmoi init --apply`/`chezmoi update` against `nolte/workstation`; the
  consumer of the rendered file is Claude Code on the target machine.
- **Out of scope (confirmed):** The stale `~/taskfile.yaml` not including the
  worktree collection, and any *other* provisioning step that could hit the same
  asdf-shim-126 trap. This branch touches **only** `modify_dot_claude.json`.

## Understanding KPI

- Thresholds: `τ_low = 0.4`, `τ_high = 0.8`, self-consistency `k = 2`, question budget = `5` (spec defaults; unchanged)
- `U_gate = min_d c_d` over required dimensions = **0.85**
- Termination: `saturation` — both below-`τ_high` dimensions were lifted by
  authoritative operator answers; no remaining candidate question has positive
  net EVPI (the remaining dimensions are evidence-backed by the researched plan
  and the existing code).

### Gap matrix

| Dimension | Applicable | `c_d` | Uncertainty source | Evidence event |
|---|---|---|---|---|
| `functional` | yes | 0.90 | interpretation | Operator's authored plan §1–§3 + existing `modify_dot_claude.json` merge logic; teach-back confirmed |
| `non_functional` | yes | 0.88 | specification | Operator answer: silent pass-through (never break `apply`); reliability/idempotency/no-secrets from plan §5 |
| `constraints` | yes | 0.90 | interpretation | Verified root-cause research in plan §2 (asdf shims exit 126, `/usr/bin/python3` works in stripped env) |
| `domain_objects` | yes | 0.85 | interpretation | plan §2: `~/.claude.json`, `mcpServers.github`, interpreter candidate list |
| `actors` | yes | 0.85 | interpretation | plan §2: chezmoi pipes stdin→stdout; the provisioned machine/operator |
| `acceptance_criteria` | yes | 0.90 | interpretation | plan §4/§6 resume-anchor checklist (frozen-snapshot verify, 126 repro+fix, pre-commit, `chezmoi cat`); teach-back confirmed |
| `edge_cases` | yes | 0.85 | specification | Operator answer on the no-interpreter case; heredoc-stdin regression guard + idempotency from plan §5 |
| `scope_boundaries` | yes | 0.90 | specification | Operator answer: only `modify_dot_claude.json`; taskfile + other traps out of scope |

## Requirements

<!-- EARS/CNL form, tagged confirmed/assumed, traceable to the utterance/source
     that produced each. -->

- **R1** — WHEN the `modify_dot_claude.json` script runs, the script SHALL select its
  interpreter by **test-execution** — iterating a candidate list and running
  `"$cand" -c ''`, taking the first that exits 0 — rather than by `command -v`.
  - _dimension_: `functional`, `constraints` · _status_: `confirmed` · _source_: plan §3 "Select the interpreter by test-execution, not by `command -v`"

- **R2** — WHEN building the candidate list, the script SHALL order **system paths first**
  (`/usr/bin/python3`, `/usr/local/bin/python3`, `/bin/python3`) ahead of the
  PATH-resolved names (`python3`, `python`), so a working system interpreter
  wins over a broken asdf shim.
  - _dimension_: `functional`, `constraints` · _status_: `confirmed` · _source_: plan §3 candidate order; §2 "Order system paths first so a working system interpreter wins over a broken shim"

- **R3** — WHEN no candidate executes successfully, the script SHALL pass stdin through
  unchanged (`cat`) and `exit 0`, so `chezmoi apply`/`update` never breaks; the
  `mcpServers.github` entry is simply not added on that run.
  - _dimension_: `edge_cases`, `non_functional` · _status_: `confirmed` · _source_: operator answer "Silent pass-through (Plan-Default)"

- **R4** — WHEN a working interpreter is selected, the script SHALL merge **only**
  `mcpServers.github` (remote OAuth GitHub MCP, URL-only, no secret) and SHALL
  preserve every other key of the piped `~/.claude.json` byte-for-byte.
  - _dimension_: `functional`, `non_functional` · _status_: `confirmed` · _source_: plan §5 invariants; existing merge logic

- **R5** — The script SHALL pass its merge program via `-c '...'` and SHALL NOT pass it
  as a heredoc on stdin, so `sys.stdin` stays the piped file (guards against the
  known regression that collapsed the file to just the github entry).
  - _dimension_: `constraints`, `edge_cases` · _status_: `confirmed` · _source_: plan §2 prior-art bug + §5 invariant "Program passed via `-c '...'`, never a heredoc on stdin"

- **R6** — The script's output SHALL byte-match Claude Code's serialisation: 2-space
  indent, raw UTF-8, no trailing newline; and re-running the script SHALL be
  idempotent.
  - _dimension_: `non_functional`, `acceptance_criteria` · _status_: `confirmed` · _source_: plan §3/§5 "byte-exact serialisation"; §4 idempotency check

- **R7** — The change SHALL be limited to `chezmoi_config/modify_dot_claude.json`; the
  stale `~/taskfile.yaml` and any other asdf-shim-126-prone provisioning step
  are out of scope for this branch.
  - _dimension_: `scope_boundaries` · _status_: `confirmed` · _source_: operator answer "Nur modify_dot_claude.json (Plan-Default)"

**Acceptance criteria (from plan §4/§6, all `confirmed`):**
1. Frozen-snapshot verification: only `mcpServers` changes, existing entries
   (e.g. `reachy-mini`) preserved byte-identical, `github` added, idempotent.
2. The 126 scenario is reproduced (`PATH=~/.asdf/shims:/usr/bin:/bin`) and proven
   fixed via the `/usr/bin/python3` fallback (exit 0, correct output).
3. `pre-commit run --files chezmoi_config/modify_dot_claude.json` is green.
4. `chezmoi cat ~/.claude.json` against this worktree renders the merged file
   without exit 126.

## Surviving assumptions / open risks

- **Spec-not-vendored (process risk):** `spec/project/requirements-elicitation/`
  is not present in this repo's `spec/` tree; this elicitation used the canonical
  upstream copy from the nolte-shared plugin. Consumers that verify the spec is
  reachable *in-project* will not find it. Recommend vendoring the planning specs
  under `spec/project/` (matches the recorded portfolio note).
- **Silent pass-through trade-off (accepted):** R3 means a genuinely
  misprovisioned machine (no working python at all) fails *silently* — the github
  MCP entry is quietly absent rather than surfacing a loud error. Operator
  explicitly accepted this in favour of never breaking `chezmoi apply`.
- No below-`τ_high` cells remain; the interview terminated by saturation, not by
  the question-budget cap.
