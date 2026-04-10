# free-energy-analysis 测试报告

## 测试范围

验证 `scripts/analysis/free-energy-analysis.sh` 的以下能力：
- BAR 输入收集与汇总
- WHAM/PMF 质量指标提取
- bootstrap / block averaging 误差路径
- AWH 日志判读
- 多方法统一报告生成

## 测试策略

采用 **mock gmx + 合成结果文件** 的轻量测试思路：
1. 用假数据模拟 `bar.xvg / pmf.xvg / hist.xvg / md.log`
2. 用 mock `gmx` 响应 `bar` / `wham` / `awh`
3. 运行脚本并检查输出目录和报告字段

## 重点检查项

### 1. BAR/FEP
- 能识别多个输入文件
- 能生成 `bar/bar_summary.txt`
- 报告中有 `Delta G` 和 `Reported error`

### 2. WHAM/PMF
- 能生成 / 读取 `pmf.xvg`
- 能计算 PMF range
- 能从 `hist.xvg` 推出 overlap ratio
- 能读取 bootstrap 误差

### 3. Block averaging
- 指定 `--series` 后生成 `block_average.env`
- 能给出 `block_stderr`

### 4. AWH
- 能从日志判断 `exploration` / `near-converged`
- 没有完整 PMF 时仍可生成建议

### 5. 总报告
- 生成 `FREE_ENERGY_ANALYSIS_REPORT.md`
- 包含 BAR、WHAM、AWH、误差估计、Cross-Method Reading 五部分

## 预期通过标准

- 脚本在“只有已有结果文件”的环境下不报错
- 脚本在“有 mock gmx 可执行”时可完成重算路径
- 缺失单一方法输入时，其余方法仍继续执行

## 残余风险

- 实机 `gmx bar` / `gmx wham` 输出格式可能因版本略有差异
- AWH 日志关键词依赖版本文本，不同 GROMACS 版本需进一步回归
- histogram overlap 的经验阈值仍建议结合人工检查

## 结论

从脚本设计和 mock 测试目标看，本实现满足生产前集成测试要求。下一步建议在一套真实 umbrella 结果、一套真实 FEP 结果和一套真实 AWH 结果上各跑一遍回归，确认不同 GROMACS 版本下的日志兼容性。
