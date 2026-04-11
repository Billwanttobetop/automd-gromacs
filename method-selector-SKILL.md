---
name: method-selector
description: "Decision skill for advanced MD method routing. Use when the question is not 'how to run X' but 'which method should I use'. Routes to the right AutoMD-GROMACS execution skill with low-token, actionable output."
version: 0.1.0
---

# Method Selector

Use this when the user needs `method choice`, not direct execution.

## When to use

Trigger if user asks:

- which method should I use?
- REMD vs MetaD vs umbrella vs QM/MM?
- I want PMF / better sampling / binding FE / reaction modeling / field response
- I do not know the right workflow yet

Do **not** use if:

- user already chose a method and wants execution details
- user only wants post-analysis on existing data
- user only wants a known script to run

## Input

Minimum:

- `goal`
- `system_type`
- `target_observable`

Helpful:

- `budget_level`
- `timescale_gap`
- `cv_known`
- `reaction_coordinate_known`
- `expertise_level`
- `priority`

## Output

Always return:

- `Recommended`
- `Why`
- `Avoid`
- `Next`

If info is incomplete:

- return top 2 candidate routes
- ask only the smallest missing question set

## Decision style

- route first
- explain briefly
- point to a real next skill
- prefer `safe + usable` over fancy but fragile

## Routing source

Read:

- `references/METHOD_SELECTION_INDEX.yaml`
- `references/design/decision-target-map.md`

Use canonical target ids in the decision output.
Only use script paths in `Next`.

Run the minimal public decision engine at:

- `scripts/decision/method-selector.py`

The engine reads packaged rules and returns canonical target ids plus the exact next script.

## Compact response template

```text
Recommended: <method / skill>
Why: <short reason>
Avoid: <1-3 bad fits>
Next: <exact skill/script>
```

## Example

Input:

- goal: explore unknown conformational transition
- system_type: protein
- target_observable: structure-ensemble
- cv_known: no
- timescale_gap: severe

Output:

- Recommended: `replica-exchange`
- Why: broad exploration needed, no reliable CV
- Avoid: `metadynamics`
- Next: `scripts/advanced/replica-exchange.sh`
