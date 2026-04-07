# 维护和更新快速参考

## 🚀 快速更新流程

### 方式 1: 使用快速更新脚本（推荐）
```bash
cd /root/.openclaw/workspace/gromacs-skills
./QUICK_UPDATE.sh
# 输入新版本号，自动更新所有文件
clawhub publish .
```

### 方式 2: 手动更新
```bash
# 1. 修改代码
vim scripts/xxx.sh

# 2. 更新版本号（3个文件）
vim _meta.json      # "version": "2.1.1"
vim SKILL.md        # version: 2.1.1
vim VERIFICATION.md # v2.1.1 + 日期

# 3. 发布
clawhub publish /root/.openclaw/workspace/gromacs-skills/
```

---

## 📋 常见场景

| 场景 | 版本变化 | 操作 |
|------|---------|------|
| 修复 Bug | 2.1.0 → 2.1.1 | 修改脚本 → 更新版本 → 发布 |
| 更新文档 | 2.1.0 → 2.1.1 | 修改文档 → 更新版本 → 发布 |
| 新增 Skill | 2.1.0 → 2.2.0 | 创建脚本+文档 → 更新索引 → 发布 |
| 重大变更 | 2.1.0 → 3.0.0 | 架构调整 → 全面测试 → 发布 |

---

## 🔧 维护工具

**已创建的工具:**
- `MAINTENANCE_GUIDE.md` - 完整维护指南
- `QUICK_UPDATE.sh` - 快速更新版本号
- `UPLOAD_CHECKLIST.md` - 发布检查清单
- `VERIFICATION.md` - 防伪验证文档

**使用方法:**
```bash
# 快速更新版本
./QUICK_UPDATE.sh

# 查看完整指南
cat MAINTENANCE_GUIDE.md

# 发布前检查
cat UPLOAD_CHECKLIST.md
```

---

## 📞 联系方式

**作者:** 郭轩 (guoxuan)  
**邮箱:** guoxuan@hkust-gz.edu.cn  
**单位:** 香港科技大学（广州）

---

**提示:** 详细维护指南请查看 `MAINTENANCE_GUIDE.md`
