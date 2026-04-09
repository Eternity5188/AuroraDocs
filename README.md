# AuroraDocs 🌟

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Node.js 16+](https://img.shields.io/badge/node.js-16+-green.svg)](https://nodejs.org/)
[![Vue 3](https://img.shields.io/badge/vue-3-green.svg)](https://vuejs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-blue.svg)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg)](https://www.docker.com/)

**通用文档智能生成平台** - 基于 LoRA 微调大模型，为各行业提供个性化文档生成解决方案

[🚀 快速开始](#快速开始) • [🐛 问题反馈](https://github.com/Eternity5188/AuroraDocs/issues)

</div>

---

## ✨ 功能特性

### 🚀 核心能力
- **🧠 智能文档生成**：支持文本、代码、流程图、图表等多模态内容生成
- **🎯 个性化训练**：基于用户样例文档进行 LoRA 微调，生成专属 AI 模型
- **📝 协作文档管理**：实时协作编辑、版本控制、智能模板库
- **🔍 质量优化引擎**：智能校验、风格统一、知识图谱增强

### 🎯 应用场景
- 📋 **技术文档**：API 文档、用户手册、开发指南
- 📊 **商业报告**：市场分析、商业计划书、数据报告
- ⚖️ **法律文件**：合同起草、法律意见书、合规文档
- 🏥 **医疗记录**：病历辅助、医疗报告、患者教育
- 📢 **营销内容**：广告文案、品牌故事、社交媒体内容
- 🔬 **科研文档**：论文撰写、研究报告、学术出版
- 🏢 **企业文档**：内部手册、培训材料、政策文件

### 🏗️ 架构优势
- **☁️ 云边协同**：远程 GPU 后端 + 轻量级客户端
- **🔧 灵活配置**：支持自定义 API 提供商和模型参数
- **⚡ 高性能**：DeepSpeed + vLLM 加速推理，Celery 分布式任务
- **🛡️ 企业级安全**：本地数据存储，端到端加密通信

---

## 🖼️ 界面预览

<div align="center">
  <img src="docs/screenshots/dashboard.png" alt="主界面" width="45%">
  <img src="docs/screenshots/training.png" alt="训练界面" width="45%">
</div>

---

## 🛠️ 技术栈

### 后端 (Remote GPU Server)
- **框架**：FastAPI + Uvicorn + Gunicorn
- **数据库**：PostgreSQL + Redis + Milvus 向量数据库
- **AI 引擎**：Qwen2.5-14B + LoRA + DeepSpeed + vLLM
- **任务队列**：Celery + Redis + Flower (监控)
- **文件存储**：MinIO 对象存储

### 前端 (Lightweight Client)
- **框架**：Vue 3 + TypeScript + Vite + Electron
- **UI 库**：Element Plus + Tailwind CSS
- **状态管理**：Pinia + Vuex 4
- **图表可视化**：ECharts + D3.js
- **富文本编辑**：Quill.js + Monaco Editor

---

## 📁 项目结构

```
E:\Software\AuroraDocs/
├── backend/                    # 🚀 后端服务 (远程 GPU 训练/推理服务器)
│   ├── app/                   # 应用核心代码
│   │   ├── api/              # REST API 路由
│   │   ├── core/             # 核心配置与数据库
│   │   ├── models/           # 数据模型与 ORM
│   │   ├── schemas/          # Pydantic 数据验证
│   │   ├── services/         # 业务逻辑服务
│   │   ├── tasks/            # Celery 异步任务
│   │   └── utils/            # 工具函数
│   ├── scripts/              # 部署与维护脚本
│   ├── tests/                # 单元测试与集成测试
│   ├── requirements.txt      # Python 依赖
│   └── Dockerfile            # 容器化配置
├── frontend/                  # 💻 前端客户端 (Windows/Web)
│   ├── electron/             # Electron 桌面应用
│   ├── public/               # 静态资源
│   ├── src/                  # 源代码
│   │   ├── api/             # API 客户端
│   │   ├── components/      # Vue 组件
│   │   ├── router/          # 路由配置
│   │   ├── stores/          # 状态管理
│   │   ├── types/           # TypeScript 类型定义
│   │   ├── utils/           # 工具函数
│   │   └── views/           # 页面视图
│   ├── config/              # 前端配置
│   ├── package.json         # Node.js 依赖
│   └── Dockerfile           # 前端容器化
├── models/                   # 🤖 AI 模型文件
│   ├── adapters/            # LoRA 适配器权重
│   ├── base/                # 基础模型缓存
│   └── checkpoints/         # 训练检查点
├── config/                   # ⚙️ 配置文件
├── docker/                   # 🐳 Docker 编排
├── docs/                     # 📚 项目文档
├── scripts/                  # 🔧 构建脚本
├── .env.example             # 🔐 环境变量模板
├── docker-compose.yml       # 🐳 服务编排
└── README.md                # 📖 项目说明
```

---

## 🚀 快速开始

### 📋 系统要求

#### 前端客户端（轻量级）
- **操作系统**：Windows 10+ / macOS 10.15+ / Ubuntu 18.04+
- **内存**：4GB 或以上
- **存储**：200MB 可用空间
- **网络**：连接到后端服务器

#### 后端服务器（GPU 计算）
- **操作系统**：Linux（推荐 Ubuntu 20.04+）
- **Python**：3.9 或更高版本
- **Docker**：20.10+ 和 Docker Compose
- **GPU**：NVIDIA GPU with CUDA 11.8+ (推荐 RTX 3090/4090 用于训练)
- **内存**：32GB+ (根据模型大小调整)
- **存储**：100GB+ (模型 + 数据)

### ⚡ 一键安装 (推荐)

#### 方式一：前端客户端（推荐）
```bash
# 1. 下载最新发布版本
https://github.com/Eternity5188/AuroraDocs/releases

# 2. 运行安装包（Windows）
AuroraDocs-Setup.exe

# 3. 启动应用后配置后端服务器地址
# 在设置面板中输入：http://[服务器IP]:8000
```

#### 方式二：后端服务器部署
```bash
# 1. 克隆项目到服务器
git clone https://github.com/Eternity5188/AuroraDocs.git
cd AuroraDocs

# 2. 创建环境文件
cp .env.example .env
# 编辑 .env 配置数据库、GPU 等参数

# 3. 启动服务栈
docker-compose up -d

# 4. 确认 API 是否运行
curl http://localhost:8000/docs
```

### 🌐 服务地址

**前端客户端**
- Windows/Mac/Linux 桌面应用

**后端服务器**（在服务器部署后）
- **API 文档**：http://[服务器IP]:8000/docs
- **API 基础**：http://[服务器IP]:8000

---

## 📖 使用指南

详细的使用教程请在客户端应用的 **"教程"** 页面查看，包括：
- 如何上传样例文档
- 如何配置 API 密钥
- 如何提交训练任务
- 如何查看和下载结果

---

## 🧪 开发指南

### 代码规范
- 后端：遵循 PEP 8，类型注解
- 前端：ESLint + Prettier，Vue 3 Composition API
- 提交：Conventional Commits

### 测试
```bash
# 后端测试
cd backend
pytest

# 前端测试
cd frontend
npm run test
```

### 部署
```bash
# 使用 Docker Compose
docker-compose up -d
```
