# GitHub 发布指南 - AutoMD-GROMACS

## 仓库信息
- **仓库名称:** automd-gromacs
- **用户名:** Billwanttobetop
- **完整 URL:** https://github.com/Billwanttobetop/automd-gromacs

## 发布步骤

### 1. 在 GitHub 创建仓库
```bash
# 访问 https://github.com/new
# 填写信息：
# - Repository name: automd-gromacs
# - Description: 🔷 AutoMD-GROMACS - AI-powered GROMACS automation skills for molecular dynamics simulations
# - Public
# - 不要初始化 README/LICENSE/.gitignore（本地已有）
```

### 2. 关联远程仓库并推送
```bash
cd /root/.openclaw/workspace/automd-gromacs

# 添加远程仓库
git remote add origin https://github.com/Billwanttobetop/automd-gromacs.git

# 推送代码
git push -u origin main

# 创建 v2.1.0 标签
git tag -a v2.1.0 -m "AutoMD-GROMACS v2.1.0 - Initial release with 13 complete skills"
git push origin v2.1.0
```

### 3. 完善 GitHub 仓库设置
- 添加 Topics: `gromacs`, `molecular-dynamics`, `openclaw`, `ai-automation`, `automd`
- 设置 About: 🔷 AutoMD-GROMACS - AI-powered GROMACS automation skills
- 添加 Website: https://clawhub.ai/skills/automd-gromacs

---

**状态:** 待执行  
**预计耗时:** 5 分钟
