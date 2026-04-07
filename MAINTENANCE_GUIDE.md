# GROMACS Skills 维护和更新指南

**项目:** gromacs-skills  
**作者:** 郭轩 (guoxuan)  
**单位:** 香港科技大学（广州）

---

## 📋 日常维护

### 1. 版本管理

**更新版本号（3个位置）:**
```bash
cd /root/.openclaw/workspace/gromacs-skills

# 1. _meta.json
vim _meta.json
# 修改 "version": "2.1.0" → "2.2.0"

# 2. SKILL.md
vim SKILL.md
# 修改 version: 2.1.0 → version: 2.2.0

# 3. VERIFICATION.md
vim VERIFICATION.md
# 更新版本号和日期
```

**版本号规则:**
- 主版本 (X.0.0): 重大架构变更
- 次版本 (2.X.0): 新增 Skills 或重要功能
- 修订版 (2.1.X): Bug 修复、文档更新

---

## 🔧 常见更新场景

### 场景 1: 修复脚本 Bug

```bash
# 1. 修改脚本
vim scripts/basic/setup.sh

# 2. 测试验证
bash scripts/basic/setup.sh --input test.pdb

# 3. 更新版本号 (2.1.0 → 2.1.1)
# 修改 _meta.json, SKILL.md

# 4. 更新 VERIFICATION.md
vim VERIFICATION.md
# 更新日期和校验码

# 5. 发布更新
clawhub publish /root/.openclaw/workspace/gromacs-skills/
```

---

### 场景 2: 新增 Skill

```bash
# 1. 创建脚本
vim scripts/advanced/new-skill.sh
chmod +x scripts/advanced/new-skill.sh

# 2. 创建故障排查文档
vim references/troubleshoot/new-skill-errors.md

# 3. 更新 SKILLS_INDEX.yaml
vim references/SKILLS_INDEX.yaml
# 添加新 Skill 条目

# 4. 更新 SKILL.md
vim SKILL.md
# 在快速开始部分添加新 Skill 说明
# 更新 Skills 数量 (13 → 14)

# 5. 更新版本号 (2.1.0 → 2.2.0)
# 修改 _meta.json, SKILL.md

# 6. 测试验证
bash scripts/advanced/new-skill.sh --test

# 7. 发布更新
clawhub publish /root/.openclaw/workspace/gromacs-skills/
```

---

### 场景 3: 更新文档

```bash
# 1. 修改文档
vim references/troubleshoot/setup-errors.md

# 2. 更新版本号 (2.1.0 → 2.1.1)
# 修改 _meta.json, SKILL.md

# 3. 更新 VERIFICATION.md
vim VERIFICATION.md

# 4. 发布更新
clawhub publish /root/.openclaw/workspace/gromacs-skills/
```

---

### 场景 4: GROMACS 新版本适配

```bash
# 假设 GROMACS 2026.2 发布

# 1. 测试所有脚本
cd /root/.openclaw/workspace/gromacs-skills
for script in scripts/*/*.sh; do
  echo "测试: $script"
  bash "$script" --help
done

# 2. 更新手册引用
vim references/SKILLS_INDEX.yaml
# 更新 Manual 版本号

# 3. 更新 SKILL.md
vim SKILL.md
# 在 homepage 或说明中注明支持的 GROMACS 版本

# 4. 更新版本号 (2.1.0 → 2.2.0)

# 5. 发布更新
clawhub publish /root/.openclaw/workspace/gromacs-skills/
```

---

## 🐛 Bug 修复流程

### 1. 收集反馈
- 用户报告的问题
- 自己发现的 Bug
- GROMACS 版本兼容性问题

### 2. 复现问题
```bash
# 在测试系统上复现
cd /root/.openclaw/workspace/gromacs-skills-project/tests
bash ../gromacs-skills/scripts/basic/setup.sh --input test.pdb
```

### 3. 修复 Bug
```bash
# 修改脚本
vim scripts/basic/setup.sh

# 测试修复
bash scripts/basic/setup.sh --input test.pdb
```

