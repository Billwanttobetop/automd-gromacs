#!/bin/bash
# pca - Principal Component Analysis
# Analyze conformational dynamics via PCA

set -e

show_help() {
    cat << 'EOF'
pca - Principal Component Analysis

USAGE:
  pca -s md.tpr -f md.xtc -o pca_results/

WORKFLOW:
  1. Covariance matrix calculation (gmx covar)
  2. Eigenvector/eigenvalue extraction
  3. Projection onto principal components
  4. 2D/3D visualization data generation

OPTIONS:
  -s FILE      Structure/TPR file (required)
  -f FILE      Trajectory file (required)
  -o DIR       Output directory (default: pca_analysis)
  --group      Selection group (default: C-alpha)
  --npc N      Number of PCs to analyze (default: 10)
  --2d         Generate 2D projection (PC1 vs PC2)
  --3d         Generate 3D projection (PC1 vs PC2 vs PC3)
  --extreme    Extract extreme structures along PC1
  -b TIME      Begin time (ps)
  -e TIME      End time (ps)
  -h, --help   Show this help

EXAMPLES:
  # Basic PCA on C-alpha
  pca -s md.tpr -f md.xtc

  # PCA on backbone, 5-10 ns
  pca -s md.tpr -f md.xtc --group Backbone -b 5000 -e 10000

  # Full analysis with projections
  pca -s md.tpr -f md.xtc --2d --3d --extreme

OUTPUT:
  eigenval.xvg    - Eigenvalues (variance per PC)
  eigenvec.trr    - Eigenvectors
  proj_pc1.xvg    - Projection on PC1 vs time
  proj_2d.xvg     - 2D projection (PC1 vs PC2)
  extreme_pc1.pdb - Extreme structures along PC1
  pca_report.txt  - Summary statistics

INTERPRETATION:
  - PC1 captures largest variance (main motion)
  - Eigenvalues show % variance explained
  - Projections reveal conformational transitions
  - Extreme structures show motion endpoints
EOF
}

# Defaults
TPR=""
TRJ=""
OUTDIR="pca_analysis"
GROUP="C-alpha"
NPC=10
DO_2D=0
DO_3D=0
DO_EXTREME=0
BEGIN=""
END=""

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -s) TPR="$2"; shift 2 ;;
        -f) TRJ="$2"; shift 2 ;;
        -o) OUTDIR="$2"; shift 2 ;;
        --group) GROUP="$2"; shift 2 ;;
        --npc) NPC="$2"; shift 2 ;;
        --2d) DO_2D=1; shift ;;
        --3d) DO_3D=1; shift ;;
        --extreme) DO_EXTREME=1; shift ;;
        -b) BEGIN="$2"; shift 2 ;;
        -e) END="$2"; shift 2 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

# Validate
[[ -z "$TPR" || -z "$TRJ" ]] && { echo "ERROR: -s and -f required"; exit 1; }
[[ ! -f "$TPR" ]] && { echo "ERROR: TPR not found: $TPR"; exit 1; }
[[ ! -f "$TRJ" ]] && { echo "ERROR: Trajectory not found: $TRJ"; exit 1; }

# Setup
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "=== PCA Analysis ==="
echo "Structure: $TPR"
echo "Trajectory: $TRJ"
echo "Group: $GROUP"
echo ""

# Build time options
TIME_OPTS=""
[[ -n "$BEGIN" ]] && TIME_OPTS="$TIME_OPTS -b $BEGIN"
[[ -n "$END" ]] && TIME_OPTS="$TIME_OPTS -e $END"

# Step 1: Covariance matrix
echo "[1/4] Computing covariance matrix..."
echo "$GROUP" | gmx covar -s "../$TPR" -f "../$TRJ" -o eigenval.xvg -v eigenvec.trr -ascii eigenvec.dat $TIME_OPTS || {
    echo "ERROR: covar failed"
    exit 1
}

# Step 2: Project on PCs
echo "[2/4] Projecting trajectory on PCs..."
for i in $(seq 1 $NPC); do
    echo "$GROUP" | gmx anaeig -s "../$TPR" -f "../$TRJ" -v eigenvec.trr -first $i -last $i -proj proj_pc${i}.xvg $TIME_OPTS 2>/dev/null || true
done

# Step 3: 2D projection
if [[ $DO_2D -eq 1 ]]; then
    echo "[3/4] Generating 2D projection (PC1 vs PC2)..."
    echo "$GROUP" | gmx anaeig -s "../$TPR" -f "../$TRJ" -v eigenvec.trr -first 1 -last 2 -2d proj_2d.xvg $TIME_OPTS
fi

# Step 4: 3D projection
if [[ $DO_3D -eq 1 ]]; then
    echo "[3/4] Generating 3D projection (PC1 vs PC2 vs PC3)..."
    echo "$GROUP" | gmx anaeig -s "../$TPR" -f "../$TRJ" -v eigenvec.trr -first 1 -last 3 -3d proj_3d.xvg $TIME_OPTS
fi

# Step 5: Extreme structures
if [[ $DO_EXTREME -eq 1 ]]; then
    echo "[4/4] Extracting extreme structures along PC1..."
    echo "$GROUP" | gmx anaeig -s "../$TPR" -f "../$TRJ" -v eigenvec.trr -first 1 -last 1 -extr extreme_pc1.pdb -nframes 10 $TIME_OPTS
fi

# Generate report
echo "Generating report..."

cat > pca_report.txt << REPORT
PCA Analysis Report
===================

Input:
  Structure: $TPR
  Trajectory: $TRJ
  Selection: $GROUP
  Time range: ${BEGIN:-0} - ${END:-end} ps

Eigenvalues (top 10):
$(head -20 eigenval.xvg | grep -v '^[@#]' | head -10 | awk '{printf "  PC%d: %.4f (%.2f%%)\n", NR, $2, $2*100}')

Cumulative variance:
$(head -20 eigenval.xvg | grep -v '^[@#]' | head -10 | awk 'BEGIN{sum=0} {sum+=$2; printf "  PC1-%d: %.2f%%\n", NR, sum*100}')

Output files:
  eigenval.xvg     - Eigenvalues
  eigenvec.trr     - Eigenvectors
  proj_pc*.xvg     - PC projections vs time
REPORT

[[ $DO_2D -eq 1 ]] && echo "  proj_2d.xvg      - 2D projection" >> pca_report.txt
[[ $DO_3D -eq 1 ]] && echo "  proj_3d.xvg      - 3D projection" >> pca_report.txt
[[ $DO_EXTREME -eq 1 ]] && echo "  extreme_pc1.pdb  - Extreme structures" >> pca_report.txt

cat >> pca_report.txt << REPORT

Interpretation:
  - PC1 captures the largest conformational change
  - First 2-3 PCs typically explain 60-80% variance
  - Projections show transitions between states
  - Extreme structures visualize motion endpoints

Visualization:
  # Plot eigenvalues
  xmgrace eigenval.xvg

  # Plot PC1 vs time
  xmgrace proj_pc1.xvg

  # Plot 2D projection
  xmgrace proj_2d.xvg

  # View extreme structures
  pymol extreme_pc1.pdb
REPORT

echo ""
echo "✓ PCA complete"
echo "Output: $OUTDIR/"
echo ""
cat pca_report.txt

exit 0
