# AuroraDocs 依赖检查工具使用指南

> **新功能**: 脚本现在可以自动发现和管理所有已有的 Conda + venv 环境！

## 快速开始

### Linux / macOS
```bash
cd backend
bash check_dependencies.sh
```

### Windows
```batch
cd backend
check_dependencies.bat
```

### 所有平台（推荐）
```bash
# 或 python 或 python3
python3 check_dependencies.py
```

---

## ✨ 新功能: 智能环境检测

所有脚本现在都能**自动发现并让用户管理 Conda 和 venv 环境**！

### 工作流程

当你运行脚本时：

1. **自动发现所有已有的环境**
   - 列出所有 Conda 环境（名称、路径、Python 版本）
   - 检测本地 `venv` 目录

2. **智能选择环境**
   - ✅ 单一环境：自动使用
   - 🎯 多个环境：优先选择 `auroradocs`（如果存在）
   - 📋 显示菜单：让用户选择其他环境

3. **在目标环境中执行检查和修复**
   - 直接在选定的环境中安装/升级包
   - 无需手动激活环境

### 实际对话示例

```
[0/5] Detecting Python environments...

✓ Found 2 environment(s):

  1 auroradocs (conda)
      Path: /home/user/miniforge3/envs/auroradocs
      Python: Python 3.11.8

  2 venv (local)
      Path: /home/user/project/backend/venv
      Python: Python 3.10.12

✓ Auto-selected: auroradocs (conda)

[1/5] Activating environment...
✓ Using pip: /home/user/miniforge3/envs/auroradocs/bin/pip
```

---

## 功能说明

这个工具会自动执行以下操作：

### 0️⃣ 环境检测和选择（新功能）
- ✅ 自动发现所有 Conda 环境
- ✅ 自动检测本地 venv
- ✅ 显示每个环境的 Python 版本
- ✅ 优先选择 `auroradocs` 环境
- ✅ 单环境时自动选择，多环境时提示用户选择

### 1️⃣ 激活环境
- ✅ 在选定的环境中获取 pip 路径
- ✅ 验证环境完整性
- ✅ 显示使用的 pip 版本

### 2️⃣ 解析需求文件
- ✅ `requirements-core.txt` - 核心依赖 (FastAPI, SQLAlchemy 等)
- ✅ `requirements-ml.txt` - AI 依赖 (PyTorch, Transformers)
- ✅ `requirements-full.txt` - 完整依赖 (vLLM, DeepSpeed 等)

### 3️⃣ 检查已安装的包
- ✅ 列出所有已安装包
- ✅ 检查版本是否匹配
- ✅ 分类统计：好的/缺失/版本错误

### 4️⃣ 自动修复
- ✅ 安装缺失的包
- ✅ 升级版本不匹配的包
- ✅ 优先使用预编译二进制包 (`--prefer-binary`)

### 5️⃣ 验证
- ✅ 重新检查所有包
- ✅ 确认修复成功
- ✅ 提供后续步骤建议

## 脚本对比

| 功能 | check_dependencies.py | check_dependencies.sh | check_dependencies.bat |
|------|----------------------|----------------------|----------------------|
| **平台支持** | ✅ 全平台 | ✅ Linux/Mac | ✅ Windows |
| **易用性** | 最简单 | 需要 bash | 需要 cmd |
| **适配性** | 最强 | 最强 | 一般 |
| **推荐指数** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

## 使用场景

### 场景 1: 自动修复所有依赖（推荐）
```bash
python3 check_dependencies.py
```
**结果：** 自动检查并修复所有缺失或版本错误的包

### 场景 2: 只检查，不修复
编辑脚本，注释掉修复部分，然后运行

### 场景 3: 在 CI/CD 中使用
```yaml
- name: Check dependencies
  run: python check_dependencies.py
```

### 场景 4: 手动重新安装
```bash
# 完整重新安装
pip install -r requirements-ml.txt --force-reinstall

# 只装核心包
pip install -r requirements-core.txt

# 只装 AI 包
pip install torch==2.2.0 transformers==4.35.2 peft==0.6.2
```

## 在不同环境中的表现

### ✅ 新安装 (AutoDL)
```
[info] Checking Python environment...
✓ Python 3.11.0
[info] Analyzing requirements files...
✓ requirements-core.txt: 15 packages
✓ requirements-ml.txt: 3 additional packages
...
📦 Installing missing packages...
  → Installing fastapi==0.104.1... ✓
  → Installing torch==2.2.0... ✓
  ... (所有包都会安装)
[5/5] Verification complete!
✅ All dependencies are now correct!
```

