#!/usr/bin/env python3

"""
AuroraDocs 依赖检查和修复工具
支持: Linux, macOS, Windows
功能: 检查所有依赖，自动安装缺失包，升级版本不匹配的包
"""

import subprocess
import sys
import os
import re
from pathlib import Path
from packaging import version
import pkg_resources

# 颜色代码
class Color:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    END = '\033[0m'
    
    @staticmethod
    def colored(text, color):
        if sys.platform == "win32":
            return text
        return f"{color}{text}{Color.END}"

def print_header(text):
    print()
    print("=" * 50)
    print(f"  {text}")
    print("=" * 50)
    print()

def print_success(msg):
    print(f"{Color.colored('✓', Color.GREEN)} {msg}")

def print_error(msg):
    print(f"{Color.colored('❌', Color.RED)} {msg}")

def print_warning(msg):
    print(f"{Color.colored('⚠️ ', Color.YELLOW)} {msg}")

def print_info(msg):
    print(f"{Color.colored('[info]', Color.BLUE)} {msg}")

def parse_requirements_file(file_path):
    """解析需求文件并返回包和版本的字典"""
    packages = {}
    
    if not os.path.exists(file_path):
        return packages
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            
            # 跳过注释和空行
            if not line or line.startswith('#'):
                continue
            
            # 跳过 -r 引用（直接处理被引用的文件）
            if line.startswith('-r'):
                continue
            
            # 解析包名和版本
            # 格式: package==version, package>=version, package[extras]==version
            match = re.match(r'^([a-zA-Z0-9_-]+)(?:\[.*?\])?(.*?)$', line)
            if match:
                pkg_name = match.group(1)
                version_spec = match.group(2).strip() if match.group(2) else ""
                packages[pkg_name] = version_spec
    
    return packages

def get_installed_version(package_name):
    """获取已安装的包版本，如果未安装返回 None"""
    try:
        dist = pkg_resources.get_distribution(package_name)
        return dist.version
    except pkg_resources.DistributionNotFound:
        return None

def normalize_package_name(name):
    """规范化包名（处理 underscore/dash）"""
    return name.lower().replace('_', '-')

def check_version_match(installed, required):
    """检查版本是否匹配"""
    if not required:
        return True  # 没有版本要求
    
    # 解析版本说明符
    if '==' in required:
        required_ver = required.split('==')[1].strip()
        return installed == required_ver
    elif '>=' in required:
        required_ver = required.split('>=')[1].strip()
        return version.parse(installed) >= version.parse(required_ver)
    elif '<=' in required:
        required_ver = required.split('<=')[1].strip()
        return version.parse(installed) <= version.parse(required_ver)
    elif '!=' in required:
        required_ver = required.split('!=')[1].strip()
        return version.parse(installed) != version.parse(required_ver)
    
    return True

