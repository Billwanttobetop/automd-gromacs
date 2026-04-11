# AutoMD-GROMACS v5.0.0

## Release Focus

AutoMD-GROMACS v5.0.0 upgrades the project from an execution-centered GROMACS skill set into a public OpenClaw skill with a decision layer.

This version does not replace the existing execution framework.
It adds a routing layer on top of it so agents can choose the right method before running the workflow.

## What Is New

### 1. Decision Layer

A new public decision entry is added:

- `method-selector`
- `scripts/decision/method-selector.py`

Purpose:
- choose the right MD method before execution
- reduce wrong-method starts
- return a stable low-token contract:
  - `Recommended`
  - `Why`
  - `Avoid`
  - `Next`

### 2. Public Layer Model

The product-facing stack is now explicitly defined as:

```text
decision -> execution -> validation
```

This separates:
- method selection
- workflow execution
- result interpretation and validation

### 3. Canonical Target Map

A stable public target naming system is now included.

Key rule:
- use canonical target ids in routing output
- use script paths only in `Next`

Examples:
- `replica-exchange`
- `freeenergy`
- `trajectory-analysis`
- `free-energy-analysis`
- `publication-viz`

### 4. Structured Routing Rules

Method-routing rules are now packaged in:

- `references/METHOD_SELECTION_INDEX.yaml`

This file defines:
- input fields
- normalized value sets
- routing rules
- fallback behavior
- canonical target map
- naming rules

### 5. Publish Cleanup

The package has been cleaned for public OpenClaw distribution:

- broken index references removed
- `SKILLS_INDEX.yaml` repaired and normalized
- `.skillignore` tightened to exclude development/test/publish noise
- public-facing docs updated to reflect decision-layer usage

## What Stays the Same

v5.0.0 keeps the existing AutoMD-GROMACS execution framework.

The following are preserved and reused:
- existing scripts under `scripts/advanced/`
- existing scripts under `scripts/analysis/`
- low-token design approach
- progressive disclosure structure
- troubleshooting-first style

So this is:
- an upgrade extension
- not a rewrite
- not a replacement of prior skills

## Why v5 Matters

Before v5:
- AutoMD-GROMACS mainly answered: after a method is chosen, how should it run?

In v5:
- AutoMD-GROMACS also answers: before execution, which method should be chosen?

That makes the skill more useful for:
- novice OpenClaw users
- mixed-capability agents
- workflows where wrong-method prevention matters
- public reusable deployment beyond the original local workspace

## Recommended Entry Points

### If method is not chosen yet

Use:

```bash
python3 scripts/decision/method-selector.py \
  --goal "binding free energy from a docked complex" \
  --system-type protein-ligand \
  --target-observable binding-free-energy \
  --pretty
```

### If method is already known

Go directly to the relevant execution script under:
- `scripts/basic/`
- `scripts/advanced/`
- `scripts/analysis/`
- `scripts/visualization/`

## Included Public References

- `SKILL.md`
- `method-selector-SKILL.md`
- `references/SKILLS_INDEX.yaml`
- `references/METHOD_SELECTION_INDEX.yaml`
- `references/design/decision-target-map.md`
- `references/troubleshoot/`

## Summary

AutoMD-GROMACS v5.0.0 is the first version that formalizes:

- decision layer
- execution framework
- validation layer

in one public OpenClaw skill package.
