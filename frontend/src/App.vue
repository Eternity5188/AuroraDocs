<template>
  <div id="app">
    <TitleBar />
    <div class="app-frame">
      <Sidebar />
      <main class="app-body">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import TitleBar from './components/TitleBar.vue'
import Sidebar from './components/Sidebar.vue'
</script>

<style>
:root {
  color-scheme: light;
  font-family: Inter, "Segoe UI", "Helvetica Neue", Arial, sans-serif;
  background: #eef2ff;
}

body {
  margin: 0;
  background: #eef2ff;
}

#app {
  min-height: 100vh;
}

.app-frame {
  display: flex;
  min-height: calc(100vh - 48px);
  background: #eef2ff;
}

.app-body {
  flex: 1;
  padding: 24px 30px;
  overflow: auto;
}
</style>
