# 🚀 AutoMD-GROMACS 三平台发布总览

## 项目信息
- **项目名称:** automd-gromacs
- **版本:** v2.1.0
- **作者:** 郭轩 (Guo Xuan) @Billwanttobetop
- **定位:** AutoMD 系列首个项目 - GROMACS 自动化

## 发布状态

### ✅ 已完成
- [x] 项目重命名 (gromacs-skills → automd-gromacs)
- [x] 核心文件更新 (SKILL.md, _meta.json, README.md)
- [x] Git 仓库初始化
- [x] 发布指南文档准备

### 🔄 待执行

#### 1. GitHub 发布 (首次)
- [ ] 在 GitHub 创建 automd-gromacs 仓库
- [ ] 关联远程仓库并推送代码
- [ ] 创建 v2.1.0 release 标签
- [ ] 完善仓库设置 (Topics, About, Website)

**详细步骤:** 见 `GITHUB_PUBLISH.md`

#### 2. ClawHub 重新发布
- [ ] 确保 GitHub 仓库已创建
- [ ] 在本地电脑执行 `clawhub login`
- [ ] 执行 `clawhub publish`
- [ ] 验证发布成功

**详细步骤:** 见 `CLAWHUB_PUBLISH.md`

#### 3. SkillHub 新项目提交
- [ ] 确保 GitHub + ClawHub 已发布
- [ ] 访问 SkillHub 提交页面
- [ ] 填写项目信息和标签
- [ ] 提交审核
- [ ] 审核通过后验证

**详细步骤:** 见 `SKILLHUB_SUBMIT.md`

## 发布顺序

```
1. GitHub (基础) 
   ↓
2. ClawHub (OpenClaw 生态)
   ↓
3. SkillHub (中文社区)
```

## 预计耗时

- GitHub: 5 分钟
- ClawHub: 3 分钟
- SkillHub: 10 分钟
- **总计:** ~20 分钟

## AutoMD 系列战略

### 系列规划
- 🔷 **automd-gromacs** - GROMACS 自动化（当前项目）
- 🔶 **automd-amber** - AMBER 自动化（未来）
- 🔵 **automd-namd** - NAMD 自动化（未来）
- 🟢 **automd-lammps** - LAMMPS 自动化（未来）
- 🟣 **automd-openmm** - OpenMM 自动化（未来）
- ⚫ **automd-core** - 通用核心库（未来）

### 品牌优势
- ✅ 统一命名规范
- ✅ 可复用架构设计
- ✅ 社区认知度累积
- ✅ 跨平台工作流整合

## 快速执行命令

### GitHub 发布
```bash
# 1. 先在 GitHub 网页创建仓库: https://github.com/new
# 2. 然后执行：
cd /root/.openclaw/workspace/automd-gromacs
git remote add origin https://github.com/Billwanttobetop/automd-gromacs.git
git push -u origin main
git tag -a v2.1.0 -m "AutoMD-GROMACS v2.1.0 - Initial release"
git push origin v2.1.0
```

### ClawHub 发布（本地电脑）
```bash
git clone https://github.com/Billwanttobetop/automd-gromacs.git
cd automd-gromacs
clawhub login
clawhub publish
```

### 验证发布
```bash
# ClawHub
clawhub search automd-gromacs

# GitHub
curl -s https://api.github.com/repos/Billwanttobetop/automd-gromacs | jq '.name, .description'
```

---

**项目位置:** `/root/.openclaw/workspace/automd-gromacs/`  
**文档更新:** 2026-04-08 08:46  
**下一步:** 执行 GitHub 仓库创建
