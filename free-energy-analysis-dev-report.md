# free-energy-analysis 开发报告

## 目标

新增 `free-energy-analysis` 作为**自由能结果分析与质量评估总控 Skill**，定位在现有：
- `scripts/advanced/freeenergy.sh`
- `scripts/advanced/umbrella.sh`
- `scripts/advanced/enhanced-sampling.sh`
- `scripts/advanced/metadynamics.sh`

之后，用于**读取和复核结果**，而不是重复生产模拟流程。

## 本次交付

### 1. 核心脚本
- `scripts/analysis/free-energy-analysis.sh`

### 2. 故障排查文档
- `references/troubleshoot/free-energy-analysis-errors.md`

### 3. 索引更新
- `references/SKILLS_INDEX.yaml`

## 设计原则

1. **分析优先，不重跑全流程**
   - 优先解析已有 `bar.xvg / pmf.xvg / hist.xvg / awh_pmf.xvg / md.log`
   - 条件允许时才调用 `gmx bar / gmx wham / gmx awh` 复算

2. **结果判读优先于纯命令封装**
   - 不只给出文件，还输出统一 `FREE_ENERGY_ANALYSIS_REPORT.md`
   - 把 overlap、收敛、baseline drift、粗糙度、bootstrap/block averaging 摘要整合到一个地方

3. **与已有 Skill 衔接**
   - `freeenergy.sh` 产生的 lambda/dhdl 结果可直接供 BAR 分析
   - `umbrella.sh` 产生的 `tpr_files.dat`、`pullf_files.dat`、`pmf.xvg`、`hist.xvg` 可直接供 WHAM 复核
   - `metadynamics.sh` 的 AWH 输出和日志可直接供 AWH 读取与建议
   - `enhanced-sampling.sh` 的 BAR 后处理结果也能被复用

4. **Token 控制**
   - 报告内容聚焦定量结果 + 质量提示，避免冗长教程式输出
   - 把详细修复路径放入 troubleshoot 文档，主索引只保留 quick_ref

## 实现细节

### BAR / FEP
- 支持 `--bar-inputs` 显式输入
- 支持 `--bar-pattern` 自动收集 lambda 文件
- 若可用则执行 `gmx bar`
- 否则读取现有 `bar.xvg`/`analysis/bar.xvg`
- 汇总 `delta_g` 和 `error`

### WHAM / PMF
- 支持 `--wham-tpr-list` + `--wham-pullf-list`
- 若可用则执行 `gmx wham -bsres -nBootstrap`
- 自动解析：
  - PMF range
  - bootstrap mean error
  - histogram overlap ratio
  - baseline drift
  - roughness 指标
  - convergence 状态

### AWH
- 支持 `--awh-edr`、`--awh-log`、`--awh-pmf`
- 若可用则执行 `gmx awh`
- 若无完整输出，至少基于日志给出阶段判断：
  - `exploration`
  - `near-converged`
  - `unknown`

### 误差估计
- bootstrap：来自 `gmx wham` 的 `bsres.xvg` 或 PMF 第三列
- block averaging：通过 `--series` 对任意数值时间序列做分块标准误估计

### 统一总报告
输出目录下生成：
- `bar/`
- `wham/`
- `awh/`
- `FREE_ENERGY_ANALYSIS_REPORT.md`

## 质量取舍

### 为什么没有把 overlap 做成复杂二维统计？
因为当前仓库主要是 Bash Skill，目标是生产可用、AI 低 token 调用。当前版本采用：
- 直接读 `hist.xvg`
- 用非零直方图占比、重叠占比做一阶质量筛查

这不是最完整的统计学实现，但足够快速、解释性强、并且与 `umbrella.sh` 产物兼容。

### 为什么 block averaging 不自动猜所有窗口？
因为不同任务里最合适的序列不同：
- umbrella 常看 `pullx.xvg`
- FEP 常看 `dhdl.xvg`
- AWH 常看 bias 或 PMF 相关序列

所以这里保留 `--series` 显式指定，避免错误自动化。

## 生产适用性评估

优点：
- 能直接接在现有自由能 skill 后面用
- 对“已有结果但没有完整运行环境”的场景也可工作
- 给出质量评估，而不仅是文件汇总

边界：
- 不是替代 MBAR/alchemlyb 的高级统计工具
- AWH 定量收敛判据仍依赖 GROMACS 日志与用户专业判断
- roughness / overlap 是实用筛查指标，不是严谨发表级充分条件

## 结论

本次实现把 `automd-gromacs` 中原本分散在 `freeenergy / umbrella / metadynamics / enhanced-sampling` 的后处理能力，整合成了一个单独的分析总控 Skill，满足“真实可用、结果判读、误差分析”的目标。适合作为生产工作流中的**最后一道质量门**。
