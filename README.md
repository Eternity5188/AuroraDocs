# AuroraDocs

<div align="center">

![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)
![Python](https://img.shields.io/badge/python-3.9%2B-blue.svg)
![Node.js](https://img.shields.io/badge/node.js-16%2B-brightgreen.svg)
![Status](https://img.shields.io/badge/status-active-success.svg)

**Intelligence-Driven Document Generation Platform**  
*Powered by LoRA-Fine-tuned Large Language Models*

[Features](#-features) • [Quick Start](#-quick-start) • [Requirements](#-requirements) • [License](#-license)

</div>

---

## 📖 About

**AuroraDocs** is an intelligent document generation platform that combines cutting-edge AI with user-friendly design. Instead of wrestling with complex deployment steps, simply run a startup script and start generating high-quality documents.

This project demonstrates how powerful ML systems can be wrapped in a seamless, production-ready package that works out of the box.

---

## ✨ Features

- 🧠 **AI-Powered Generation** – Generate documents, code, and diagrams using fine-tuned LLMs
- 🎯 **Personalized Training** – LoRA fine-tuning on your own examples  
- 🚀 **Zero-Config Setup** – Clone, run, done. No configuration needed
- 🔄 **Real-time Collaboration** – Built-in version control and templates
- 🛡️ **Privacy First** – Local storage, edge deployment ready
- 📦 **Production Ready** – Enterprise-grade reliability out of the box

---

## 📋 Requirements

| Component | Requirement | Optional |
|-----------|-------------|----------|
| **Python** | 3.9+ | ❌ |
| **Node.js** | 16+ | ❌ |
| **PostgreSQL** | 12+ | ✅ (SQLite default) |
| **Redis** | 6+ | ✅ (Task queue) |
| **GPU** | NVIDIA CUDA 11.8+ | ✅ (Model training) |

---

## 🚀 Quick Start

> **Platform Note:** Choose the correct startup command for your OS:
> - **Linux / macOS**: Use `bash run.sh`
> - **Windows**: Use `run.bat`

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Eternity5188/AuroraDocs.git
cd AuroraDocs
```

### 2️⃣ Start Backend

```bash
cd backend

# Linux / macOS
bash run.sh

# Windows
run.bat
```

✅ Backend runs on `http://localhost:8000`  
📖 API Docs: `http://localhost:8000/docs`

### 3️⃣ Start Frontend (New Terminal)

```bash
cd frontend

# Linux / macOS
bash run.sh

# Windows
run.bat
```

✅ Frontend runs on `http://localhost:5173`

---

## 🎯 How It Works

The scripts automate everything:

```
run.sh/run.bat
    ↓
├─ Detect Python/Node.js
├─ Create virtual environment
├─ Install dependencies silently
├─ Generate .env automatically
├─ Create data directories
└─ Start service
```

**Users don't need to know about:**
- Environment variables
- Virtual environments  
- Dependency management
- Configuration files

---

## 🏗️ Architecture

```
AuroraDocs/
├── backend/              # FastAPI + AI Engine
│   ├── app/
│   │   ├── api/         # REST endpoints
│   │   ├── core/        # Business logic
│   │   ├── models/      # Database schemas
│   │   └── services/    # AI services
│   ├── run.sh / run.bat # One-click startup
│   └── requirements.txt
│
├── frontend/             # Vue 3 + Electron
│   ├── src/
│   │   ├── api/         # API client
│   │   ├── components/  # UI components
│   │   ├── stores/      # State management
│   │   └── views/       # Pages
│   ├── run.sh / run.bat # One-click startup
│   └── package.json
│
└── README.md            # This file
```

---

## 🛠️ Technology Stack

| Layer | Technologies |
|-------|--------------|
| **Backend** | FastAPI, SQLAlchemy, Celery, Uvicorn |
| **AI/ML** | PyTorch, Transformers, LoRA, vLLM |
| **Frontend** | Vue 3, TypeScript, Vite, Electron |
| **Database** | PostgreSQL, SQLite, Redis |
| **Storage** | MinIO, Local filesystem |

---

## 📊 Project Status

- ✅ Core features implemented
- ✅ Production-ready
- ✅ Zero-config deployment
- 🚧 Web-based UI improvements in progress
- 📋 Enterprise features coming soon

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

For substantial changes, please open an issue first to discuss what you would like to change.

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

---

## 👤 Author

**AuroraDocs** is maintained by the community.

For questions, open an issue on [GitHub](https://github.com/Eternity5188/AuroraDocs/issues).

---

## 🎓 Learn More

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Vue 3 Guide](https://vuejs.org/)
- [LoRA Paper](https://arxiv.org/abs/2106.09685)
- [vLLM Documentation](https://docs.vllm.ai/)

---

<div align="center">

Made with ❤️ by the AuroraDocs community

</div>
