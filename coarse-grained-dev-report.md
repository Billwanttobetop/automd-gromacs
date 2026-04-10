# Coarse-Grained Skill 开发报告

## 项目信息

- **Skill名称**: coarse-grained
- **开发日期**: 2026-04-08
- **版本**: 1.0.0
- **开发者**: GROMACS Expert Subagent
- **状态**: ✅ 开发完成

---

## 一、需求分析

### 1.1 核心功能
粗粒化模拟是分子动力学中的重要技术，通过将多个原子合并为一个"珠子"(bead)来降低计算复杂度，使得：
- **时间尺度**: 从纳秒扩展到微秒-毫秒
- **系统规模**: 从数万原子扩展到数百万原子
- **计算效率**: 提升100-1000倍

### 1.2 MARTINI力场
MARTINI是最流行的粗粒化力场：
- **MARTINI 2**: 成熟稳定，脂质参数完善
- **MARTINI 3**: 更准确，蛋白质表现更好
- **映射规则**: 平均4个重原子 → 1个珠子

### 1.3 关键挑战
1. **力场获取**: MARTINI不在GROMACS默认力场中
2. **转换工具**: 需要martinize进行AA→CG转换
3. **参数差异**: 时间步长、截断距离、静电处理与全原子不同
4. **反向映射**: CG→AA需要专用工具
5. **多尺度**: AA和CG模拟的衔接

---

## 二、技术设计

### 2.1 架构设计

```
coarse-grained.sh
├── 模式选择
│   ├── aa2cg: 全原子→粗粒化完整流程
│   ├── cg: 直接粗粒化模拟
│   ├── backmapping: 粗粒化→全原子
│   └── multiscale: 多尺度模拟
├── 自动修复
│   ├── MARTINI力场自动下载
│   ├── martinize工具自动安装
│   ├── 时间步长自动验证
│   └── 失败自动重启
└── 完整流程
    ├── AA→CG转换 (martinize)
    ├── 系统准备 (盒子、溶剂、离子)
    ├── 能量最小化
    ├── NVT平衡
    ├── NPT平衡
    ├── 生产模拟
    └── 反向映射 (可选)
```

### 2.2 关键参数

#### MARTINI标准参数
```bash
# 时间步长
dt = 0.020-0.030 ps  # 20-30 fs (全原子: 2 fs)

# 截断距离
rcoulomb = 1.1 nm
rvdw     = 1.1 nm

# 静电处理
coulombtype = reaction-field
epsilon_r   = 15
epsilon_rf  = 0

# 温度耦合
tcoupl = v-rescale
tau_t  = 1.0 ps

# 压力耦合
pcoupl = parrinello-rahman
tau_p  = 12.0 ps          # 比全原子大 (2.0 ps)
compressibility = 3e-4    # 比全原子小 (4.5e-5)
```

### 2.3 自动修复策略

#### 1. MARTINI力场自动获取
```bash
check_martini_forcefield() {
    # 搜索常见位置
    # 如果未找到，自动下载
    wget http://cgmartini.nl/.../martini_v3.0.0.tar.gz
    # 解压到输出目录
}
```

#### 2. martinize工具自动安装
```bash
check_martinize() {
    # 检测martinize2或martinize.py
    # 如果未找到，尝试pip安装
    pip3 install vermouth-martinize
}
```

#### 3. 时间步长自动验证
```bash
validate_timestep() {
    # 检查dt是否在20-30 fs范围
    # 过小或过大自动修正
    if (( $(echo "$DT < 0.010" | bc -l) )); then
        DT=0.020  # 修正到20 fs
    fi
}
```

#### 4. 失败自动重启
```bash
restart_from_checkpoint() {
    # 检测检查点文件
    # 从中断处继续
    gmx mdrun -cpi stage.cpt ...
}
```

---

## 三、实现细节

### 3.1 核心函数

#### aa_to_cg() - 全原子到粗粒化转换
```bash
# 使用martinize2 (MARTINI 3)
martinize2 -f protein.pdb -o cg_topol.top -x cg_protein.pdb \
    -ff martini3001 \
    -elastic -ef 500 -el 0.5 -eu 0.9  # 弹性网络

# 或使用martinize.py (MARTINI 2)
martinize.py -f protein.pdb -o cg_topol.top -x cg_protein.pdb \
    -ff martini22 -elastic
```

**关键点**:
- `-elastic`: 添加弹性网络维持蛋白质结构
- `-ef 500`: 弹性力常数 (kJ/mol/nm²)
- `-el 0.5, -eu 0.9`: 下限和上限距离 (nm)
- `-cys auto`: 自动检测二硫键

#### setup_cg_system() - 系统准备
```bash
# 1. 定义盒子
gmx editconf -f cg_protein.gro -o cg_box.gro \
    -c -d 1.5 -bt dodecahedron

# 2. 添加粗粒化水
# 创建CG水模型
cat > water.gro << EOF
    1W      W    1   0.000   0.000   0.000
EOF
gmx solvate -cp cg_box.gro -cs water.gro -o cg_solv.gro

# 3. 添加离子
gmx genion -s ions.tpr -o cg_ions.gro \
    -pname NA+ -nname CL- -neutral -conc 0.15
```

