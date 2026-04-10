---
name: automd-gromacs
description: "AutoMD-GROMACS: AI-friendly molecular dynamics automation for GROMACS with workflow, enhanced sampling, special-system simulation, advanced analysis, and publication-ready visualization. Built-in troubleshooting and token-optimized execution. Part of the AutoMD series."
version: 4.0.0
author: Guo Xuan
organization: Hong Kong University of Science and Technology (Guangzhou)
homepage: https://github.com/Billwanttobetop/automd-gromacs
metadata:
  openclaw:
    emoji: "🧬"
    category: science
    requires:
      bins:
        - gmx
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
---

# AutoMD-GROMACS

AutoMD-GROMACS is an AI-oriented automation toolkit for GROMACS. It packages end-to-end simulation workflows, enhanced sampling, special-system simulation, advanced analysis, and publication-ready visualization into executable Skills with troubleshooting references.

## Scope

- Core workflow: setup, equilibration, production, preprocessing, utilities
- Enhanced sampling: umbrella, free energy, replica exchange, metadynamics, steered MD, enhanced sampling, accelerated MD
- Special systems: membrane, ligand, coarse-grained, electric field, non-equilibrium, QM/MM
- Analysis: trajectory, binding, property, membrane, scattering, free-energy, protein-focused analyses
- Visualization: publication-ready plotting and structure/trajectory rendering

## Quick Start

1. Read `references/SKILLS_INDEX.yaml`
2. Pick the relevant script under `scripts/`
3. Run `bash scripts/<group>/<skill>.sh ...`
4. If something fails, read `references/troubleshoot/<skill>-errors.md`

## Design

- Executable workflows over tutorial prose
- Layered disclosure for low token overhead
- Embedded domain knowledge from GROMACS practice
- Auto-repair and troubleshooting guidance by default

## Project Info

- Version: 4.0.0
- Based on: GROMACS 2026.1
- License: MIT
- Homepage: https://github.com/Billwanttobetop/automd-gromacs

**Get started:** `read references/SKILLS_INDEX.yaml`
