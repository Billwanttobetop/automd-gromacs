---
name: automd-gromacs
description: "AutoMD-GROMACS: Automated molecular dynamics simulation workflow - 13 Skills covering system setup, equilibration, production, analysis, free energy, ligand binding, membrane proteins, umbrella sampling, PCA, and workflows. Built-in auto-repair, 84.7% token savings. Part of the AutoMD series."
version: 2.1.0
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

Automated molecular dynamics simulation workflow for GROMACS, optimized for AI agents with built-in auto-repair and manual knowledge. Part of the **AutoMD series** for automated MD simulations.

## Quick Start

1. Read the index: `read references/SKILLS_INDEX.yaml`
2. Choose a skill (setup, freeenergy, umbrella, etc.)
3. Execute: `bash scripts/<skill>.sh <args>`
4. If errors occur: `read references/troubleshoot/<skill>-errors.md`

## 13 Skills Overview

**Basic (P0):** setup, equilibration, production, analysis  
**Advanced (P1):** freeenergy, umbrella, membrane, ligand  
**Extended (P2):** pca, workflow  
**Utility (P3):** protein, utils, run

## Architecture

3-layer progressive disclosure:
- Layer 1: SKILL.md (this file) - quick overview
- Layer 2: references/SKILLS_INDEX.yaml - structured index
- Layer 3: scripts/*.sh + references/troubleshoot/*.md - executable scripts + troubleshooting

## Design Principles

- Executable > Readable: Direct runnable commands, not tutorials
- Structured > Textual: YAML/scripts, not long docs
- Embedded Facts > External References: 90+ manual knowledge points embedded
- Auto-Repair > Manual Intervention: 8+ auto-repair functions

## Token Optimization

- Normal flow: 2,300 tokens (vs traditional 15,000)
- 84.7% savings, 100% technical accuracy maintained

## Project Info

- Version: 2.1.0
- Based on: GROMACS 2026.1
- License: MIT
- Verified: Real system validation (LYSOZYME 38376 atoms)

---

**Get started:** `read references/SKILLS_INDEX.yaml`