**关键点**:
- 粗粒化水: W (4个水分子 → 1个珠子)
- 离子名称: NA+/CL- (MARTINI 3) 或 NA/CL (MARTINI 2)
- 盒子边距: 1.5 nm (比全原子稍大)

#### run_em/nvt/npt/production() - 模拟阶段
每个阶段都使用MARTINI标准参数：
- Reaction-Field静电
- 1.1 nm截断
- 特殊的温度/压力耦合参数

#### backmapping() - 反向映射
```bash
# 使用backward.py
backward.py -f cg_structure.gro -o aa_structure.gro

# 或使用CG2AT
cg2at -c cg_structure.gro -a aa_template.pdb -o aa_structure.gro
```

### 3.2 MDP模板

所有MDP文件都内嵌MARTINI标准参数，确保：
- 正确的静电处理 (reaction-field)
- 合适的截断距离 (1.1 nm)
- 粗粒化专用的耦合参数

### 3.3 错误处理

脚本包含14种常见错误的自动修复：
- ERROR-001 ~ ERROR-014
- 每个错误都有明确的原因和解决方案
- 优先自动修复，失败时提供手动方案

---

## 四、Token优化

### 4.1 优化策略

#### 1. 内嵌关键事实
```bash
# 注释中直接说明MARTINI参数
# dt = 0.020 ps  # 20 fs, MARTINI推荐
# rcoulomb = 1.1 nm  # MARTINI标准
```

#### 2. 结构化注释
```bash
# ============================================
# 功能模块名称
# ============================================
# 简短说明
```

#### 3. quick_ref精简
SKILLS_INDEX.yaml中只包含最关键的参数和错误，避免冗余。

### 4.2 Token统计

**脚本大小**:
- coarse-grained.sh: ~450 行, ~15 KB
- 故障排查文档: ~500 行, ~18 KB
- SKILLS_INDEX条目: ~40 行, ~2 KB

**预估Token消耗**:
- 正常流程: ~2000 tokens (quick_ref + 脚本关键部分)
- 出错流程: ~5000 tokens (+ 故障排查文档)
- 对比全手册: 节省 ~85% (从 ~30,000 tokens)

---

## 五、测试计划

### 5.1 单元测试

#### Test 1: MARTINI力场自动下载
```bash
# 删除现有力场
rm -rf martini.ff

# 运行脚本
MODE=aa2cg INPUT_PDB=test.pdb ./coarse-grained.sh

# 验证
[[ -d "coarse-grained/martini.ff" ]] && echo "PASS" || echo "FAIL"
```

#### Test 2: martinize自动安装
```bash
# 卸载martinize
pip3 uninstall -y vermouth-martinize

# 运行脚本
MODE=aa2cg INPUT_PDB=test.pdb ./coarse-grained.sh

# 验证
command -v martinize2 && echo "PASS" || echo "FAIL"
```

#### Test 3: 时间步长自动修正
```bash
# 设置错误的时间步长
export DT=0.002  # 全原子的2 fs

# 运行脚本
MODE=cg INPUT_GRO=test.gro INPUT_TOP=test.top ./coarse-grained.sh

# 验证日志
grep "AUTO-FIX.*0.020" coarse-grained/*.log && echo "PASS" || echo "FAIL"
```

### 5.2 集成测试

#### Test 4: 完整AA→CG流程
```bash
# 准备测试数据
wget https://files.rcsb.org/download/1UBQ.pdb

# 运行完整流程
MODE=aa2cg INPUT_PDB=1UBQ.pdb \
    SIM_TIME=100 \
    ./coarse-grained.sh

# 验证输出
[[ -f "coarse-grained/md.xtc" ]] && \
[[ -f "coarse-grained/CG_REPORT.md" ]] && \
echo "PASS" || echo "FAIL"
```

#### Test 5: 直接CG模拟
```bash
# 使用预先准备的CG结构
MODE=cg \
    INPUT_GRO=cg_protein.gro \
    INPUT_TOP=cg_topol.top \
    SIM_TIME=100 \
    ./coarse-grained.sh

# 验证
[[ -f "coarse-grained/md.xtc" ]] && echo "PASS" || echo "FAIL"
```

#### Test 6: 反向映射
```bash
# 安装backward.py
pip3 install backward

# 运行反向映射
MODE=backmapping INPUT_GRO=cg_final.gro ./coarse-grained.sh

# 验证
[[ -f "coarse-grained/aa_structure.gro" ]] && echo "PASS" || echo "FAIL"
```

### 5.3 压力测试

#### Test 7: 大系统模拟
```bash
# 使用大蛋白质 (>500残基)
MODE=aa2cg INPUT_PDB=large_protein.pdb \
    SIM_TIME=1000 \
    NTOMP=8 GPU_ID=0 \
    ./coarse-grained.sh

# 监控性能
# 预期: 比全原子快100-1000倍
```

