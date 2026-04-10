# Publication-Quality Visualization - 使用指南

## 快速开始

### 1. 基础用法

#### 生成蛋白质结构图
```bash
bash scripts/visualization/publication-viz.sh \
  --type structure \
  --structure protein.pdb \
  --style cartoon \
  --color spectrum \
  --format png \
  --dpi 300
```

#### 绘制 RMSD 时间序列
```bash
bash scripts/visualization/publication-viz.sh \
  --type plot \
  --data rmsd.xvg \
  --plot-type timeseries \
  --journal-style nature \
  --format pdf
```

#### PCA 2D 投影
```bash
# 先运行 PCA 分析
bash scripts/analysis/trajectory-analysis.sh -s md.tpr -f md.xtc --mode pca

# 生成可视化
bash scripts/visualization/publication-viz.sh \
  --type trajectory \
  --trajectory md.xtc \
  --method pca \
  --dims 2
```

#### 一键生成完整报告
```bash
bash scripts/visualization/publication-viz.sh \
  --type report \
  --structure protein.pdb \
  --trajectory md.xtc \
  -o publication-viz
```

---

## 2. 高级示例

### 2.1 分子结构可视化

#### 表面图 + 疏水性着色
```bash
bash scripts/visualization/publication-viz.sh \
  --type structure \
  --structure protein.pdb \
  --style surface \
  --color hydrophobicity \
  --format svg \
  --dpi 600
```

#### 配体结合位点
```bash
# 使用自定义 PyMOL 脚本
cat > ligand_binding.pml << 'EOF'
load complex.pdb
hide everything
show cartoon, chain A
show sticks, resn LIG
color cyan, chain A
color yellow, resn LIG
zoom resn LIG, 5
ray 3000, 3000
png binding_site.png, dpi=300
EOF

pymol -c ligand_binding.pml
```

---

### 2.2 数据图表

#### RMSD + 误差带
```python
import matplotlib.pyplot as plt
import numpy as np

# 读取数据
data = np.loadtxt('rmsd.xvg', comments=['#', '@'])
time = data[:, 0] / 1000  # ps → ns
rmsd = data[:, 1]

# 计算滑动平均和标准差
window = 50
rmsd_smooth = np.convolve(rmsd, np.ones(window)/window, mode='valid')
rmsd_std = np.array([np.std(rmsd[i:i+window]) for i in range(len(rmsd)-window+1)])
time_smooth = time[:len(rmsd_smooth)]

# Nature 风格
plt.rcParams.update({
    'font.family': 'Arial',
    'font.size': 8,
    'axes.linewidth': 0.5,
    'figure.figsize': (3.5, 2.5)
})

fig, ax = plt.subplots()
ax.plot(time_smooth, rmsd_smooth, linewidth=1.0, color='#0173B2', label='RMSD')
ax.fill_between(time_smooth, rmsd_smooth-rmsd_std, rmsd_smooth+rmsd_std, 
                alpha=0.3, color='#0173B2')
ax.set_xlabel('Time (ns)')
ax.set_ylabel('RMSD (nm)')
ax.legend(frameon=False)
plt.tight_layout()
plt.savefig('rmsd_errorband.pdf', dpi=300, bbox_inches='tight')
```

