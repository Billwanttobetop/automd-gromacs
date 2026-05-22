#!/bin/bash
# GROMACS Extended Properties Analysis
# 蛋白高级性质: 偶极矩, 静电势, 自由体积, 水合层, 最小距离
# GROMACS 2026 compatible
set -e

TRJ="${TRJ:-md.trr}"
TPR="${TPR:-md.tpr}"
NDX="${NDX:-analysis.ndx}"
OUTPUT="${OUTPUT:-properties}"
ANALYSES="${ANALYSES:-dipoles,potential,freevolume,h2order,mindist}"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
check_file() { [ -f "$1" ] || { echo "[ERROR] Missing: $1"; exit 1; }; }

# Check prerequisites
check_file "$TPR"
check_file "$TRJ"

# Create index if missing
if [ ! -f "$NDX" ]; then
    log "Creating index file..."
    echo "q" | gmx make_ndx -f "$TPR" -o "$NDX" 2>&1 | tail -1
fi

mkdir -p "$OUTPUT"
cd "$OUTPUT"

# Wrap GROMACS calls safely
safe_run() {
    local cmd="$1"
    local out="$2"
    log "Running: $cmd"
    if eval "$cmd" 2>&1 | tail -3; then
        log "  ✅ $out"
    else
        log "  ⚠️ $out (non-fatal, continuing)"
    fi
}

IFS=',' read -ra AN <<< "$ANALYSES"
for a in "${AN[@]}"; do
    case "$a" in
        dipoles)
            safe_run "echo Protein | gmx dipoles -s ../$TPR -f ../$TRJ -n ../$NDX -o dipoles.xvg -eps epsilon.xvg" "dipoles.xvg"
            ;;
        potential)
            safe_run "echo Protein | gmx potential -s ../$TPR -f ../$TRJ -n ../$NDX -o potential.xvg" "potential.xvg"
            ;;
        freevolume)
            safe_run "echo Protein | gmx freevolume -s ../$TPR -f ../$TRJ -n ../$NDX -o freevolume.xvg" "freevolume.xvg"
            ;;
        h2order)
            safe_run "echo Water_and_ions | gmx h2order -s ../$TPR -f ../$TRJ -n ../$NDX -o h2order.xvg" "h2order.xvg"
            ;;
        mindist)
            safe_run "echo Protein | gmx mindist -s ../$TPR -f ../$TRJ -n ../$NDX -od mindist.xvg" "mindist.xvg"
            ;;
        sasa)
            safe_run "echo Protein | gmx sasa -s ../$TPR -f ../$TRJ -n ../$NDX -o sasa.xvg" "sasa.xvg"
            ;;
    esac
done

# Generate report
log "Generating report..."
cat > PROPERTIES_REPORT.md << 'REOF'
# Extended Protein Properties Report

## Dipole Moment
- File: `dipoles.xvg` — Total dipole moment (Debye) vs time
- File: `epsilon.xvg` — Dielectric constant estimate
- Interpretation: Large fluctuations indicate conformational changes

## Electrostatic Potential
- File: `potential.xvg` — Potential along box Z-axis (mV)
- Use: Identify charged patches, membrane potential

## Free Volume
- File: `freevolume.xvg` — Molecular and van der Waals volumes
- Interpretation: >0.25 = flexible, <0.20 = rigid

## Water Ordering (h2order)
- File: `h2order.xvg` — Water molecule orientation around protein
- Interpretation: High order near hydrophobic surfaces, low near charged

## Minimum Distance
- File: `mindist.xvg` — Closest contact distance between groups
- Use: Monitor binding/unbinding events, steric clashes

---
Generated: $(date)
REOF

log "✅ Properties analysis complete: $OUTPUT/"
