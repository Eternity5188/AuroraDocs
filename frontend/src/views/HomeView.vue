<template>
  <div class="home-page">
    <section class="page-toolbar">
      <div>
        <h1>AuroraDocs</h1>
        <p>文档智能训练与任务管理平台，简洁、现代、适合企业级使用。</p>
      </div>
      <div class="header-badge">
        <span>v0.1.0</span>
      </div>
    </section>

    <div class="page-main">
      <el-row :gutter="24" class="overview-row">
        <el-col :xs="24" :md="16">
          <el-card class="overview-card" shadow="hover">
            <div class="overview-card-inner">
              <div>
                <h2>工作流</h2>
                <p>上传样例、配置 API、提交训练、查询状态。保持界面简明，重点操作一目了然。</p>
              </div>
              <div class="overview-pill">最新版</div>
            </div>
          </el-card>
        </el-col>
        <el-col :xs="24" :md="8">
          <el-card class="metric-card" shadow="hover">
            <div class="metric-title">当前任务</div>
            <div class="metric-value">{{ taskStatusLabel }}</div>
            <div class="metric-note">任务 ID：{{ taskId || '尚未提交' }}</div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="24">
        <el-col :xs="24" :lg="12">
          <el-card id="upload-section" class="panel-card" shadow="always">
            <div class="panel-header">
              <span>1. 上传样例</span>
              <span class="panel-tip">支持 PDF / DOCX / TXT / MD</span>
            </div>
            <el-upload
              ref="uploadRef"
              :before-upload="beforeUpload"
              :auto-upload="false"
              :file-list="fileList"
              :on-change="handleChange"
              drag
              class="upload-card"
            >
              <i class="el-icon-upload"></i>
              <div class="upload-text">拖拽文件到此处，或点击选择</div>
              <div class="upload-subtext">仅需一个样例即可快速开始</div>
            </el-upload>
            <el-button type="primary" :loading="uploadLoading" :disabled="!selectedFile" @click="uploadFile">上传样例</el-button>
            <div v-if="samplePath" class="note success">已上传：{{ samplePath }}</div>
          </el-card>

          <el-card id="api-section" class="panel-card" shadow="always" style="margin-top: 24px;">
            <div class="panel-header">
              <span>2. 配置 API</span>
              <span class="panel-tip">只保存本地，无后端泄露</span>
            </div>
            <el-form label-position="top" :model="apiConfig" label-width="110px">
              <el-form-item label="提供商">
                <el-select v-model="apiConfig.provider" placeholder="选择 API 提供商">
                  <el-option label="OpenAI" value="openai" />
                  <el-option label="Azure OpenAI" value="azure_openai" />
                  <el-option label="自定义 API" value="custom" />
                </el-select>
              </el-form-item>
              <el-form-item label="终端 URL">
                <el-input v-model="apiConfig.endpoint" :placeholder="endpointPlaceholder" />
              </el-form-item>
              <el-form-item label="API Key">
                <el-input v-model="apiConfig.api_key" placeholder="请输入 API Key" show-password />
              </el-form-item>
              <el-form-item>
                <el-checkbox v-model="apiConfig.save_local">保存到本地</el-checkbox>
              </el-form-item>
            </el-form>
          </el-card>
        </el-col>

        <el-col :xs="24" :lg="12">
          <el-card id="task-section" class="panel-card" shadow="always">
            <div class="panel-header">
              <span>3. 提交训练</span>
              <span class="panel-tip">预测时延取决于后端 GPU 状态</span>
            </div>
            <el-form ref="taskFormRef" label-position="top" :model="taskForm" :rules="taskFormRules" label-width="120px">
              <el-form-item label="模型名称" prop="model_name">
                <el-input v-model="taskForm.model_name" placeholder="例如 company-doc-v1" />
              </el-form-item>
              <el-form-item label="训练轮次" prop="epochs">
                <el-input-number v-model="taskForm.epochs" :min="1" style="width: 100%;" />
              </el-form-item>
              <el-form-item label="学习率" prop="learning_rate">
                <el-input-number v-model="taskForm.learning_rate" :min="0.00001" :step="0.0001" style="width: 100%;" />
              </el-form-item>
              <el-form-item label="Prompt 模板">
                <el-input type="textarea" v-model="taskForm.prompt_template" rows="4" placeholder="可选：训练提示模板" />
              </el-form-item>
              <el-button type="success" :loading="submitLoading" :disabled="!samplePath" @click="submitTask">提交训练</el-button>
            </el-form>
            <div class="note" style="margin-top: 14px;">提交后请复制任务 ID 用于查询。</div>
          </el-card>

          <el-card id="status-section" class="panel-card" shadow="always" style="margin-top: 24px;">
            <div class="panel-header">
              <span>4. 查询状态</span>
              <span class="panel-tip">实时读取任务执行结果</span>
            </div>
            <el-input v-model="taskId" placeholder="训练任务 ID" style="margin-bottom: 16px;" />
            <el-button type="primary" :loading="statusLoading" :disabled="!taskId" @click="checkStatus">查询状态</el-button>
            <el-alert v-if="taskStatus" :title="taskStatusLabel" :type="statusType" show-icon style="margin-top: 16px;" />
            <div v-if="taskMessage" class="note" style="margin-top: 12px;">{{ taskMessage }}</div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="24" class="secondary-row">
        <el-col :xs="24" :lg="12">
          <el-card id="history-section" class="panel-card" shadow="always">
            <div class="panel-header">
              <span>训练历史</span>
              <span class="panel-tip">最近 10 条提交记录</span>
            </div>
            <div class="history-list">
              <div v-if="history.length === 0" class="history-empty">暂无历史记录</div>
              <div v-for="entry in history" :key="entry.taskId" class="history-item">
                <div>
                  <div class="history-task">ID: {{ entry.taskId }}</div>
                  <div class="history-info">模型：{{ entry.modelName }} · 状态：{{ entry.status }} · {{ formatTime(entry.submittedAt) }}</div>
                </div>
                <el-button type="text" size="small" @click="restoreTask(entry.taskId)">恢复</el-button>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :xs="24" :lg="12">
          <el-card id="settings-section" class="panel-card" shadow="always">
            <div class="panel-header">
              <span>应用设置</span>
              <span class="panel-tip">持久化本地配置</span>
            </div>
            <el-form label-position="top" :model="settings" label-width="120px">
              <el-form-item label="自动保存 API 配置">
                <el-switch v-model="settings.saveApiConfig" />
              </el-form-item>
              <el-form-item label="主题模式">
                <el-select v-model="settings.theme" placeholder="选择主题">
                  <el-option label="浅色" value="light" />
                  <el-option label="深色" value="dark" />
                </el-select>
              </el-form-item>
              <el-form-item label="托盘最小化">
                <el-switch v-model="settings.minimizeToTray" />
              </el-form-item>
              <el-button type="primary" @click="saveSettings">保存设置</el-button>
            </el-form>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, reactive, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { uploadSample, createTrainingTask, getTaskStatus } from '../api/client'