#### 多面板组合图 (2x2)
```python
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy as np

# 读取数据
rmsd = np.loadtxt('rmsd.xvg', comments=['#', '@'])
rmsf = np.loadtxt('rmsf.xvg', comments=['#', '@'])
rg = np.loadtxt('gyrate.xvg', comments=['#', '@'])
sasa = np.loadtxt('sasa.xvg', comments=['#', '@'])

# 创建 2x2 布局
fig = plt.figure(figsize=(7, 5))
gs = gridspec.GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

# 子图 A: RMSD
ax1 = fig.add_subplot(gs[0, 0])
ax1.plot(rmsd[:, 0]/1000, rmsd[:, 1], linewidth=1.0, color='#0173B2')
ax1.set_xlabel('Time (ns)')
ax1.set_ylabel('RMSD (nm)')
ax1.text(0.05, 0.95, 'A', transform=ax1.transAxes, fontsize=12, 
         fontweight='bold', va='top')

# 子图 B: RMSF
ax2 = fig.add_subplot(gs[0, 1])
ax2.plot(rmsf[:, 0], rmsf[:, 1], linewidth=1.0, color='#DE8F05')
ax2.set_xlabel('Residue')
ax2.set_ylabel('RMSF (nm)')
ax2.text(0.05, 0.95, 'B', transform=ax2.transAxes, fontsize=12, 
         fontweight='bold', va='top')

# 子图 C: Rg
ax3 = fig.add_subplot(gs[1, 0])
ax3.plot(rg[:, 0]/1000, rg[:, 1], linewidth=1.0, color='#029E73')
ax3.set_xlabel('Time (ns)')
ax3.set_ylabel('Rg (nm)')
ax3.text(0.05, 0.95, 'C', transform=ax3.transAxes, fontsize=12, 
         fontweight='bold', va='top')

# 子图 D: SASA
ax4 = fig.add_subplot(gs[1, 1])
ax4.plot(sasa[:, 0]/1000, sasa[:, 1], linewidth=1.0, color='#CC78BC')
ax4.set_xlabel('Time (ns)')
ax4.set_ylabel('SASA (nm²)')
ax4.text(0.05, 0.95, 'D', transform=ax4.transAxes, fontsize=12, 
         fontweight='bold', va='top')

plt.savefig('multi_panel.pdf', dpi=300, bbox_inches='tight')
```

#### 热图 (接触图)
```python
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# 读取接触矩阵
contact_matrix = np.loadtxt('contact_mean.xpm.dat')

# Nature 风格
plt.rcParams.update({
    'font.family': 'Arial',
    'font.size': 8,
    'figure.figsize': (4, 3.5)
})

fig, ax = plt.subplots()
sns.heatmap(contact_matrix, cmap='RdYlBu_r', vmin=0, vmax=1,
            cbar_kws={'label': 'Contact Frequency'},
            xticklabels=10, yticklabels=10, ax=ax)
ax.set_xlabel('Residue')
ax.set_ylabel('Residue')
plt.tight_layout()
plt.savefig('contact_heatmap.pdf', dpi=300, bbox_inches='tight')
```

---

### 2.3 轨迹可视化

#### 自由能景观 (2D)
```python
import matplotlib.pyplot as plt
import numpy as np
from scipy.ndimage import gaussian_filter

# 读取 PCA 投影
data = np.loadtxt('projection_pca.xvg', comments=['#', '@'])
pc1 = data[:, 1]
pc2 = data[:, 2]

# 计算 2D 直方图
hist, xedges, yedges = np.histogram2d(pc1, pc2, bins=50)
hist = gaussian_filter(hist, sigma=1.0)

# 计算自由能 (kJ/mol)
kT = 0.008314 * 300  # kJ/mol at 300K
free_energy = -kT * np.log(hist + 1e-10)
free_energy = free_energy - np.min(free_energy)  # 归零

# 绘制等高线图
fig, ax = plt.subplots(figsize=(4, 3.5))
contour = ax.contourf(xedges[:-1], yedges[:-1], free_energy.T, 
                      levels=20, cmap='viridis')
ax.contour(xedges[:-1], yedges[:-1], free_energy.T, 
           levels=10, colors='white', linewidths=0.5, alpha=0.5)
ax.set_xlabel('PC1 (nm)')
ax.set_ylabel('PC2 (nm)')
cbar = plt.colorbar(contour, label='Free Energy (kJ/mol)')
plt.tight_layout()
plt.savefig('free_energy_landscape.pdf', dpi=300, bbox_inches='tight')
```