#### Test 8: 失败恢复
```bash
# 模拟中断
MODE=cg INPUT_GRO=test.gro INPUT_TOP=test.top \
    SIM_TIME=1000 \
    ./coarse-grained.sh &
PID=$!

# 中途杀死
sleep 30
kill $PID

# 重新运行
MODE=cg INPUT_GRO=test.gro INPUT_TOP=test.top \
    SIM_TIME=1000 \
    ./coarse-grained.sh

# 验证从检查点恢复
grep "从检查点重启" coarse-grained/*.log && echo "PASS" || echo "FAIL"
```

---

## 六、已知限制

### 6.1 技术限制

1. **MARTINI力场覆盖**
   - 蛋白质: ✅ 完全支持
   - 脂质: ✅ 完全支持
   - 核酸: ⚠️ 部分支持
   - 小分子: ⚠️ 需要手动参数化

2. **反向映射精度**
   - 主链: ✅ 高精度
   - 侧链: ⚠️ 中等精度
   - 氢原子: ❌ 需要重新添加

3. **时间尺度**
   - 有效时间 = 实际时间 × 4
   - 20 fs步长 ≈ 全原子5 fs

### 6.2 工具依赖

必需:
- GROMACS (任何版本)
- martinize2 或 martinize.py

可选:
- backward.py (反向映射)
- insane (膜系统构建)
- CG2AT (反向映射替代)

### 6.3 使用限制

不适用场景:
- 需要原子级精度的研究
- 化学反应模拟
- 量子效应重要的系统
- 精确氢键分析

---

## 七、未来改进

### 7.1 短期 (v1.1)
- [ ] 添加膜蛋白专用模式
- [ ] 支持MARTINI小分子参数化
- [ ] 集成insane工具
- [ ] 添加更多CG水模型

### 7.2 中期 (v1.2)
- [ ] 支持SIRAH力场 (另一种CG力场)
- [ ] 自动化反向映射流程
- [ ] 多尺度模拟优化
- [ ] CG-AA混合模拟

### 7.3 长期 (v2.0)
- [ ] 机器学习辅助参数化
- [ ] 自适应分辨率模拟
- [ ] GPU加速优化
- [ ] 云端MARTINI力场库

---

## 八、总结

### 8.1 完成情况

✅ **已完成**:
1. 完整的AA→CG转换流程
2. 直接CG模拟支持
3. 反向映射接口
4. 多尺度模拟框架
5. MARTINI力场自动获取
6. martinize工具自动安装
7. 14种错误自动修复
8. 完整的故障排查文档
9. SKILLS_INDEX集成
10. Token优化 (节省85%)

### 8.2 技术亮点

1. **自动化程度高**: 从力场下载到工具安装全自动
2. **容错性强**: 14种错误自动修复
3. **参数准确**: 内嵌MARTINI官方推荐参数
4. **文档完善**: 详细的故障排查和最佳实践
5. **Token高效**: 精简注释和结构化设计

### 8.3 对比现有Skills

| 特性 | replica-exchange | metadynamics | coarse-grained |
|------|------------------|--------------|----------------|
| 自动安装依赖 | ❌ | ⚠️ (PLUMED) | ✅ (MARTINI+martinize) |
| 力场管理 | N/A | N/A | ✅ (自动下载) |
| 多模式支持 | ✅ (T/H/Both) | ✅ (PLUMED/AWH) | ✅ (4种模式) |
| 错误修复数 | 5 | 6 | 14 |
| Token优化 | ✅ | ✅ | ✅ |
| 文档完整性 | ✅ | ✅ | ✅ |

### 8.4 创新点

1. **首个支持力场自动获取的Skill**
2. **首个支持多尺度模拟的Skill**
3. **最完善的依赖自动安装**
4. **最详细的参数说明 (MARTINI特殊性)**

---

## 九、交付清单

### 9.1 代码文件
- ✅ `/root/.openclaw/workspace/automd-gromacs/scripts/advanced/coarse-grained.sh` (450行)

### 9.2 文档文件
- ✅ `/root/.openclaw/workspace/automd-gromacs/references/troubleshoot/coarse-grained-errors.md` (500行)

### 9.3 配置文件
- ✅ `/root/.openclaw/workspace/automd-gromacs/references/SKILLS_INDEX.yaml` (已更新)

### 9.4 报告文件
- ✅ 本开发报告
- ⏳ 测试报告 (待实战验证后生成)

---

## 十、致谢

- **MARTINI团队**: 开发优秀的粗粒化力场
- **martinize开发者**: 提供便捷的转换工具
- **GROMACS社区**: 提供强大的MD引擎
- **AutoMD-GROMACS项目**: 提供优秀的架构设计

---

**报告生成时间**: 2026-04-08 14:30 GMT+8  
**开发者**: GROMACS Expert Subagent  
**状态**: ✅ 开发完成，等待实战验证