const uploadRef = ref(null)
const fileList = ref([])
const selectedFile = ref(null)
const samplePath = ref('')
const taskId = ref('')
const taskStatus = ref('')
const taskMessage = ref('')
const uploadLoading = ref(false)
const submitLoading = ref(false)
const statusLoading = ref(false)
const history = ref([])

const settings = reactive({
  saveApiConfig: true,
  theme: 'light',
  minimizeToTray: true,
})

const taskForm = reactive({
  model_name: '',
  prompt_template: '',
  epochs: 1,
  learning_rate: 0.0002,
})

const apiConfig = reactive({
  provider: 'openai',
  endpoint: '',
  api_key: '',
  save_local: true,
})

const taskFormRules = {
  model_name: [
    { required: true, message: '请输入模型名称', trigger: 'blur' },
    { min: 3, message: '模型名称至少需要 3 个字符', trigger: 'blur' },
  ],
  learning_rate: [
    { type: 'number', required: true, message: '请输入学习率', trigger: 'change' },
  ],
}

const taskFormRef = ref(null)

const endpointPlaceholder = computed(() => {
  if (apiConfig.provider === 'azure_openai') {
    return '例如 https://<your-resource-name>.openai.azure.com/openai/deployments/<部署名>/chat/completions?api-version=2024-03-15-preview'
  }
  if (apiConfig.provider === 'custom') {
    return '请输入自定义 API 终端 URL，例如 https://custom-api.example.com/v1/chat/completions'
  }
  return '例如 https://api.openai.com/v1/chat/completions'
})

