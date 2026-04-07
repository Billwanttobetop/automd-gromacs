# 发布说明

由于自动登录超时，请您手动完成发布：

## 方式 1: clawhub 发布（推荐）

### 步骤：

1. **在您的本地终端执行：**
```bash
clawhub login
```

2. **在浏览器中完成登录**

3. **发布项目：**
```bash
cd /root/.openclaw/workspace
clawhub publish gromacs-skills/
```

---

## 方式 2: 先上传到 GitHub，再发布到 clawhub

### GitHub 上传：

```bash
cd /root/.openclaw/workspace/gromacs-skills

# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: GROMACS Skills v2.1.0

- 13 complete Skills (6 basic + 7 advanced)
- Built-in auto-repair functions
- Token optimization (84.7% savings)
- Real-world validated
- Bilingual documentation (EN/CN)

Author: Guo Xuan 郭轩
Institution: HKUST(GZ)"

# 添加远程仓库（需要先在 GitHub 创建仓库）
git remote add origin https://github.com/guoxuan/gromacs-skills.git

# 推送
git branch -M main
git push -u origin main

# 添加标签
git tag -a v2.1.0 -m "Release v2.1.0"
git push origin v2.1.0
```

### 然后发布到 clawhub：

```bash
clawhub login
clawhub publish gromacs-skills/
```

---

## 方式 3: 使用 GitHub CLI（如果已安装）

```bash
cd /root/.openclaw/workspace/gromacs-skills

# 创建仓库并推送
gh repo create gromacs-skills --public --source=. --remote=origin
git add .
git commit -m "Initial commit: GROMACS Skills v2.1.0"
git push -u origin main

# 创建 Release
gh release create v2.1.0 --title "v2.1.0" --notes "Initial release with 13 complete Skills"
```

---

## 项目位置

`/root/.openclaw/workspace/gromacs-skills/`

---

## 所有文件已准备完成

- ✅ 13 个 Skills
- ✅ 双语文档
- ✅ 防伪信息
- ✅ 维护工具
- ✅ GitHub 准备

**随时可以发布！**
