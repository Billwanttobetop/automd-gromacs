#!/bin/bash
# protein - Protein-specific analysis toolkit
# DSSP, SASA, secondary structure, contacts

set -e

show_help() {
    cat << 'EOF'
protein - Protein-specific analysis

COMMANDS:
  dssp        Secondary structure (DSSP)
  sasa        Solvent accessible surface area
  hbond       Hydrogen bond analysis
  contact     Residue contact map
  rmsf        Per-residue flexibility

USAGE:
  protein dssp -s md.tpr -f md.xtc
  protein sasa -s md.tpr -f md.xtc
  protein hbond -s md.tpr -f md.xtc
  protein contact -s md.tpr -f md.xtc
  protein rmsf -s md.tpr -f md.xtc

OPTIONS:
  -s FILE      Structure/TPR file
  -f FILE      Trajectory file
  -o DIR       Output directory (default: protein_analysis)
  -b TIME      Begin time (ps)
  -e TIME      End time (ps)
  --group      Selection group (default: Protein)

EXAMPLES:
  # Full protein analysis
  protein dssp -s md.tpr -f md.xtc
  protein sasa -s md.tpr -f md.xtc
  protein hbond -s md.tpr -f md.xtc

  # Analyze specific region
  protein rmsf -s md.tpr -f md.xtc --group "r 10-50"

OUTPUT:
  dssp.xpm         - Secondary structure map
  sasa.xvg         - SASA vs time
  hbond.xvg        - H-bond count vs time
  contact.xpm      - Contact map
  rmsf.xvg         - Per-residue RMSF
EOF
}

CMD="${1:-}"
shift || true