### 4. 更新文档
```bash
# 如果是新错误，添加到故障排查文档
vim references/troubleshoot/setup-errors.md
```

### 5. 发布修复版本
```bash
# 更新版本号 (2.1.0 → 2.1.1)
# 发布
clawhub publish /root/.openclaw/workspace/gromacs-skills/
```

---

## 📊 质量检查清单

### 发布前检查

```bash
# 1. 脚本可执行性
find scripts -name "*.sh" -exec bash -n {} \;

# 2. 文件完整性
ls -la scripts/basic/*.sh
ls -la scripts/advanced/*.sh
ls -la references/troubleshoot/*-errors.md

# 3. 版本号一致性
grep "version" _meta.json SKILL.md

# 4. 防伪信息
cat _meta.json | grep -E "author|organization|verified"

# 5. 文档完整性
ls -la LICENSE VERIFICATION.md SKILL.md
```

---

## 🔄 更新发布流程

### 标准流程

```bash
# 1. 修改代码/文档
vim scripts/xxx.sh

# 2. 测试验证
bash scripts/xxx.sh --test

# 3. 更新版本号
vim _meta.json SKILL.md VERIFICATION.md

# 4. 提交更改（如果使用 Git）
git add .
git commit -m "fix: 修复 xxx 问题"
git tag v2.1.1
git push origin main --tags

# 5. 发布到 clawhub
clawhub publish /root/.openclaw/workspace/gromacs-skills/

# 6. 验证发布
clawhub search gromacs
```

---

## 📝 变更日志

### 建议创建 CHANGELOG.md

```markdown
# Changelog

## [2.1.1] - 2026-04-08
### Fixed
- 修复 setup.sh 中的力场选择问题
- 更新 equilibration-errors.md 文档

## [2.1.0] - 2026-04-07
### Added
- 新增 production.sh
- 新增 preprocess.sh
- 新增 utils.sh
- 新增 pca.sh
- 新增 protein.sh
- 新增 workflow.sh

### Changed
- 优化 Token 使用 (84.7%)
- 符合 OpenClaw 规范

## [2.0.0] - 2026-04-06
### Added
- 初始发布
- 7 个核心 Skills
```

---

## 🚨 紧急修复流程

### 如果发现严重 Bug

```bash
# 1. 立即修复
vim scripts/xxx.sh

# 2. 快速测试
bash scripts/xxx.sh --test

# 3. 更新版本号 (2.1.0 → 2.1.1)

# 4. 立即发布
clawhub publish /root/.openclaw/workspace/gromacs-skills/

# 5. 通知用户（如果有渠道）
```

---

## 📧 用户反馈处理

### 收集反馈渠道
- GitHub Issues (如果有仓库)
- 邮箱: guoxuan@hkust-gz.edu.cn
- clawhub 评论区

### 反馈处理流程
1. 记录问题
2. 复现问题
3. 修复或解答
4. 更新文档
5. 发布新版本（如需要）

---

## 🔐 安全维护

### 定期检查
- 依赖工具版本 (GROMACS, acpype, dssp)
- 脚本权限 (chmod +x)
- 敏感信息泄露

### 更新防伪信息
```bash
# 每次发布更新 VERIFICATION.md
vim VERIFICATION.md
# 更新日期和校验码
```

---

## 📚 文档维护

### 定期更新
- README/SKILL.md - 保持最新
- 故障排查文档 - 添加新错误
- 参考文档 - 更新手册链接

### 文档质量
- 清晰简洁
- 可执行的示例
- 及时更新

---

## 🎯 长期规划

### 功能扩展
- 新增更多高级 Skills
- 支持更多力场
- 增强自动修复能力

### 性能优化
- 进一步减少 Token 消耗
- 提升脚本执行效率
- 优化错误处理

### 社区建设
- 收集用户反馈
- 建立用户社区
- 贡献指南

---

**维护联系方式:**
- 作者: 郭轩 (guoxuan)
- 邮箱: guoxuan@hkust-gz.edu.cn
- 单位: 香港科技大学（广州）