#### PCA 3D 投影
```python
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

# 读取 PCA 投影
data = np.loadtxt('projection_pca.xvg', comments=['#', '@'])
time = data[:, 0]
pc1 = data[:, 1]
pc2 = data[:, 2]
pc3 = data[:, 3]

# 3D 散点图
fig = plt.figure(figsize=(5, 5))
ax = fig.add_subplot(111, projection='3d')
scatter = ax.scatter(pc1, pc2, pc3, c=time, cmap='viridis', s=1, alpha=0.6)
ax.set_xlabel('PC1 (nm)')
ax.set_ylabel('PC2 (nm)')
ax.set_zlabel('PC3 (nm)')
cbar = plt.colorbar(scatter, label='Time (ps)', shrink=0.8)
plt.tight_layout()
plt.savefig('pca_3d.pdf', dpi=300, bbox_inches='tight')
```

---

### 2.4 特殊图表

#### Ramachandran 图 (带密度等高线)
```python
import matplotlib.pyplot as plt
import numpy as np
from scipy.ndimage import gaussian_filter

# 读取二面角数据
data = np.loadtxt('ramachandran.xvg', comments=['#', '@'])
phi = data[:, 1]
psi = data[:, 2]

# 计算密度
hist, xedges, yedges = np.histogram2d(phi, psi, bins=100, 
                                      range=[[-180, 180], [-180, 180]])
hist = gaussian_filter(hist, sigma=2.0)

# 绘图
fig, ax = plt.subplots(figsize=(4, 4))
contour = ax.contourf(xedges[:-1], yedges[:-1], hist.T, 
                      levels=20, cmap='Blues')
ax.contour(xedges[:-1], yedges[:-1], hist.T, 
           levels=10, colors='black', linewidths=0.5, alpha=0.3)
ax.set_xlabel('Phi (°)')
ax.set_ylabel('Psi (°)')
ax.set_xlim(-180, 180)
ax.set_ylim(-180, 180)
ax.axhline(0, color='gray', linewidth=0.5, linestyle='--', alpha=0.5)
ax.axvline(0, color='gray', linewidth=0.5, linestyle='--', alpha=0.5)
plt.colorbar(contour, label='Density')
plt.tight_layout()
plt.savefig('ramachandran.pdf', dpi=300, bbox_inches='tight')
```

#### 氢键网络图
```python
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np

# 读取氢键数据 (假设格式: donor acceptor frequency)
hbonds = np.loadtxt('hbond_network.dat')

# 创建网络图
G = nx.Graph()
for donor, acceptor, freq in hbonds:
    if freq > 0.5:  # 只显示频率 > 50% 的氢键
        G.add_edge(int(donor), int(acceptor), weight=freq)

# 绘图
fig, ax = plt.subplots(figsize=(6, 6))
pos = nx.spring_layout(G, k=0.5, iterations=50)
nx.draw_networkx_nodes(G, pos, node_size=300, node_color='lightblue', ax=ax)
nx.draw_networkx_labels(G, pos, font_size=8, ax=ax)
edges = G.edges()
weights = [G[u][v]['weight'] for u, v in edges]
nx.draw_networkx_edges(G, pos, width=[w*3 for w in weights], 
                       alpha=0.6, ax=ax)
ax.axis('off')
plt.tight_layout()
plt.savefig('hbond_network.pdf', dpi=300, bbox_inches='tight')
```

---

## 3. 期刊投稿指南

### 3.1 Nature 系列

