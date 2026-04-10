# Steered MD 使用示例

## 快速开始

### 示例 1: 配体解离 (最常用)

```bash
# 使用 distance 几何 + constant-velocity 模式
INPUT_GRO=protein_ligand.gro \
INPUT_TOP=topol.top \
INPUT_NDX=index.ndx \
PULL_GEOMETRY=distance \
PULL_MODE=constant-velocity \
PULL_GROUP1=Protein \
PULL_GROUP2=Ligand \
PULL_RATE=0.01 \
PULL_K=1000 \
SIM_TIME=1000 \
./scripts/advanced/steered-md.sh
```

**输出**:
- `steered-md/pullf.xvg` - 拉力-时间曲线
- `steered-md/pullx.xvg` - 距离-时间曲线
- `steered-md/umbrella_windows.dat` - 伞状采样窗口配置
- `steered-md/STEERED_MD_REPORT.md` - 详细报告

---

### 示例 2: 蛋白质展开

```bash
# 沿 Z 方向拉伸蛋白质
PULL_GEOMETRY=direction \
PULL_MODE=constant-velocity \
PULL_GROUP1=N_terminus \
PULL_GROUP2=C_terminus \
PULL_VEC="0 0 1" \
PULL_RATE=0.005 \
SIM_TIME=2000 \
./scripts/advanced/steered-md.sh
```

---

### 示例 3: 恒定力拉伸

```bash
# 施加恒定力研究力响应
PULL_MODE=constant-force \
PULL_RATE=500 \
SIM_TIME=5000 \
./scripts/advanced/steered-md.sh
```

---

### 示例 4: 膜蛋白拉伸 (圆柱几何)

```bash
# 使用圆柱约束拉伸膜蛋白
PULL_GEOMETRY=cylinder \
PULL_VEC="0 0 1" \
CYLINDER_R=1.5 \
PULL_GROUP1=Membrane \
PULL_GROUP2=Protein \
PULL_RATE=0.01 \
./scripts/advanced/steered-md.sh
```

---

### 示例 5: 角度拉力

```bash
# 改变三个原子组之间的角度
PULL_GEOMETRY=angle \
PULL_GROUP1=GroupA \
PULL_GROUP2=GroupB \
PULL_GROUP3=GroupC \
PULL_MODE=umbrella \
PULL_K=1000 \
PULL_INIT=120 \
./scripts/advanced/steered-md.sh
```

---

## 典型工作流

### 工作流 1: 配体解离 → 伞状采样 → PMF

```bash
# Step 1: 运行 steered MD
PULL_MODE=constant-velocity PULL_RATE=0.01 SIM_TIME=1000 \
./scripts/advanced/steered-md.sh

# Step 2: 查看生成的窗口配置
cat steered-md/umbrella_windows.dat

# Step 3: 从轨迹提取构象
cd steered-md
gmx trjconv -s pull.tpr -f pull.xtc -o conf.gro -sep -skip 10

# Step 4: 运行伞状采样 (使用 umbrella.sh)
cd ..
./scripts/advanced/umbrella.sh --windows steered-md/umbrella_windows.dat

# Step 5: WHAM 分析
gmx wham -it tpr-files.dat -if pullf-files.dat -o pmf.xvg
```

---

### 工作流 2: 力-距离曲线分析

```bash
# Step 1: 运行 steered MD
./scripts/advanced/steered-md.sh

# Step 2: 查看拉力统计
cat steered-md/force_stats.txt

# Step 3: 绘制力-距离曲线
cd steered-md
xmgrace pullf.xvg pullx.xvg

# Step 4: 计算功 (Work)
awk 'BEGIN{w=0} !/^[@#]/ {
    if(NR>1) w+=(($2+prev)/2)*($1-prevt); 
    prev=$2; prevt=$1
} END{print "Work:", w, "kJ/mol"}' pullf.xvg
```

---

## 参数调优

### 调优 1: 拉力速率过快导致 LINCS 警告

```bash
# 问题: Step 12450: LINCS WARNING
# 解决: 减小拉力速率
PULL_RATE=0.001 ./scripts/advanced/steered-md.sh

# 或减小时间步长
DT=0.001 PULL_RATE=0.005 ./scripts/advanced/steered-md.sh
```

### 调优 2: 拉力曲线噪声过大

```bash
# 增加弹簧常数
PULL_K=2000 ./scripts/advanced/steered-md.sh

# 或减小拉力速率
PULL_RATE=0.005 ./scripts/advanced/steered-md.sh
```

### 调优 3: 初始距离检测失败

```bash
# 手动指定初始距离
PULL_INIT=2.5 ./scripts/advanced/steered-md.sh

# 或使用 gmx distance 手动计算
echo "Protein Ligand" | gmx distance -s system.gro -n index.ndx \
    -select "com of group Protein" -select2 "com of group Ligand"
```

---

## 常见问题

### Q1: 如何选择拉力速率?

**A**: 
- **快速筛选**: 0.01 nm/ps (1 ns 拉伸 10 nm)
- **精确 PMF**: 0.001-0.005 nm/ps (慢速拉伸)
- **力响应**: 100-1000 kJ/mol/nm (恒定力)

### Q2: 如何判断拉力速率是否合理?

**A**: 查看拉力曲线:
- **合理**: 平滑曲线,无异常尖峰
- **过快**: 大量噪声,LINCS 警告
- **过慢**: 计算时间过长

### Q3: 如何生成伞状采样窗口?

**A**: 使用 constant-velocity 模式,脚本会自动生成 `umbrella_windows.dat`

### Q4: 支持多个拉力坐标吗?

**A**: 当前版本仅支持单个拉力坐标。如需多个,请手动编辑 MDP 文件。

---

## 性能优化

```bash
# 使用 GPU 加速
GPU_ID=0 ./scripts/advanced/steered-md.sh

# 增加 OpenMP 线程
NTOMP=8 ./scripts/advanced/steered-md.sh

# 减少输出频率 (节省磁盘空间)
# 编辑 pull.mdp:
# nstxout-compressed = 10000
# pull-nstxout = 500
```

---

## 结果验证

```bash
# 1. 检查模拟是否完成
grep "Finished mdrun" steered-md/pull.log

# 2. 查看拉力统计
cat steered-md/force_stats.txt

# 3. 绘制曲线
xmgrace steered-md/pullf.xvg steered-md/pullx.xvg

# 4. 检查能量守恒
echo "Total-Energy" | gmx energy -f steered-md/pull.edr -o energy.xvg
xmgrace energy.xvg
```
