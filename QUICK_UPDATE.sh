#!/bin/bash
# 快速更新脚本

echo "=== GROMACS Skills 快速更新工具 ==="
echo ""

# 1. 检查当前版本
CURRENT_VERSION=$(grep '"version"' _meta.json | cut -d'"' -f4)
echo "当前版本: $CURRENT_VERSION"
echo ""

# 2. 询问新版本号
read -p "新版本号 (例如 2.1.1): " NEW_VERSION

if [[ -z "$NEW_VERSION" ]]; then
  echo "❌ 版本号不能为空"
  exit 1
fi

echo ""
echo "准备更新: $CURRENT_VERSION → $NEW_VERSION"
echo ""

# 3. 更新 _meta.json
echo "→ 更新 _meta.json..."
sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" _meta.json

# 4. 更新 SKILL.md
echo "→ 更新 SKILL.md..."
sed -i "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" SKILL.md

# 5. 更新 VERIFICATION.md
echo "→ 更新 VERIFICATION.md..."
TODAY=$(date +%Y-%m-%d)
sed -i "s/v$CURRENT_VERSION/v$NEW_VERSION/g" VERIFICATION.md
sed -i "s/发布日期:.*/发布日期: $TODAY/" VERIFICATION.md

echo ""
echo "✅ 版本号已更新到 $NEW_VERSION"
echo ""
echo "下一步:"
echo "  1. 测试你的修改"
echo "  2. clawhub publish /root/.openclaw/workspace/gromacs-skills/"
echo ""