const statusType = computed(() => {
  if (!taskStatus.value) return 'info'
  if (taskStatus.value.toLowerCase() === 'completed') return 'success'
  if (taskStatus.value.toLowerCase() === 'failed') return 'error'
  return 'warning'
})

const taskStatusLabel = computed(() => {
  if (!taskStatus.value) return '未提交任务'
  return `当前状态：${taskStatus.value}`
})

function loadApiConfig() {
  try {
    const saved = localStorage.getItem('auroradocs_api_config')
    if (saved) {
      const parsed = JSON.parse(saved)
      apiConfig.provider = parsed.provider || 'openai'
      apiConfig.endpoint = parsed.endpoint || ''
      apiConfig.api_key = parsed.api_key || ''
      apiConfig.save_local = parsed.save_local ?? true
    }
  } catch (error) {
    console.warn('读取本地 API 配置失败', error)
  }
}

function saveApiConfig() {
  if (!apiConfig.save_local) {
    localStorage.removeItem('auroradocs_api_config')
    return
  }
  localStorage.setItem('auroradocs_api_config', JSON.stringify({
    provider: apiConfig.provider,
    endpoint: apiConfig.endpoint,
    api_key: apiConfig.api_key,
    save_local: apiConfig.save_local,
  }))
}

watch(apiConfig, saveApiConfig, { deep: true })
watch(settings, saveSettings, { deep: true })

function loadHistory() {
  try {
    const saved = localStorage.getItem('auroradocs_history')
    history.value = saved ? JSON.parse(saved) : []
  } catch (error) {
    console.warn('读取历史记录失败', error)
    history.value = []
  }
}

function saveHistory() {
  localStorage.setItem('auroradocs_history', JSON.stringify(history.value.slice(0, 10)))
}

function loadSettings() {
  try {
    const saved = localStorage.getItem('auroradocs_settings')
    if (saved) {
      const parsed = JSON.parse(saved)
      settings.saveApiConfig = parsed.saveApiConfig ?? true
      settings.theme = parsed.theme || 'light'
      settings.minimizeToTray = parsed.minimizeToTray ?? true
    }
  } catch (error) {
    console.warn('读取应用设置失败', error)
  }
}

function saveSettings() {
  localStorage.setItem('auroradocs_settings', JSON.stringify(settings))
  // 更新主进程设置
  if (window.electron?.settings?.setMinimizeToTray) {
    window.electron.settings.setMinimizeToTray(settings.minimizeToTray)
  }
  ElMessage.success('设置已保存')
}

function formatTime(value) {
  if (!value) return '--'
  return new Date(value).toLocaleString()
}

function restoreTask(taskIdToRestore) {
  const existing = history.value.find(item => item.taskId === taskIdToRestore)
  if (existing) {
    taskId.value = existing.taskId
    taskStatus.value = existing.status
    taskMessage.value = existing.note || '已恢复历史任务'
    ElMessage.success('已恢复历史任务')
  }
}

function loadAllData() {
  loadApiConfig()
  loadHistory()
  loadSettings()
  // 更新主进程设置
  if (window.electron?.settings?.setMinimizeToTray) {
    window.electron.settings.setMinimizeToTray(settings.minimizeToTray)
  }
}

onMounted(loadAllData)

function beforeUpload(file) {
  selectedFile.value = file
  return false
}

function handleChange(file) {
  selectedFile.value = file.raw || file
}

async function uploadFile() {
  if (!selectedFile.value) {
    return ElMessage.warning('请先选择要上传的样例文件')
  }
  uploadLoading.value = true
  try {
    const result = await uploadSample(selectedFile.value)
    samplePath.value = result.file_path
    ElMessage.success('样例上传成功')
  } catch (error) {
    ElMessage.error(error?.response?.data?.detail || '样例上传失败')
  } finally {
    uploadLoading.value = false
  }
}

