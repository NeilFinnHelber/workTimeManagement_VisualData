<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import ModalView from "./views/ModalView.vue";

const sidebarWidth = ref(450);
let isResizing = false;

function startResize() {
  isResizing = true;
  document.body.style.userSelect = 'none';
}

function onMouseMove(e) {
  if (!isResizing) return;

  const sidebar = document.querySelector('.sidebar');
  if (!sidebar) return;

  const sidebarLeft = sidebar.getBoundingClientRect().left;

  const newWidth = Math.max(
    250,
    Math.min(800, e.clientX - sidebarLeft)
  );

  sidebarWidth.value = newWidth;
}

function stopResize() {
  if (isResizing) {
    isResizing = false;
    document.body.style.userSelect = '';
  }
}

onMounted(() => {
  window.addEventListener('mousemove', onMouseMove);
  window.addEventListener('mouseup', stopResize);
});

onUnmounted(() => {
  window.removeEventListener('mousemove', onMouseMove);
  window.removeEventListener('mouseup', stopResize);
});
</script>

<template>
  <div id="app-root">
    
    <!-- HEADER -->
    <header class="main-header">
      <div class="logo">VISUAL<span>DATA</span></div>
      <nav class="main-nav">
        <router-link to="/">Overview</router-link>
        <router-link to="/user-dashboard">User Dashboard</router-link>
      </nav>
    </header>

    <!-- MAIN LAYOUT -->
    <div class="layout">
      
      <aside 
        class="sidebar" 
        :style="{ width: sidebarWidth + 'px' }"
      >
        <div class="sidebar-label">Control Panel</div>

        <ModalView />

        <!-- RESIZER HANDLE -->
        <div class="resizer" @mousedown="startResize"></div>
      </aside>

      <main class="content-area">
        <router-view />
      </main>

    </div>

  </div>
</template>

<style>
* {
  box-sizing: border-box;
}

html, body {
  margin: 0;
  padding: 0;
  height: 100%;
}

body {
  background: #020617;
  color: #f8fafc;
  font-family: 'Inter', -apple-system, sans-serif;
  overflow: hidden;
}

/* ROOT */
#app-root {
  height: 100vh;
  width: 100vw;
  display: flex;
  flex-direction: column;
}

/* HEADER */
.main-header {
  height: 64px;
  flex-shrink: 0;
  width: 100%;

  display: flex;
  align-items: center;
  justify-content: space-between;

  padding: 0 2rem;

  background: #0f172a;
  border-bottom: 1px solid #1e293b;
}

/* LAYOUT */
.layout {
  flex: 1;
  display: flex;
  overflow: hidden;
}

/* SIDEBAR */
.sidebar {
  position: relative;
  display: flex;
  flex-direction: column;
  overflow-y: auto;

  scrollbar-gutter: stable;
}

/* RESIZER */
.resizer {
  position: absolute;
  top: 0;
  right: 0;

  width: 5px;
  height: 100%;

  cursor: col-resize;
  background: transparent;
}

.resizer:hover {
  background: rgba(59, 130, 246, 0.3);
}

/* SIDEBAR LABEL */
.sidebar-label {
  padding: 1rem;

  font-size: 0.75rem;
  font-weight: 700;
  color: #64748b;

  text-transform: uppercase;
  letter-spacing: 0.05em;

  background: #0f172a;

  position: sticky;
  top: 0;
  z-index: 5;
}

/* CONTENT AREA */
.content-area {
  flex: 1;
  min-width: 0;

  background: #020617;

  padding: 4rem;
  overflow-y: auto;
}

/* NAV */
.logo {
  font-weight: 800;
  font-size: 1.25rem;
  color: #3b82f6;
}

.logo span {
  color: #fff;
}

.main-nav {
  display: flex;
  gap: 1.5rem;
}

.main-nav a {
  color: #94a3b8;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.9rem;

  padding: 0.5rem 0.75rem;
  border-radius: 6px;

  transition: all 0.2s;
}

.main-nav a:hover {
  color: #fff;
  background: #1e293b;
}

.main-nav a.router-link-active {
  color: #3b82f6;
  background: rgba(59, 130, 246, 0.1);
}
</style>