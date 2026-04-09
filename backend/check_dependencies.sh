#!/bin/bash

# AuroraDocs 依赖检查和修复脚本
# 功能: 检查所有依赖，自动安装缺失包，升级版本不匹配的包

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo "=================================================="
echo "  AuroraDocs - Dependency Checker & Fixer"
echo "=================================================="
echo ""

# ============= 颜色定义 =============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============= 激活环境 =============

echo -e "${BLUE}[1/5]${NC} Activating Python environment..."

# 检测 Conda 或 venv
if command -v conda &> /dev/null; then
    eval "$(conda shell.bash hook 2>/dev/null)" || true
    CONDA_ENV=$(conda env list | grep "auroradocs" | awk '{print $1}' | head -1)
    
    if [ -z "$CONDA_ENV" ]; then
        echo -e "${YELLOW}⚠️  Conda environment 'auroradocs' not found${NC}"
        echo "Creating Conda environment..."
        conda create -y -n auroradocs python=3.11
        echo "Please run this script again after environment creation"
        exit 0
    fi
    
    echo "✓ Using Conda environment: auroradocs"
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate auroradocs
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    echo "✓ Using venv environment"
else
    echo -e "${RED}❌ No Python environment found${NC}"
    echo "Run: bash run.sh (to setup environment first)"
    exit 1
fi

echo "✓ Python: $(python --version)"
echo ""

# ============= 解析需求文件 =============

echo -e "${BLUE}[2/5]${NC} Analyzing requirements files..."

declare -A required_packages
declare -A required_versions

# 函数: 解析需求文件
parse_requirements() {
    local file=$1
    if [ ! -f "$file" ]; then
        return
    fi
    
    while IFS= read -r line; do
        # 跳过注释和空行
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        
        # 跳过 -r 引用
        [[ "$line" =~ ^-r ]] && continue
        
        # 解析包名和版本
        # 处理格式: package==version, package>=version, package[extras]==version
        if [[ "$line" =~ ^([a-zA-Z0-9_-]+)(\[.*?\])?([=!<>]*)(.*) ]]; then
            local pkg="${BASH_REMATCH[1]}"
            local extras="${BASH_REMATCH[2]}"
            local op="${BASH_REMATCH[3]}"
            local version="${BASH_REMATCH[4]}"
            
            required_packages["$pkg"]=1
            [ -n "$version" ] && required_versions["$pkg"]="${op}${version}"
        fi
    done < "$file"
}

# 解析所有需求文件
parse_requirements "requirements-core.txt"
parse_requirements "requirements-ml.txt"
parse_requirements "requirements-full.txt"

echo "✓ Found ${#required_packages[@]} required packages"
echo ""

# ============= 检查和修复依赖 =============

echo -e "${BLUE}[3/5]${NC} Checking installed packages..."
echo ""

declare -a missing_packages
declare -a wrong_version_packages
declare -a outdated_packages
declare -a good_packages

for pkg in "${!required_packages[@]}"; do
    # 获取预期版本 (去掉 extras)
    pkg_name="${pkg}"
    expected_version="${required_versions[$pkg]:-}"
    
    # 查询已安装版本
    installed_version=$(python -c "import pkg_resources; print(pkg_resources.get_distribution('$pkg_name').version)" 2>/dev/null || echo "")
    
    if [ -z "$installed_version" ]; then
        # 包未安装
        echo -e "${RED}❌${NC} ${pkg_name}: MISSING"
        missing_packages+=("$pkg_name")
    else
        if [ -z "$expected_version" ]; then
            # 没有指定版本要求，已安装即可
            echo -e "${GREEN}✓${NC} ${pkg_name}: ${installed_version} (any version)"
            good_packages+=("$pkg_name")
        elif [[ "$expected_version" =~ ^== ]]; then
            # 需要精确版本
            required_ver="${expected_version#==}"
            if [ "$installed_version" = "$required_ver" ]; then
                echo -e "${GREEN}✓${NC} ${pkg_name}: ${installed_version}"
                good_packages+=("$pkg_name")
            else
                echo -e "${YELLOW}⚠️ ${NC} ${pkg_name}: ${installed_version} → need ${required_ver}"
                wrong_version_packages+=("$pkg_name${expected_version}")
            fi
        else
            # 范围版本要求
            echo -e "${GREEN}✓${NC} ${pkg_name}: ${installed_version} (${expected_version})"
            good_packages+=("$pkg_name")
        fi
    fi
done

echo ""
echo "=================================================="
echo "  Summary"
echo "=================================================="
echo -e "${GREEN}✓ Good:${NC}            ${#good_packages[@]}"
echo -e "${RED}❌ Missing:${NC}         ${#missing_packages[@]}"
echo -e "${YELLOW}⚠️  Wrong version:${NC}   ${#wrong_version_packages[@]}"
echo ""

# ============= 自动修复 =============

if [ ${#missing_packages[@]} -gt 0 ] || [ ${#wrong_version_packages[@]} -gt 0 ]; then
    echo -e "${BLUE}[4/5]${NC} Fixing dependencies..."
    echo ""
    
    # 安装缺失的包
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo "📦 Installing missing packages..."
        for pkg in "${missing_packages[@]}"; do
            echo "  → Installing ${pkg}..."
            pip install --prefer-binary "$pkg" -q || {
                echo -e "${RED}    ❌ Failed to install $pkg${NC}"
            }
        done
        echo ""
    fi
    
    # 升级版本不匹配的包
    if [ ${#wrong_version_packages[@]} -gt 0 ]; then
        echo "🔄 Upgrading packages with wrong versions..."
        for pkg_spec in "${wrong_version_packages[@]}"; do
            echo "  → Upgrading ${pkg_spec}..."
            pip install --prefer-binary "$pkg_spec" --upgrade -q || {
                echo -e "${RED}    ❌ Failed to upgrade $pkg_spec${NC}"
            }
        done
        echo ""
    fi
    
    echo -e "${BLUE}[5/5]${NC} Verifying installation..."
    echo ""
    
    # 重新验证
    all_good=true
    for pkg in "${required_packages[@]}"; do
        installed_version=$(python -c "import pkg_resources; print(pkg_resources.get_distribution('$pkg').version)" 2>/dev/null || echo "")
        if [ -z "$installed_version" ]; then
            echo -e "${RED}❌${NC} ${pkg}: Still missing!"
            all_good=false
        fi
    done
    
    if [ "$all_good" = true ]; then
        echo -e "${GREEN}✅ All dependencies are now correct!${NC}"
    else
        echo -e "${RED}⚠️  Some dependencies still have issues${NC}"
    fi
else
    echo -e "${GREEN}✅ All dependencies are correct!${NC}"
fi

echo ""
echo "=================================================="
echo "  Dependency check complete!"
echo "=================================================="
echo ""
echo "📝 Next steps:"
echo "  1. If all checks passed: run 'bash run.sh'"
echo "  2. If issues remain: check error messages above"
echo "  3. For manual install: pip install -r requirements-ml.txt"
echo ""
