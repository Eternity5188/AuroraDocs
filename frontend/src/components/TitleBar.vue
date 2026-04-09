<template>
  <div class="titlebar">
    <div class="titlebar-left">
      <div class="app-badge">A</div>
      <div class="titlebar-info">
        <div class="titlebar-name">AuroraDocs</div>
        <div class="titlebar-subtitle">文档训练与任务管理</div>
      </div>
    </div>
    <div class="titlebar-actions">
      <button class="control-button" @click="minimize">—</button>
      <button class="control-button" @click="toggleMaximize">{{ isMaximized ? '❐' : '□' }}</button>
      <button class="control-button close" @click="close">×</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const isMaximized = ref(false)

function minimize() {
  window.electron?.control?.minimize?.()
}

async function toggleMaximize() {
  await window.electron?.control?.maximize?.()
  isMaximized.value = !isMaximized.value
}

function close() {
  window.electron?.control?.close?.()
}

onMounted(async () => {
  if (window.electron?.control?.isMaximized) {
    isMaximized.value = await window.electron.control.isMaximized()
  }
})
</script>

<style scoped>
.titlebar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 48px;
  padding: 0 16px;
  background: linear-gradient(90deg, #ffffff 0%, #eef4ff 100%);
  border-bottom: 1px solid rgba(30, 50, 105, 0.08);
  -webkit-app-region: drag;
}

.titlebar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.app-badge {
  width: 34px;
  height: 34px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
  background: #3b6de0;
  color: #fff;
  font-weight: 700;
  font-size: 16px;
}

.titlebar-info {
  display: flex;
  flex-direction: column;
}

.titlebar-name {
  font-size: 14px;
  font-weight: 700;
  color: #1f3c88;
}

.titlebar-subtitle {
  font-size: 12px;
  color: #637096;
}

.titlebar-actions {
  display: flex;
  gap: 4px;
}

.control-button {
  width: 42px;
  height: 30px;
  border: none;
  background: transparent;
  color: #4f5f8a;
  font-size: 14px;
  cursor: pointer;
  -webkit-app-region: no-drag;
  transition: background 0.2s ease;
}

.control-button:hover {
  background: rgba(59, 109, 224, 0.12);
}

.control-button.close:hover {
  background: rgba(232, 82, 82, 0.16);
  color: #d43f3a;
}
</style>
