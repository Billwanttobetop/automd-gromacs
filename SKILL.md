---
name: automd-gromacs
description: "AutoMD-GROMACS: AI-friendly molecular dynamics automation for GROMACS with workflow, enhanced sampling, special-system simulation, advanced analysis, and publication-ready visualization. Built-in troubleshooting and token-optimized execution. Part of the AutoMD series."
metadata:
  openclaw:
    emoji: "🧬"
    category: science
    requires:
      bins:
        - gmx
        - python3
    install:
      - id: conda
        kind: conda
        channel: conda-forge
        package: gromacs
        bins:
          - gmx
        label: Install GROMACS via conda
      - id: manual
        kind: manual
        url: https://manual.gromacs.org/current/install-guide/index.html
        label: Install GROMACS from source
      - id: pyyaml
        kind: manual
        url: https://pyyaml.org/wiki/PyYAMLDocumentation
        label: Install PyYAML for the decision layer (`pip install pyyaml`)
---

# AutoMD-GROMACS

AutoMD-GROMACS is an AI-oriented automation toolkit for GROMACS. It packages decision-layer routing, end-to-end simulation workflows, enhanced sampling, special-system simulation, advanced analysis, and publication-ready visualization into a public OpenClaw skill with troubleshooting references.

Project metadata:
- Version: 5.0.0
- Author: Guo Xuan
- Organization: Hong Kong University of Science and Technology (Guangzhou)
- Homepage: https://github.com/Billwanttobetop/automd-gromacs

## Scope

- Decision layer: method routing before execution via `method-selector`
- Core workflow: setup, equilibration, production, preprocessing, utilities
- Enhanced sampling: umbrella, free energy, replica exchange, metadynamics, steered MD, enhanced sampling, accelerated MD
- Special systems: membrane, ligand, coarse-grained, electric field, non-equilibrium, QM/MM
- Validation and analysis: trajectory, binding, property, membrane, scattering, free-energy, protein-focused analyses
- Visualization: publication-ready plotting and structure/trajectory rendering

## Quick Start

1. Read `references/SKILLS_INDEX.yaml`
2. If the method is not chosen yet, use `scripts/decision/method-selector.py`
3. Run the recommended script under `scripts/`
4. If something fails, read `references/troubleshoot/<skill>-errors.md`

Example:

```bash
python3 scripts/decision/method-selector.py \
  --goal "binding free energy from a docked complex" \
  --system-type protein-ligand \
  --target-observable binding-free-energy \
  --pretty
```

## Design

- Decision -> execution -> validation as the public product stack
- Executable workflows over tutorial prose
- Layered disclosure for low token overhead
- Embedded domain knowledge from GROMACS practice
- Auto-repair and troubleshooting guidance by default

## Project Info

- Version: 5.0.0
- Based on: GROMACS 2026.1
- Runtime needs: `python3`, `PyYAML`, `gmx`
- License: MIT
- Homepage: https://github.com/Billwanttobetop/automd-gromacs

**Get started:** `read references/SKILLS_INDEX.yaml`
