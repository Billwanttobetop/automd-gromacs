# GitHub 上传指南

## 📦 准备工作

项目已完全准备好上传到 GitHub！

**项目位置:** `/root/.openclaw/workspace/gromacs-skills/`

---

## 🚀 上传步骤

### 方式 1: 使用 Git 命令行（推荐）

```bash
# 1. 进入项目目录
cd /root/.openclaw/workspace/gromacs-skills

# 2. 初始化 Git 仓库
git init

# 3. 添加所有文件
git add .

# 4. 提交
git commit -m "Initial commit: GROMACS Skills v2.1.0

- 13 complete Skills (6 basic + 7 advanced)
- Built-in auto-repair functions
- Token optimization (84.7% savings)
- Real-world validated
- Bilingual documentation (EN/CN)"

# 5. 在 GitHub 创建仓库
# 访问 https://github.com/new
# 仓库名: gromacs-skills
# 描述: GROMACS molecular dynamics simulation workflow toolkit
# 公开/私有: 根据需要选择
# 不要初始化 README (我们已经有了)

# 6. 添加远程仓库
git remote add origin https://github.com/guoxuan/gromacs-skills.git

# 7. 推送到 GitHub
git branch -M main
git push -u origin main

# 8. 添加标签
git tag -a v2.1.0 -m "Release v2.1.0"
git push origin v2.1.0
```

---

### 方式 2: 使用 GitHub CLI

```bash
# 1. 进入项目目录
cd /root/.openclaw/workspace/gromacs-skills

# 2. 初始化并创建仓库
gh repo create gromacs-skills --public --source=. --remote=origin

# 3. 添加并提交
git add .
git commit -m "Initial commit: GROMACS Skills v2.1.0"

# 4. 推送
git push -u origin main

# 5. 创建 Release
gh release create v2.1.0 --title "v2.1.0" --notes "Initial release with 13 complete Skills"
```

---

### 方式 3: 手动上传

```bash
# 1. 打包项目
cd /root/.openclaw/workspace
tar -czf gromacs-skills-v2.1.0.tar.gz gromacs-skills/

# 2. 在 GitHub 创建仓库
# 访问 https://github.com/new

# 3. 通过网页上传文件
# 或使用 GitHub Desktop
```

---

## 📝 GitHub 仓库设置

### 仓库信息

**名称:** gromacs-skills  
**描述:** GROMACS molecular dynamics simulation workflow toolkit for AI agents | GROMACS 分子动力学模拟工作流工具包

**Topics (标签):**
- gromacs
- molecular-dynamics
- simulation
- biophysics
- computational-chemistry
- ai-agent
- automation
- protein
- membrane
- free-energy

### README.md

已创建双语 README.md，包含：
- 英文说明
- 中文说明
- 安装指南
- 快速开始
- 联系方式

### LICENSE

MIT License - 已包含

### .gitignore

已创建，排除：
- 测试输出文件
- 临时文件
- 编辑器配置

---

## 🔗 更新链接

上传到 GitHub 后，更新以下文件中的链接：

### 1. _meta.json
```json
"repository": "https://github.com/guoxuan/gromacs-skills"
```

### 2. SKILL.md
在文档中添加 GitHub 链接

### 3. README.md
确认所有链接正确

---

## 📊 GitHub Actions (可选)

可以添加 CI/CD 自动化：

```yaml
# .github/workflows/test.yml
name: Test Scripts

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test script syntax
        run: |
          find scripts -name "*.sh" -exec bash -n {} \;
```

---

## 🎯 发布 Release

```bash
# 创建 Release
gh release create v2.1.0 \
  --title "GROMACS Skills v2.1.0" \
  --notes "Initial release

Features:
- 13 complete Skills (6 basic + 7 advanced)
- Built-in auto-repair (8+ functions)
- Token optimization (84.7% savings)
- Real-world validated
- Bilingual documentation (EN/CN)

Author: Guo Xuan 郭轩
Institution: HKUST(GZ)"
```

---

## ✅ 检查清单

上传前检查：

- [ ] README.md 双语完整
- [ ] LICENSE 文件存在
- [ ] .gitignore 已创建
- [ ] 作者信息双语
- [ ] 所有脚本可执行
- [ ] 文档链接正确
- [ ] 版本号一致

---

## 📞 后续维护

### 更新 GitHub

```bash
# 1. 修改代码
vim scripts/xxx.sh

# 2. 提交更改
git add .
git commit -m "fix: 修复 xxx 问题"

# 3. 更新版本
./QUICK_UPDATE.sh

# 4. 推送到 GitHub
git push origin main

# 5. 创建新 Release
git tag v2.1.1
git push origin v2.1.1
gh release create v2.1.1 --title "v2.1.1" --notes "Bug fixes"
```

### 同步到 clawhub

```bash
# GitHub 更新后，同步到 clawhub
clawhub publish /root/.openclaw/workspace/gromacs-skills/
```

---

**准备完成！随时可以上传到 GitHub！** 🚀