**要求:**
- 字体: Arial, 8pt
- 线宽: 0.5 pt
- 单栏: 89 mm (3.5")
- 双栏: 183 mm (7.2")
- 分辨率: 300-600 DPI
- 格式: TIFF/EPS/PDF

**配置:**
```python
plt.rcParams.update({
    'font.family': 'Arial',
    'font.size': 8,
    'axes.linewidth': 0.5,
    'xtick.major.width': 0.5,
    'ytick.major.width': 0.5,
    'figure.figsize': (3.5, 2.5)  # 单栏
})
```

---

### 3.2 Science

**要求:**
- 字体: Helvetica, 9pt
- 线宽: 0.8 pt
- 单栏: 5.5 cm
- 双栏: 12 cm
- 分辨率: 300 DPI
- 格式: PDF/EPS

**配置:**
```python
plt.rcParams.update({
    'font.family': 'Helvetica',
    'font.size': 9,
    'axes.linewidth': 0.8,
    'figure.figsize': (2.17, 2.5)  # 单栏 (5.5 cm)
})
```

---

### 3.3 Cell 系列

**要求:**
- 字体: Arial, 7pt
- 线宽: 0.5 pt
- 单栏: 85 mm
- 双栏: 180 mm
- 分辨率: 300-600 DPI
- 格式: TIFF/EPS/PDF

**配置:**
```python
plt.rcParams.update({
    'font.family': 'Arial',
    'font.size': 7,
    'axes.linewidth': 0.5,
    'figure.figsize': (3.35, 2.5)  # 单栏 (85 mm)
})
```

---

## 4. 最佳实践

### 4.1 通用建议

1. **矢量图优先:** 使用 SVG/PDF/EPS，避免 PNG/JPG (除非期刊要求)
2. **高 DPI:** 位图至少 300 DPI，印刷用 600 DPI
3. **色盲友好:** 使用 ColorBrewer 或 Seaborn colorblind 调色板
4. **标注清晰:** 轴标签、图例、单位必须完整
5. **字体一致:** 全文使用相同字体和字号
6. **线宽适中:** 0.5-1.0 pt，避免过粗或过细
7. **留白充足:** 使用 `tight_layout()` 或 `bbox_inches='tight'`
8. **检查期刊要求:** 每个期刊有具体规定

---

### 4.2 PyMOL 技巧

**高质量渲染:**
```pymol
set ray_trace_mode, 1
set ray_shadows, 1
set ray_trace_fog, 0
set antialias, 2
set ambient, 0.4
set specular, 0.5
set depth_cue, 0
ray 3000, 3000
png output.png, dpi=300
```

**透明表面:**
```pymol
show surface
set transparency, 0.5
```

**配体高亮:**
```pymol
show sticks, resn LIG
color yellow, resn LIG
zoom resn LIG, 5
```

---

### 4.3 Matplotlib 技巧

**误差带:**
```python
ax.fill_between(x, y-err, y+err, alpha=0.3)
```

**双 Y 轴:**
```python
ax1 = fig.add_subplot(111)
ax2 = ax1.twinx()
ax1.plot(x, y1, color='blue')
ax2.plot(x, y2, color='red')
```

**对数坐标:**
```python
ax.set_yscale('log')
```

**网格:**
```python
ax.grid(True, linestyle='--', alpha=0.3)
```

---

## 5. 故障排查

### 常见问题

**Q1: PyMOL 不可用**
```bash
# 安装 PyMOL
conda install -c conda-forge pymol-open-source
# 或
sudo apt-get install pymol
```

**Q2: Python 库缺失**
```bash
pip3 install matplotlib seaborn numpy scipy pandas
```

**Q3: 字体缺失**
```bash
# Ubuntu
sudo apt-get install fonts-liberation

# macOS
# Arial 已内置

# 检查可用字体
python3 -c "import matplotlib.font_manager; print([f.name for f in matplotlib.font_manager.fontManager.ttflist])"
```

**Q4: 图像模糊**
- 增加 DPI: `--dpi 600`
- 使用矢量图: `--format svg` 或 `pdf`

**Q5: 内存不足**
- 跳帧: `gmx trjconv -skip 10`
- 降低分辨率: `--dpi 150`

---

## 6. 参考资源

- **PyMOL Wiki:** https://pymolwiki.org/
- **Matplotlib Gallery:** https://matplotlib.org/stable/gallery/
- **Seaborn Tutorial:** https://seaborn.pydata.org/tutorial.html
- **ColorBrewer:** https://colorbrewer2.org/
- **Nature Figure Guidelines:** https://www.nature.com/nature/for-authors/final-submission
- **Science Figure Guidelines:** https://www.science.org/content/page/instructions-preparing-initial-manuscript
- **Cell Figure Guidelines:** https://www.cell.com/figure-guidelines

---

**最后更新:** 2026-04-09
