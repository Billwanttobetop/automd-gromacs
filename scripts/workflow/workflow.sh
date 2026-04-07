#!/bin/bash
# workflow - End-to-end GROMACS workflow automation
# Complete pipeline from PDB to production MD

set -e

show_help() {
    cat << 'EOF'
workflow - End-to-end GROMACS automation

USAGE:
  workflow -i protein.pdb -o project_dir/

PIPELINE:
  1. System preparation (pdb2gmx, solvate, ions)
  2. Energy minimization
  3. NVT equilibration
  4. NPT equilibration
  5. Production MD
  6. Basic analysis (RMSD, RMSF, Rg)

OPTIONS:
  -i FILE      Input PDB file (required)
  -o DIR       Output directory (default: workflow_output)
  --ff         Force field (default: amber99sb-ildn)
  --water      Water model (default: tip3p)
  --box        Box distance (default: 1.0 nm)
  --mdtime     Production time (default: 10 ns)
  --temp       Temperature (default: 300 K)
  --quick      Skip analysis
  -h, --help   Show this help

EXAMPLES:
  # Full workflow with defaults
  workflow -i protein.pdb

  # Custom parameters
  workflow -i protein.pdb --ff charmm36 --mdtime 50

  # Quick run (no analysis)
  workflow -i protein.pdb --quick

OUTPUT:
  setup/          - System preparation
  em/             - Energy minimization
  nvt/            - NVT equilibration
  npt/            - NPT equilibration
  md/             - Production MD
  analysis/       - Analysis results
  workflow.log    - Complete log
  REPORT.md       - Summary report

ESTIMATED TIME:
  Setup:        5 min
  EM:           10 min
  NVT:          15 min
  NPT:          15 min
  MD (10 ns):   2-4 hours
  Analysis:     10 min
EOF
}

# Defaults
INPUT=""
OUTDIR="workflow_output"
FF="amber99sb-ildn"
WATER="tip3p"
BOX_DIST="1.0"
MD_TIME=10  # ns
TEMP=300
QUICK=0
NTOMP=2

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -i) INPUT="$2"; shift 2 ;;
        -o) OUTDIR="$2"; shift 2 ;;
        --ff) FF="$2"; shift 2 ;;
        --water) WATER="$2"; shift 2 ;;
        --box) BOX_DIST="$2"; shift 2 ;;
        --mdtime) MD_TIME="$2"; shift 2 ;;
        --temp) TEMP="$2"; shift 2 ;;
        --quick) QUICK=1; shift ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

# Validate
[[ -z "$INPUT" ]] && { echo "ERROR: -i input PDB required"; exit 1; }
[[ ! -f "$INPUT" ]] && { echo "ERROR: Input not found: $INPUT"; exit 1; }

# Setup
mkdir -p "$OUTDIR"
cd "$OUTDIR"
exec > >(tee workflow.log) 2>&1

echo "=== GROMACS Workflow ==="
echo "Input: $INPUT"
echo "Force field: $FF"
echo "Water: $WATER"
echo "MD time: $MD_TIME ns"
echo ""

START_TIME=$(date +%s)

# Phase 1: System preparation
echo "[1/6] System preparation..."
mkdir -p setup
cd setup

echo "1" | gmx pdb2gmx -f "../../$INPUT" -o protein.gro -p topol.top -water "$WATER" -ff "$FF" -ignh
gmx editconf -f protein.gro -o box.gro -c -d "$BOX_DIST" -bt dodecahedron
gmx solvate -cp box.gro -cs spc216.gro -o solvated.gro -p topol.top

# Add ions
cat > ions.mdp << 'MDP'
integrator = steep
emtol = 1000.0
nsteps = 500
nstlist = 1
cutoff-scheme = Verlet
ns_type = grid
coulombtype = PME
rcoulomb = 1.0
rvdw = 1.0
pbc = xyz
MDP

gmx grompp -f ions.mdp -c solvated.gro -p topol.top -o ions.tpr -maxwarn 2
echo "SOL" | gmx genion -s ions.tpr -o system.gro -p topol.top -pname NA -nname CL -neutral -conc 0.15

cd ..
echo "✓ Setup complete"

# Phase 2: Energy minimization
echo "[2/6] Energy minimization..."
mkdir -p em
cd em

cat > em.mdp << 'MDP'
integrator = steep
emtol = 1000.0
nsteps = 50000
nstlist = 10
cutoff-scheme = Verlet
ns_type = grid
coulombtype = PME
rcoulomb = 1.0
rvdw = 1.0
DispCorr = EnerPres
pbc = xyz
MDP

gmx grompp -f em.mdp -c ../setup/system.gro -p ../setup/topol.top -o em.tpr -maxwarn 2
export OMP_NUM_THREADS=$NTOMP
gmx mdrun -v -deffnm em -ntmpi 1 -ntomp $NTOMP

cd ..
echo "✓ EM complete"

# Phase 3: NVT equilibration
echo "[3/6] NVT equilibration..."
mkdir -p nvt
cd nvt

cat > nvt.mdp << MDP
integrator = md
dt = 0.002
nsteps = 50000
nstenergy = 5000
nstlog = 5000
nstxout-compressed = 5000
continuation = no
constraint_algorithm = lincs
constraints = h-bonds
cutoff-scheme = Verlet
ns_type = grid
nstlist = 10
rcoulomb = 1.0
rvdw = 1.0
DispCorr = EnerPres
coulombtype = PME
tcoupl = V-rescale
tc-grps = Protein Non-Protein
tau_t = 0.1 0.1
ref_t = $TEMP $TEMP
pcoupl = no
pbc = xyz
gen_vel = yes
gen_temp = $TEMP
gen_seed = -1
define = -DPOSRES
MDP

