# Scattering Analysis Development Report

## Goal

Deliver a production-ready AutoMD-GROMACS `scattering-analysis` workflow focused on experiment-facing SAXS/SANS analysis, especially simulated-vs-experimental curve comparison.

## Delivered Files

- `scripts/analysis/scattering-analysis.sh`
- `references/troubleshoot/scattering-analysis-errors.md`
- `references/SKILLS_INDEX.yaml` (added `scattering_analysis` entry)

## Implemented Capabilities

### 1. SAXS calculation
- Uses `gmx saxs` when trajectory inputs are provided.
- Normalizes raw XVG output into a clean `q intensity error` table.

### 2. SANS / scattering organization
- Supports direct import of reduced SANS/scattering data via `--sans`.
- Attempts `gmx sans`, then falls back to `gmx scattering` when available.

### 3. q-range / contrast / input-prep guidance
- Generates `compare/input_preparation_notes.md` automatically.
- Embeds practical advice on q-range, unit harmonization, SAXS buffer subtraction, and SANS contrast matching.

### 4. Simulation-experiment comparison
- Interpolates simulation onto the experimental q-grid.
- Applies least-squares scaling to the simulated curve.
- Reports RMSE, MAE, RMS relative error, chi-like score, worst mismatch, and low/mid/high-q bias distribution.

### 5. Guinier / Kratky interpretation
- Estimates `Rg`, `I(0)`, fit window, `R^2`, and `qRg` criterion.
- Generates a Kratky-like folded/flexible interpretation summary.

### 6. Figures + Markdown report
- Produces `SCATTERING_REPORT.md` in all workflows.
- Produces `figures/scattering_plot.png` when `matplotlib` is available.
- Degrades gracefully to text-only outputs if plotting dependencies are absent.

### 7. Downstream export
- Writes `export/scattering_export.tsv` and `export/scattering_export.json`.
- Export layout is compatible with downstream plotting or packaging by `publication-viz` / `automd-viz`.

## Design Notes

- Primary workflow is experiment comparison rather than stand-alone calculation.
- Normalization is centralized so XVG and beamline-reduced text files share one path.
- Report text is short, machine-generated, and token-efficient.
- Error handling is aligned with existing AutoMD-GROMACS analysis scripts.

## Token Optimization

`SKILLS_INDEX` entry was kept compact and operational:
- fast dependency scan
- direct parameter hints
- experiment-specific interpretation rules
- no long tutorial prose

This keeps normal invocation within the intended low-context path, while detailed troubleshooting is moved to the dedicated error document.

## Known Boundaries

- Exact `gmx saxs/sans/scattering` flags can differ between GROMACS builds; the workflow is designed to fail clearly and allow external curve import fallback.
- Guinier/Kratky interpretation is intentionally basic and should be treated as a screening aid, not a substitute for full expert fitting.

## Quality Assessment

- Functionality coverage: complete for requested scope
- Experiment-facing utility: high
- Graceful fallback behavior: implemented
- Production readiness: suitable for real workflows with standard curve files and common GROMACS builds