### ✅ 升级环境 (版本不匹配)
```
[info] Checking installed packages...
✓ fastapi: 0.103.0 (==0.104.1)  ← 版本低
⚠️  pydantic: 2.4.0 → need 2.5.0
...
🔄 Upgrading packages with wrong versions...
  → Upgrading fastapi==0.104.1... ✓
  → Upgrading pydantic==2.5.0... ✓
✅ All dependencies are now correct!
```

### ✅ 保险检查 (已有正确版本)
```
✓ fastapi: 0.104.1 (==0.104.1)
✓ pydantic: 2.5.0
✓ torch: 2.2.0
...
Good packages:        18
Missing packages:     0
Wrong version:        0
✅ All dependencies are correct!
```

## 常见问题

### Q: 脚本找不到包？
**A:** 确保在 `backend/` 目录中运行脚本

### Q: 错误 `ModuleNotFoundError: No module named 'packaging'`？
**A:** `packaging` 是 pip 的依赖，通常已安装。如果没有：
```bash
pip install packaging
```

### Q: 某个包安装失败？
**A:** 可能是网络问题或包不兼容。查看错误信息：
```bash
# 带完整输出重新尝试
pip install package_name -v
```

### Q: 想完全重新安装？
**A:** 
```bash
# 删除虚拟环境（Conda）
conda remove -n auroradocs --all

# 或 venv
rm -rf venv

# 然后运行
bash run.sh
```

## 脚本输出说明

```
=====================================
  AuroraDocs - Dependency Checker & Fixer
=====================================

[info] Checking Python environment...
✓ Python 3.11.0

[info] Analyzing requirements files...
✓ requirements-core.txt: 15 packages
✓ requirements-ml.txt: 3 additional packages
✓ requirements-full.txt: 0 additional packages

Total: 18 unique packages

[info] Checking installed packages...
✓ fastapi: 0.104.1 (==0.104.1)          ← 正确
✓ pydantic: 2.5.0 (==2.5.0)
⚠️  torch: 2.1.0 → need 2.2.0             ← 版本低
❌ transformers: MISSING                 ← 缺失
...

===== Check Summary =====
✓ Good packages:        15
❌ Missing packages:    3
⚠️  Wrong version:      2

📦 Installing missing packages...
  → Installing transformers==4.35.2... ✓
  → Installing peft==0.6.2... ✓
  → Installing vllm==0.3.3... ✓

🔄 Upgrading packages with wrong versions...
  → Upgrading torch==2.2.0... ✓
  → Upgrading pydantic==2.5.0... ✓

[5/5] Verifying installation...
✓ transformers: 4.35.2
✓ peft: 0.6.2
✓ vllm: 0.3.3
✓ torch: 2.2.0
✓ pydantic: 2.5.0

===== ✅ All dependencies are now correct! =====

📝 Next steps:
  1. Run: bash run.sh (Linux/Mac) or run.bat (Windows)
  2. If issues remain: check error messages above
  3. For manual verification: pip list | grep -E 'torch|transformers|fastapi'
```

## 技术细节

### 版本匹配逻辑
- `==X.Y.Z` - 精确版本（必须完全相同）
- `>=X.Y.Z` - 最低版本（已安装 ≥ 要求）
- `<=X.Y.Z` - 最高版本（已安装 ≤ 要求）
- `!=X.Y.Z` - 不能是某版本
- 空值 - 任意版本都可以

### 包安装策略
1. **优先二进制**: `--prefer-binary` - 避免编译
2. **自动降级**: 如果安装失败，自动尝试用流行版本
3. **定向升级**: 只升级有问题的包

### 包规范化
- 包名转小写：`FastAPI` → `fastapi`
- dash/underscore 规范化：`python_jose` → `python-jose`

## 进阶用法

### 只检查，不修复
编辑脚本，在 `# 自动修复` 部分添加 return 语句

### 添加自定义检查
在 `main()` 函数中添加检查逻辑

### 输出到文件
```bash
python3 check_dependencies.py > dependency_report.txt 2>&1
```

### 集成到 CI/CD
GitHub Actions 例子：
```yaml
- name: Check dependencies
  run: |
    cd backend
    python3 check_dependencies.py
```

## 支持和问题

如果遇到问题：
1. 检查错误信息
2. 运行 `pip list` 查看已安装包
3. 查看 [PyPA 文档](https://pypa.io/)
4. 考虑在虚拟环境中重新安装

---

**最后更新:** 2024-04-09
**支持平台:** Linux, macOS, Windows
**Python 版本:** 3.9+
