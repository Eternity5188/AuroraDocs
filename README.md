# AuroraDocs - 通用文档智能生成平台

基于LoRA微调大模型的通用文档智能生成平台，采用“远程GPU后端 + 轻量Windows/Web客户端”的现代架构，为各行业文档编辑者提供符合行业要求、样例风格的高质量文档生成解决方案。

## 功能特性

### 🚀 核心功能
- **智能文档生成**：支持文本、代码、流程图、图表等多模态生成
- **个性化模型训练**：基于用户样例文档训练专属AI模型
- **文档协作管理**：实时协作编辑、版本控制、模板库
- **内容质量优化**：智能校验、风格统一、知识更新

### 🎯 应用场景
- 技术文档编写（API文档、用户手册）
- 商业报告撰写（市场分析、商业计划书）
- 法律文件生成（合同、法律意见书）
- 医疗记录辅助（病历、医疗报告）
- 营销内容创作（广告文案、品牌故事）
- 科研文档支持（论文、研究报告）
- 企业文档管理（内部手册、培训材料）

## 技术栈

### 后端
- **框架**：FastAPI + Uvicorn
- **数据库**：PostgreSQL + Redis + Milvus
- **AI**：Qwen2.5-14B + LoRA + DeepSpeed + vLLM
- **任务队列**：Celery + Redis
- **文件存储**：MinIO

### 前端
- **框架**：Vue3 + TypeScript + Vite
- **UI库**：Element Plus
- **状态管理**：Pinia
- **图表**：ECharts
- **编辑器**：Mavon Editor

### 部署
- **后端部署**：AutoDL / 校园GPU服务器（RTX 4090），负责模型微调、推理、模型管理
- **前端部署**：Windows/Web 轻量客户端，通过 REST API / WebSocket 与后端通信
- **用户自定义 API**：客户端支持用户配置自己的 API 提供商、终端地址与密钥，调整到当前文档生成任务
- **用户自定义 API**：客户端支持用户配置自己的 API 提供商、终端地址与密钥，调整到当前文档生成任务
- **容器化**：Docker + Docker Compose 用于后端服务部署
- **反向代理**：Nginx

## 系统架构

- **后端服务**：部署在远程GPU服务器，负责样例预处理、LoRA微调、模型推理、任务调度与结果存储、用户 API 配置
- **前端客户端**：可部署为Vue3 Web界面或Electron桌面应用，主要负责用户交互、样例上传、任务管理、用户 API 配置和结果展示
- **通信方式**：客户端通过安全API与后端通信，训练与推理请求在后端执行，客户端不承担模型训练任务

## 项目结构

```
AuroraDocs/
├── backend/                 # 后端服务（远程GPU训练/推理服务器）
│   ├── app/                # 应用代码
│   │   ├── api/           # API路由
│   │   ├── core/          # 核心配置
│   │   ├── models/        # 数据模型
│   │   ├── schemas/       # Pydantic模式
│   │   ├── services/      # 业务逻辑
│   │   ├── tasks/         # 异步任务
│   │   ├── config/        # 应用配置
│   │   ├── utils/         # 工具函数
│   │   └── middleware/    # 中间件
│   ├── scripts/           # 部署脚本
│   ├── tests/             # 单元测试
│   └── requirements.txt   # Python依赖
├── frontend/               # 轻量客户端应用（Windows/Web）
│   ├── public/            # 静态资源
│   ├── src/               # 源代码
│   │   ├── api/          # API调用
│   │   ├── components/   # Vue组件
│   │   ├── router/       # 路由配置
│   │   ├── stores/       # 状态管理
│   │   ├── types/        # TypeScript类型
│   │   ├── utils/        # 工具函数
│   │   └── views/        # 页面组件
│   ├── config/           # 前端配置
│   └── package.json      # Node.js依赖
├── models/                # AI模型文件
│   ├── adapters/         # LoRA适配器
│   └── base/             # 基础模型
├── config/                # 配置文件
├── logs/                  # 日志文件
├── docker/                # Docker配置
├── docs/                  # 项目文档
├── scripts/               # 构建脚本
├── .env.example          # 环境变量示例
└── README.md             # 项目说明
```

## 快速开始

### 环境要求
- Python 3.9+
- Node.js 16+
- Docker & Docker Compose
- NVIDIA GPU (推荐RTX 4090)用于后端服务器部署

### 部署说明
后端服务建议部署在远程GPU服务器（如AutoDL、校园GPU集群），前端客户端可在Windows本地运行或通过Web浏览器访问。

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-repo/AuroraDocs.git
   cd AuroraDocs
   ```

2. **后端设置**
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **前端设置**
   ```bash
   cd frontend
   npm install
   ```

4. **桌面应用打包**
   ```bash
   cd frontend
   npm run electron:build
   ```
   打包产物会生成在 `frontend/dist_electron` 目录下，可用于 Windows 安装包或 ZIP 下载。

5. **环境配置**
   ```bash
   cd backend
   copy ..\.env.example .env
   # 编辑 backend\.env 文件，配置数据库、Redis、MinIO 等信息

   cd ..\frontend
   copy .env.example .env
   # 配置 VITE_API_BASE_URL 为后端地址
   ```

5. **启动服务**
   ```bash
   # 启动后端 API
   cd backend
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

   # 启动 Celery worker (另开终端)
   cd backend
   celery -A app.tasks.celery_app.celery_app worker --loglevel=info

   # 启动前端 (另开终端)
   cd frontend
   npm run dev
   ```

## 开发指南

### 代码规范
- 后端：遵循PEP 8，类型注解
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
# 使用Docker Compose
docker-compose up -d
```

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系我们

- 项目主页：[GitHub](https://github.com/your-repo/AuroraDocs)
- 问题反馈：[Issues](https://github.com/your-repo/AuroraDocs/issues)
- 邮箱：contact@auroradocs.com