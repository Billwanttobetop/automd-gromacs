# AutoMD-GROMACS

**English** | [中文](#中文说明)

---

## English

### Overview

**AutoMD-GROMACS** is an automated molecular dynamics simulation workflow toolkit for GROMACS, designed for AI agents with built-in auto-repair and optimized token usage. Part of the **AutoMD series** for automated MD simulations.

**Author:** Guo Xuan 郭轩  
**Institution:** Hong Kong University of Science and Technology (Guangzhou)  
**Version:** v2.1.0  
**License:** MIT

### Features

- **13 Complete Skills** (6 basic + 7 advanced)
- **Built-in Auto-Repair** (8+ functions)
- **Token Optimized** (84.7% savings)
- **Real-World Validated** (production tested)
- **AI-Friendly Design** (layered disclosure architecture)

### Skills List

**Basic Skills (6):**
1. setup - System preparation
2. equilibration - System equilibration
3. analysis - Basic analysis
4. production - Production simulation
5. preprocess - Preprocessing (grompp)
6. utils - Utility tools

**Advanced Skills (7):**
7. freeenergy - Free energy calculation
8. ligand - Ligand-protein complex
9. membrane - Membrane protein simulation
10. umbrella - Umbrella sampling
11. pca - Principal component analysis
12. protein - Protein-specific analysis
13. workflow - End-to-end automation

### Installation

```bash
# Via clawhub
clawhub install automd-gromacs

# Via skillhub
skillhub install automd-gromacs

# Via GitHub
git clone https://github.com/Billwanttobetop/automd-gromacs.git
```

### Quick Start

```bash
# System setup
bash scripts/basic/setup.sh --input protein.pdb

# Equilibration
bash scripts/basic/equilibration.sh --input setup_ions.gro --topology topol.top

# Production simulation
bash scripts/basic/production.sh --input npt.gro --topology topol.top --time 1000

# Analysis
bash scripts/basic/analysis.sh --trajectory md.xtc --structure md.tpr
```

### Documentation

- **SKILL.md** - Complete guide
- **MAINTENANCE_GUIDE.md** - Maintenance guide
- **references/SKILLS_INDEX.yaml** - Skills index
- **references/troubleshoot/** - Troubleshooting docs

### Requirements

- GROMACS 2026.1+
- Optional: acpype, dssp (for advanced features)

### Contact

- **Author:** Guo Xuan 郭轩
- **GitHub:** [@Billwanttobetop](https://github.com/Billwanttobetop)
- **Email:** xguo608@connect.hkust-gz.edu.cn
- **Institution:** Hong Kong University of Science and Technology (Guangzhou)
- **Project:** Part of the AutoMD series

### License

MIT License - see [LICENSE](LICENSE) file

---

## 中文说明

### 概述

**AutoMD-GROMACS** 是一个自动化的 GROMACS 分子动力学模拟工作流工具包，专为 AI Agent 设计，内置自动修复功能和优化的 Token 使用。属于 **AutoMD 系列**自动化分子动力学模拟工具。

**作者:** 郭轩 Guo Xuan  
**单位:** 香港科技大学（广州）  
**版本:** v2.1.0  
**许可证:** MIT

### 特性

- **13 个完整 Skills** (基础 6 + 高级 7)
- **内置自动修复** (8+ 函数)
- **Token 优化** (节省 84.7%)
- **真实验证** (生产环境测试)
- **AI 友好设计** (层进式披露架构)

### Skills 列表

**基础 Skills (6个):**
1. setup - 系统准备
2. equilibration - 系统平衡
3. analysis - 基础分析
4. production - 生产模拟
5. preprocess - 预处理 (grompp)
6. utils - 实用工具

**高级 Skills (7个):**
7. freeenergy - 自由能计算
8. ligand - 配体-蛋白质复合物
9. membrane - 膜蛋白模拟
10. umbrella - 伞状采样
11. pca - 主成分分析
12. protein - 蛋白质专用分析
13. workflow - 端到端自动化

### 安装

```bash
# 通过 clawhub
clawhub install automd-gromacs

# 通过 skillhub
skillhub install automd-gromacs

# 通过 GitHub
git clone https://github.com/Billwanttobetop/automd-gromacs.git
```

### 快速开始

```bash
# 系统准备
bash scripts/basic/setup.sh --input protein.pdb

# 系统平衡
bash scripts/basic/equilibration.sh --input setup_ions.gro --topology topol.top

# 生产模拟
bash scripts/basic/production.sh --input npt.gro --topology topol.top --time 1000

# 分析
bash scripts/basic/analysis.sh --trajectory md.xtc --structure md.tpr
```

### 文档

- **SKILL.md** - 完整指南
- **MAINTENANCE_GUIDE.md** - 维护指南
- **references/SKILLS_INDEX.yaml** - Skills 索引
- **references/troubleshoot/** - 故障排查文档

### 依赖

- GROMACS 2026.1+
- 可选: acpype, dssp (高级功能)

### 联系方式

- **作者:** 郭轩 Guo Xuan
- **GitHub:** [@Billwanttobetop](https://github.com/Billwanttobetop)
- **邮箱:** xguo608@connect.hkust-gz.edu.cn
- **单位:** 香港科技大学（广州）
- **项目:** AutoMD 系列的一部分

### 许可证

MIT 许可证 - 查看 [LICENSE](LICENSE) 文件