case "$CMD" in
    dssp)
        TPR=""
        TRJ=""
        OUTDIR="protein_analysis"
        BEGIN=""
        END=""
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                -s) TPR="$2"; shift 2 ;;
                -f) TRJ="$2"; shift 2 ;;
                -o) OUTDIR="$2"; shift 2 ;;
                -b) BEGIN="$2"; shift 2 ;;
                -e) END="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        
        [[ -z "$TPR" || -z "$TRJ" ]] && { echo "ERROR: -s and -f required"; exit 1; }
        
        mkdir -p "$OUTDIR"
        cd "$OUTDIR"
        
        echo "Computing secondary structure (DSSP)..."
        
        # Check if dssp/mkdssp available
        if ! command -v dssp &>/dev/null && ! command -v mkdssp &>/dev/null; then
            echo "WARNING: dssp not installed, skipping"
            echo "Install: sudo apt-get install dssp"
            exit 1
        fi
        
        OPTS=""
        [[ -n "$BEGIN" ]] && OPTS="$OPTS -b $BEGIN"
        [[ -n "$END" ]] && OPTS="$OPTS -e $END"
        
        echo "Protein" | gmx do_dssp -s "../$TPR" -f "../$TRJ" -o dssp.xpm -sc dssp_summary.xvg $OPTS
        
        echo "✓ DSSP complete"
        echo "  dssp.xpm - structure map (view with xmgrace)"
        echo "  dssp_summary.xvg - structure vs time"
        ;;
        
    sasa)
        TPR=""
        TRJ=""
        OUTDIR="protein_analysis"
        GROUP="Protein"
        BEGIN=""
        END=""
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                -s) TPR="$2"; shift 2 ;;
                -f) TRJ="$2"; shift 2 ;;
                -o) OUTDIR="$2"; shift 2 ;;
                --group) GROUP="$2"; shift 2 ;;
                -b) BEGIN="$2"; shift 2 ;;
                -e) END="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        
        [[ -z "$TPR" || -z "$TRJ" ]] && { echo "ERROR: -s and -f required"; exit 1; }
        
        mkdir -p "$OUTDIR"
        cd "$OUTDIR"
        
        echo "Computing SASA for $GROUP..."
        
        OPTS=""
        [[ -n "$BEGIN" ]] && OPTS="$OPTS -b $BEGIN"
        [[ -n "$END" ]] && OPTS="$OPTS -e $END"
        
        echo "$GROUP" | gmx sasa -s "../$TPR" -f "../$TRJ" -o sasa.xvg -or sasa_residue.xvg $OPTS
        
        # Summary stats
        AVG=$(grep -v '^[@#]' sasa.xvg | awk '{sum+=$2; n++} END {printf "%.1f", sum/n}')
        
        echo "✓ SASA complete"
        echo "  Average SASA: $AVG nm²"
        echo "  sasa.xvg - total SASA vs time"
        echo "  sasa_residue.xvg - per-residue SASA"
        ;;
        
    hbond)
        TPR=""
        TRJ=""
        OUTDIR="protein_analysis"
        BEGIN=""
        END=""
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                -s) TPR="$2"; shift 2 ;;
                -f) TRJ="$2"; shift 2 ;;
                -o) OUTDIR="$2"; shift 2 ;;
                -b) BEGIN="$2"; shift 2 ;;
                -e) END="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        
        [[ -z "$TPR" || -z "$TRJ" ]] && { echo "ERROR: -s and -f required"; exit 1; }
        
        mkdir -p "$OUTDIR"
        cd "$OUTDIR"
        
        echo "Analyzing hydrogen bonds..."
        
        OPTS=""
        [[ -n "$BEGIN" ]] && OPTS="$OPTS -b $BEGIN"
        [[ -n "$END" ]] && OPTS="$OPTS -e $END"
        
        echo "Protein Protein" | gmx hbond -s "../$TPR" -f "../$TRJ" -num hbond.xvg $OPTS
        
        AVG=$(grep -v '^[@#]' hbond.xvg | awk '{sum+=$2; n++} END {printf "%.1f", sum/n}')
        
        echo "✓ H-bond analysis complete"
        echo "  Average H-bonds: $AVG"
        echo "  hbond.xvg - H-bond count vs time"
        ;;
        
    contact)
        TPR=""
        TRJ=""
        OUTDIR="protein_analysis"
        BEGIN=""
        END=""
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                -s) TPR="$2"; shift 2 ;;
                -f) TRJ="$2"; shift 2 ;;
                -o) OUTDIR="$2"; shift 2 ;;
                -b) BEGIN="$2"; shift 2 ;;
                -e) END="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        
        [[ -z "$TPR" || -z "$TRJ" ]] && { echo "ERROR: -s and -f required"; exit 1; }
        
        mkdir -p "$OUTDIR"
        cd "$OUTDIR"
        
        echo "Computing contact map..."
        
        OPTS=""
        [[ -n "$BEGIN" ]] && OPTS="$OPTS -b $BEGIN"
        [[ -n "$END" ]] && OPTS="$OPTS -e $END"
        
        echo "C-alpha C-alpha" | gmx mdmat -s "../$TPR" -f "../$TRJ" -mean contact_mean.xpm $OPTS
        
        echo "✓ Contact map complete"
        echo "  contact_mean.xpm - mean contact map"
        ;;
        
    rmsf)
        TPR=""
        TRJ=""
        OUTDIR="protein_analysis"
        GROUP="C-alpha"
        BEGIN=""
        END=""
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                -s) TPR="$2"; shift 2 ;;
                -f) TRJ="$2"; shift 2 ;;
                -o) OUTDIR="$2"; shift 2 ;;
                --group) GROUP="$2"; shift 2 ;;
                -b) BEGIN="$2"; shift 2 ;;
                -e) END="$2"; shift 2 ;;
                *) shift ;;
            esac
        done
        
        [[ -z "$TPR" || -z "$TRJ" ]] && { echo "ERROR: -s and -f required"; exit 1; }
        
        mkdir -p "$OUTDIR"
        cd "$OUTDIR"
        
        echo "Computing RMSF for $GROUP..."
        
        OPTS=""
        [[ -n "$BEGIN" ]] && OPTS="$OPTS -b $BEGIN"
        [[ -n "$END" ]] && OPTS="$OPTS -e $END"
        
        echo "$GROUP" | gmx rmsf -s "../$TPR" -f "../$TRJ" -o rmsf.xvg -res $OPTS
        
        AVG=$(grep -v '^[@#]' rmsf.xvg | awk '{sum+=$2; n++} END {printf "%.3f", sum/n}')
        MAX=$(grep -v '^[@#]' rmsf.xvg | awk 'BEGIN{max=0} {if($2>max) max=$2} END {printf "%.3f", max}')
        
        echo "✓ RMSF complete"
        echo "  Average RMSF: $AVG nm"
        echo "  Max RMSF: $MAX nm"
        echo "  rmsf.xvg - per-residue RMSF"
        ;;
        
    -h|--help|"")
        show_help
        exit 0
        ;;
        
    *)
        echo "Unknown command: $CMD"
        echo "Run 'protein --help' for usage"
        exit 1
        ;;
esac