gmx grompp -f nvt.mdp -c ../em/em.gro -r ../em/em.gro -p ../setup/topol.top -o nvt.tpr -maxwarn 2
gmx mdrun -v -deffnm nvt -ntmpi 1 -ntomp $NTOMP

cd ..
echo "✓ NVT complete"

# Phase 4: NPT equilibration
echo "[4/6] NPT equilibration..."
mkdir -p npt
cd npt

cat > npt.mdp << MDP
integrator = md
dt = 0.002
nsteps = 50000
nstenergy = 5000
nstlog = 5000
nstxout-compressed = 5000
continuation = yes
constraint_algorithm = lincs
constraints = h-bonds
cutoff-scheme = Verlet
ns_type = grid
nstlist = 10
rcoulomb = 1.0
rvdw = 1.0
DispCorr = EnerPres
coulombtype = PME
tcoupl = V-rescale
tc-grps = Protein Non-Protein
tau_t = 0.1 0.1
ref_t = $TEMP $TEMP
pcoupl = Parrinello-Rahman
pcoupltype = isotropic
tau_p = 2.0
ref_p = 1.0
compressibility = 4.5e-5
pbc = xyz
gen_vel = no
define = -DPOSRES
MDP

gmx grompp -f npt.mdp -c ../nvt/nvt.gro -r ../nvt/nvt.gro -t ../nvt/nvt.cpt -p ../setup/topol.top -o npt.tpr -maxwarn 2
gmx mdrun -v -deffnm npt -ntmpi 1 -ntomp $NTOMP

cd ..
echo "✓ NPT complete"

# Phase 5: Production MD
echo "[5/6] Production MD ($MD_TIME ns)..."
mkdir -p md
cd md

MD_STEPS=$((MD_TIME * 500000))

cat > md.mdp << MDP
integrator = md
dt = 0.002
nsteps = $MD_STEPS
nstenergy = 5000
nstlog = 5000
nstxout-compressed = 5000
continuation = yes
constraint_algorithm = lincs
constraints = h-bonds
cutoff-scheme = Verlet
ns_type = grid
nstlist = 10
rcoulomb = 1.0
rvdw = 1.0
DispCorr = EnerPres
coulombtype = PME
tcoupl = V-rescale
tc-grps = Protein Non-Protein
tau_t = 0.1 0.1
ref_t = $TEMP $TEMP
pcoupl = Parrinello-Rahman
pcoupltype = isotropic
tau_p = 2.0
ref_p = 1.0
compressibility = 4.5e-5
pbc = xyz
gen_vel = no
MDP

gmx grompp -f md.mdp -c ../npt/npt.gro -t ../npt/npt.cpt -p ../setup/topol.top -o md.tpr -maxwarn 2
gmx mdrun -v -deffnm md -ntmpi 1 -ntomp $NTOMP

cd ..
echo "✓ MD complete"

# Phase 6: Analysis
if [[ $QUICK -eq 0 ]]; then
    echo "[6/6] Analysis..."
    mkdir -p analysis
    cd analysis
    
    # RMSD
    echo "Backbone" | gmx rms -s ../md/md.tpr -f ../md/md.xtc -o rmsd.xvg -tu ns
    
    # RMSF
    echo "C-alpha" | gmx rmsf -s ../md/md.tpr -f ../md/md.xtc -o rmsf.xvg -res
    
    # Rg
    echo "Protein" | gmx gyrate -s ../md/md.tpr -f ../md/md.xtc -o gyrate.xvg
    
    cd ..
    echo "✓ Analysis complete"
else
    echo "[6/6] Analysis skipped (--quick)"
fi

# Generate report
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
HOURS=$((ELAPSED / 3600))
MINS=$(((ELAPSED % 3600) / 60))

cat > REPORT.md << REPORT
# Workflow Report

**Input:** $INPUT  
**Force field:** $FF  
**Water model:** $WATER  
**MD time:** $MD_TIME ns  
**Temperature:** $TEMP K  
**Elapsed time:** ${HOURS}h ${MINS}m

## Pipeline Status

- ✓ System preparation
- ✓ Energy minimization
- ✓ NVT equilibration
- ✓ NPT equilibration
- ✓ Production MD
REPORT

if [[ $QUICK -eq 0 ]]; then
    echo "- ✓ Analysis" >> REPORT.md
else
    echo "- ⊘ Analysis (skipped)" >> REPORT.md
fi

cat >> REPORT.md << REPORT

## Output Files

- \`setup/system.gro\` - Prepared system
- \`em/em.gro\` - Energy minimized
- \`npt/npt.gro\` - Equilibrated structure
- \`md/md.xtc\` - Production trajectory
- \`md/md.edr\` - Energy file
REPORT

if [[ $QUICK -eq 0 ]]; then
    cat >> REPORT.md << REPORT
- \`analysis/rmsd.xvg\` - RMSD
- \`analysis/rmsf.xvg\` - RMSF
- \`analysis/gyrate.xvg\` - Radius of gyration
REPORT
fi

cat >> REPORT.md << REPORT

## Next Steps

\`\`\`bash
# Visualize trajectory
vmd md/md.tpr md/md.xtc

# Continue simulation
cd md
gmx mdrun -v -deffnm md -cpi md.cpt -nsteps 10000000  # +20 ns

# Advanced analysis
cd ../analysis
gmx hbond -s ../md/md.tpr -f ../md/md.xtc -num hbond.xvg
\`\`\`
REPORT

echo ""
echo "=== Workflow Complete ==="
echo "Total time: ${HOURS}h ${MINS}m"
echo "Output: $OUTDIR/"
echo ""
cat REPORT.md

exit 0
