# AuroraDocs 🌟

> 智能文档生成平台 - 基于 LoRA 微调大模型

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Node.js 16+](https://img.shields.io/badge/node.js-16+-green.svg)](https://nodejs.org/)
[![Vue 3](https://img.shields.io/badge/vue-3-green.svg)](https://vuejs.org/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg)](https://www.docker.com/)

## ✨ 功能

- 🧠 **智能文档生成** - 支持文本、代码、流程图等多模态内容
- 🎯 **个性化训练** - 基于用户样例的 LoRA 微调
- ☁️ **云边协同** - 远程 GPU 后端 + 轻量级客户端
- 📝 **协作编辑** - 实时协作、版本控制、模板库
- 🛡️ **企业安全** - 本地存储、端到端加密

## 🚀 快速开始

### 前置要求
- **前端**：Windows/Mac/Linux，4GB 内存
- **后端**：Linux，Docker，NVIDIA GPU（可选）

### Docker 部署

```bash
git clone https://github.com/Eternity5188/AuroraDocs.git
cd AuroraDocs

cp .env.example .env
docker-compose up -d

# 验证：访问 http://localhost:8000/docs
```

### 前端配置

```bash
cd frontend
npm install
npm run dev

# 访问 http://localhost:5173
```

## 📁 结构

```
├── backend/       # FastAPI 后端 + AI 模型
├── frontend/      # Vue 3 + Electron 客户端
├── docker-compose.yml
└── .env.example
```

## 🛠️ 技术栈

**后端**：FastAPI · PostgreSQL · Redis · Celery · vLLM · LoRA  
**前端**：Vue 3 · TypeScript · Electron · Element Plus

## 📄 License

MIT License - 详见 [LICENSE](./LICENSE)

## 🐛 问题反馈

[提交 Issue](https://github.com/Eternity5188/AuroraDocs/issues)
