# ClawHub 重新发布指南 - AutoMD-GROMACS

## 发布信息
- **旧项目名:** gromacs-skills
- **新项目名:** automd-gromacs
- **版本:** v2.1.0
- **作者:** @Billwanttobetop

## 发布步骤

### 方案 A：本地电脑发布（推荐）

```bash
# 1. 在本地电脑克隆项目
git clone https://github.com/Billwanttobetop/automd-gromacs.git
cd automd-gromacs

# 2. 登录 ClawHub
clawhub login

# 3. 发布项目
clawhub publish

# 4. 验证发布
clawhub search automd-gromacs
```

### 方案 B：服务器发布（需要网络配置）

如果服务器网络环境支持回调端口访问：

```bash
cd /root/.openclaw/workspace/automd-gromacs

# 登录
clawhub login

# 发布
clawhub publish
```

## 发布后验证

- ClawHub 页面: https://clawhub.ai/skills/automd-gromacs
- 搜索测试: `clawhub search automd`
- 安装测试: `clawhub install automd-gromacs`

## 注意事项

1. 确保 GitHub 仓库已创建并推送代码
2. _meta.json 中的 repository 字段已更新为新仓库地址
3. SKILL.md 中的 homepage 已更新
4. 旧项目 gromacs-skills 可以标记为 deprecated

---

**状态:** 待执行  
**依赖:** GitHub 仓库创建完成  
**预计耗时:** 3 分钟
