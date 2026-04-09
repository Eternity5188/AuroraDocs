<template>
  <div class="sidebar-shell">
    <div class="sidebar-brand">AuroraDocs</div>
    <div class="sidebar-group">
      <div class="sidebar-title">操作指南</div>
      <button class="sidebar-item" @click="scrollTo('upload-section')">上传样例</button>
      <button class="sidebar-item" @click="scrollTo('api-section')">配置 API</button>
      <button class="sidebar-item" @click="scrollTo('task-section')">提交训练</button>
      <button class="sidebar-item" @click="scrollTo('status-section')">查询状态</button>
      <button class="sidebar-item" @click="scrollTo('history-section')">训练历史</button>
      <button class="sidebar-item" @click="scrollTo('settings-section')">应用设置</button>
    </div>
    <div class="sidebar-footer">
      <div class="footer-label">版本</div>
      <div class="footer-value">0.1.0</div>
    </div>
  </div>
</template>

<script setup>
function scrollTo(id) {
  const element = document.getElementById(id)
  if (element) {
    element.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}
</script>

<style scoped>
.sidebar-shell {
  width: 240px;
  padding: 24px 18px;
  background: #ffffff;
  border-right: 1px solid rgba(31, 48, 102, 0.08);
  min-height: calc(100vh - 48px);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.sidebar-brand {
  font-size: 20px;
  font-weight: 700;
  color: #1f3c88;
  margin-bottom: 24px;
}

.sidebar-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.sidebar-title {
  font-size: 12px;
  color: #7b86a6;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  margin-bottom: 10px;
}

.sidebar-item {
  display: block;
  width: 100%;
  padding: 12px 16px;
  text-align: left;
  border: none;
  border-radius: 14px;
  background: #f4f7ff;
  color: #233165;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s ease, transform 0.2s ease;
}

.sidebar-item:hover {
  background: #e8efff;
  transform: translateX(2px);
}

.sidebar-footer {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid rgba(31, 48, 102, 0.08);
}

.footer-label {
  font-size: 12px;
  color: #7b86a6;
  margin-bottom: 6px;
}

.footer-value {
  color: #1f3c88;
  font-weight: 700;
}
</style>
