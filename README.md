# AuroraDocs 🌟

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Node.js 16+](https://img.shields.io/badge/node.js-16+-green.svg)](https://nodejs.org/)
[![Vue 3](https://img.shields.io/badge/vue-3-green.svg)](https://vuejs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-blue.svg)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg)](https://www.docker.com/)

**通用文档智能生成平台** - 基于 LoRA 微调大模型，为各行业提供个性化文档生成解决方案

[🚀 快速开始](#快速开始) • [🐛 问题反馈](https://github.com/your-repo/AuroraDocs/issues)

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
- **操作系统**：Windows 10+ / macOS 10.15+ / Ubuntu 18.04+
- **Python**：3.9 或更高版本
- **Node.js**：16 或更高版本
- **Docker**：20.10+ (可选，用于容器化部署)
- **GPU**：NVIDIA GPU with CUDA 11.8+ (推荐 RTX 3090/4090 用于训练)

### ⚡ 一键安装 (推荐)

#### 方式一：桌面应用 (Windows 用户)
```bash
# 下载最新发布版本
# https://github.com/your-repo/AuroraDocs/releases

# 运行安装包，自动配置本地环境
```

#### 方式二：Docker 部署
```bash
git clone https://github.com/your-repo/AuroraDocs.git
cd AuroraDocs

# 启动完整服务栈
docker-compose up -d

# 访问 http://localhost:3000
```

### 🔧 手动安装

#### 1. 克隆项目
```bash
git clone https://github.com/your-repo/AuroraDocs.git
cd AuroraDocs
```

#### 2. 后端配置
```bash
cd backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件配置数据库、Redis 等
```

#### 3. 前端配置
```bash
cd ../frontend

# 安装依赖
npm install

# 配置环境
cp .env.example .env
# 设置 VITE_API_BASE_URL=http://localhost:8000
```

#### 4. 启动服务

**终端 1：启动后端 API**
```bash
cd backend
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

**终端 2：启动任务队列**
```bash
cd backend
celery -A app.tasks.celery_app worker --loglevel=info
```

**终端 3：启动前端**
```bash
cd frontend
npm run dev
```

#### 5. 桌面应用打包 (可选)
```bash
cd frontend
npm run electron:build
# 生成的安装包位于 dist_electron/
```

### 🌐 访问应用
- **Web 界面**：http://localhost:5173
- **API 文档**：http://localhost:8000/docs
- **任务监控**：http://localhost:5555 (Flower)

---

## 📖 使用指南

### 🎯 基础使用流程

1. **📤 上传样例文档**
   - 支持 PDF、DOCX、TXT、MD 格式
   - 建议上传 3-5 个高质量样例

2. **🔧 配置 API**
   - 支持 OpenAI、Azure OpenAI、自定义 API
   - 本地存储，不泄露密钥

3. **🚀 提交训练任务**
   - 设置模型参数 (epochs, learning rate)
   - 选择 Prompt 模板

4. **📊 监控训练进度**
   - 实时查看任务状态
   - 下载训练结果

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
