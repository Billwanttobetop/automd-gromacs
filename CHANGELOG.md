# Changelog

## [5.0.1] - 2026-05-22

### Added
- ISPETase (PDB: 8H5K) complete example workflow under `examples/ispetase/`
  - Setup → Equilibration → Production → Analysis (real trajectory)
  - PCA eigenvalues, 2D projection, clustering results
  - Self-contained README with reproduce commands
- Example READMEs for freeenergy, umbrella, membrane, and ligand workflows
- `accelerated-md` entry in SKILLS_INDEX.yaml

### Fixed
- `bc` dependency replaced with `awk` in setup.sh, equilibration.sh
- `base_dir` hardcoded path → `${SKILL_ROOT:-.}` in SKILLS_INDEX.yaml
- SKILL.md Quick Start: clarified troubleshoot path resolution
- Aligned `protein.sh` references between SKILLS_INDEX and METHOD_SELECTION_INDEX
- Removed stale `SKILLS_INDEX.yaml.backup` (v2.0)

### Removed
- 69 development artifacts (dev reports, test reports, publish logs) from git tracking
- 3 orphan/unreferenced scripts: `analysis/pca.sh`, `workflow/workflow.sh`, `analysis/protein.sh`
- `method-selector-SKILL.md` (orphan, content covered by main SKILL.md)

### Changed
- `.gitignore` and `.skillignore` updated to exclude development artifacts
- Root directory cleaned: 85+ files → 5 core files

## [5.0.0] - 2026-04-11

### Added
- Decision layer: method-selector with METHOD_SELECTION_INDEX.yaml
- Core workflow: setup, equilibration, production, preprocessing, utilities
- Enhanced sampling: umbrella, free energy, replica exchange, metadynamics, steered MD, enhanced sampling, accelerated MD
- Special systems: membrane, ligand, coarse-grained, electric field, non-equilibrium, QM/MM
- Validation: trajectory, binding, property, membrane, scattering, free-energy, protein-focused analyses
- Visualization: publication-ready plotting (Nature/Science/Cell styles)
- Token-optimized troubleshooting references for every workflow
- Quick reference parameters embedded in each script