def main():
    print_header("AuroraDocs - Dependency Checker & Fixer")
    
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # ============= 步骤 1: 激活环境 =============
    print_info("Checking Python environment...")
    print_success(f"Python {sys.version.split()[0]}")
    print()
    
    # ============= 步骤 2: 解析需求文件 =============
    print_info("Analyzing requirements files...")
    
    all_packages = {}
    
    # 解析 requirements-core.txt
    core_packages = parse_requirements_file("requirements-core.txt")
    all_packages.update(core_packages)
    print_success(f"requirements-core.txt: {len(core_packages)} packages")
    
    # 解析 requirements-ml.txt（会覆盖 core 中的同名包，但通常不会有重复）
    ml_packages = parse_requirements_file("requirements-ml.txt")
    all_packages.update(ml_packages)
    print_success(f"requirements-ml.txt: {len(ml_packages)} additional packages")
    
    # 解析 requirements-full.txt
    full_packages = parse_requirements_file("requirements-full.txt")
    all_packages.update(full_packages)
    print_success(f"requirements-full.txt: {len(full_packages)} additional packages")
    
    print(f"\nTotal: {len(all_packages)} unique packages")
    print()
    
    # ============= 步骤 3: 检查已安装的包 =============
    print_info("Checking installed packages...")
    print()
    
    good_packages = {}
    missing_packages = {}
    wrong_version_packages = {}
    
    for pkg_name, version_spec in sorted(all_packages.items()):
        installed_version = get_installed_version(pkg_name)
        
        if installed_version is None:
            # 包未安装
            print_error(f"{pkg_name}: MISSING")
            missing_packages[pkg_name] = version_spec
        else:
            # 检查版本
            if check_version_match(installed_version, version_spec):
                # 详细的版本信息
                if version_spec:
                    ver_info = f"{installed_version} ({version_spec})"
                else:
                    ver_info = installed_version
                print_success(f"{pkg_name}: {ver_info}")
                good_packages[pkg_name] = installed_version
            else:
                # 版本不匹配
                required_ver = version_spec.lstrip('=<>!')
                print_warning(f"{pkg_name}: {installed_version} → need {required_ver}")
                wrong_version_packages[pkg_name] = version_spec
    
    print()
    print_header("Check Summary")
    print(f"{Color.colored('✓ Good packages:', Color.GREEN)}        {len(good_packages)}")
    print(f"{Color.colored('❌ Missing packages:', Color.RED)}      {len(missing_packages)}")
    print(f"{Color.colored('⚠️  Wrong version:', Color.YELLOW)}     {len(wrong_version_packages)}")
    print()
    
    # ============= 步骤 4: 自动修复 =============
    if missing_packages or wrong_version_packages:
        print_info("Fixing dependencies...")
        print()
        
        # 安装缺失的包
        if missing_packages:
            print("📦 Installing missing packages...")
            for pkg_name, version_spec in missing_packages.items():
                pkg_spec = f"{pkg_name}{version_spec}" if version_spec else pkg_name
                print(f"  → Installing {pkg_spec}...", end=" ", flush=True)
                
                result = subprocess.run(
                    [sys.executable, "-m", "pip", "install", "--prefer-binary", pkg_spec, "-q"],
                    capture_output=True
                )
                
                if result.returncode == 0:
                    print(Color.colored("✓", Color.GREEN))
                else:
                    print(Color.colored("✗", Color.RED))
            print()
        
        # 升级版本不匹配的包
        if wrong_version_packages:
            print("🔄 Upgrading packages with wrong versions...")
            for pkg_name, version_spec in wrong_version_packages.items():
                pkg_spec = f"{pkg_name}{version_spec}" if version_spec else pkg_name
                print(f"  → Upgrading {pkg_spec}...", end=" ", flush=True)
                
                result = subprocess.run(
                    [sys.executable, "-m", "pip", "install", "--prefer-binary", pkg_spec, "--upgrade", "-q"],
                    capture_output=True
                )
                
                if result.returncode == 0:
                    print(Color.colored("✓", Color.GREEN))
                else:
                    print(Color.colored("✗", Color.RED))
            print()
        
        # ============= 步骤 5: 验证 =============
        print_info("Verifying installation...")
        print()
        
        all_fixed = True
        for pkg_name, version_spec in missing_packages.items():
            installed_version = get_installed_version(pkg_name)
            if installed_version is None:
                print_error(f"{pkg_name}: Still missing!")
                all_fixed = False
            else:
                print_success(f"{pkg_name}: {installed_version}")
        
        for pkg_name, version_spec in wrong_version_packages.items():
            installed_version = get_installed_version(pkg_name)
            if installed_version and check_version_match(installed_version, version_spec):
                print_success(f"{pkg_name}: {installed_version}")
            else:
                print_error(f"{pkg_name}: Still has issues!")
                all_fixed = False
        
        print()
        if all_fixed:
            print_header("✅ All dependencies are now correct!")
        else:
            print_header("⚠️  Some dependencies still have issues")
            return 1
    else:
        print_header("✅ All dependencies are correct!")
    
    # ============= 最后建议 =============
    print("📝 Next steps:")
    print("  1. Run: bash run.sh (Linux/Mac) or run.bat (Windows)")
    print("  2. If issues remain: check error messages above")
    print("  3. For manual verification: pip list | grep -E 'torch|transformers|fastapi'")
    print()
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