async function submitTask() {
  if (!samplePath.value) {
    return ElMessage.warning('请先上传样例文件')
  }
  if (!apiConfig.endpoint || !apiConfig.api_key) {
    return ElMessage.warning('请先配置并保存 API 选项')
  }

  taskFormRef.value?.validate(async valid => {
    if (!valid) {
      return
    }
    submitLoading.value = true
    try {
      const payload = {
        model_name: taskForm.model_name,
        sample_paths: [samplePath.value],
        prompt_template: taskForm.prompt_template,
        epochs: taskForm.epochs,
        learning_rate: taskForm.learning_rate,
        api_config: {
          provider: apiConfig.provider,
          endpoint: apiConfig.endpoint,
          api_key: apiConfig.api_key,
        },
      }
      const result = await createTrainingTask(payload)
      taskId.value = result.task_id
      taskStatus.value = result.status
      taskMessage.value = '训练任务已提交'
      history.value.unshift({
        taskId: result.task_id,
        modelName: taskForm.model_name || '未命名模型',
        status: result.status,
        submittedAt: new Date().toISOString(),
        note: '任务提交成功',
      })
      saveHistory()
      ElMessage.success('训练任务提交成功')
    } catch (error) {
      ElMessage.error(error?.response?.data?.detail || '训练任务提交失败')
    } finally {
      submitLoading.value = false
    }
  })
}

async function checkStatus() {
  if (!taskId.value) {
    return ElMessage.warning('请输入训练任务 ID')
  }
  statusLoading.value = true
  try {
    const result = await getTaskStatus(taskId.value)
    taskStatus.value = result.status
    taskMessage.value = result.message || '无附加信息'
  } catch (error) {
    ElMessage.error(error?.response?.data?.detail || '查询任务状态失败')
  } finally {
    statusLoading.value = false
  }
}
</script>

<style scoped>
.home-page {
  min-height: 100%;
  display: flex;
  flex-direction: column;
  gap: 22px;
}

.page-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 18px;
  padding: 24px 0;
}

.page-toolbar h1 {
  margin: 0;
  font-size: 30px;
  color: #1f3c88;
}

.page-toolbar p {
  margin: 10px 0 0;
  color: #5f6d92;
  font-size: 14px;
  max-width: 620px;
}

.header-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 8px 18px;
  border-radius: 999px;
  background: #eef2ff;
  color: #3b5cda;
  font-weight: 700;
}

.page-main {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.overview-row {
  margin-bottom: 0;
}

.overview-card,
.metric-card,
.panel-card {
  border-radius: 22px;
}

.overview-card {
  padding: 26px;
  background: linear-gradient(135deg, #ffffff 0%, #f4f7ff 100%);
}

.overview-card-inner {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
}

.overview-card h2 {
  margin: 0 0 12px;
  color: #1f3c88;
}

.overview-card p {
  margin: 0;
  color: #667294;
  line-height: 1.8;
}

.overview-pill {
  background: #eef2ff;
  color: #3c5cd8;
  padding: 9px 16px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 700;
}

.metric-card {
  min-height: 176px;
  padding: 24px;
}

.metric-title {
  margin: 0 0 12px;
  color: #7d8aab;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.metric-value {
  font-size: 26px;
  font-weight: 700;
  color: #1f3c88;
}

.metric-note {
  margin-top: 10px;
  color: #687291;
  font-size: 13px;
}

.panel-card {
  padding: 24px;
  background: #ffffff;
  box-shadow: 0 20px 50px rgba(31, 47, 98, 0.08);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  gap: 16px;
}

.panel-header span {
  font-size: 16px;
  font-weight: 700;
  color: #1f3c88;
}

.panel-tip {
  color: #667294;
  font-size: 13px;
}

.upload-card {
  min-height: 180px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  border: 1px dashed rgba(64, 158, 255, 0.25);
  border-radius: 18px;
  margin-bottom: 18px;
  background: #f8fbff;
}

.upload-card .el-icon-upload {
  font-size: 32px;
  color: #3b6de0;
  margin-bottom: 12px;
}

.upload-text {
  font-weight: 700;
  color: #1f3c88;
  margin-bottom: 8px;
}

.upload-subtext {
  color: #7a86a2;
}

.note {
  margin-top: 16px;
  color: #5f6e8d;
  font-size: 13px;
}

.note.success {
  color: #409eff;
}

.secondary-row {
  margin-top: 20px;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-empty {
  color: #7a86a2;
  font-size: 14px;
  padding: 18px 0;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-radius: 16px;
  background: #f8fbff;
  border: 1px solid rgba(59, 109, 224, 0.12);
}

.history-task {
  font-weight: 700;
  color: #1f3c88;
}

.history-info {
  margin-top: 6px;
  color: #5f6f92;
  font-size: 13px;
}
</style>
