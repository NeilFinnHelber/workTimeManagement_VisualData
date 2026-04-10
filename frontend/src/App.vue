<script setup>
import { ref } from 'vue';
import UserDashboard from './views/UserDashboard.vue';
import AnalyticsView from './views/AnalyticsView.vue';
import AdminDashboard from './views/AdminDashboard.vue';

const user = ref(null);
const usernameInput = ref('');
const activeTab = ref('dashboard');
const errorMessage = ref('');
const loading = ref(false);
const timeRange = ref('today'); // today | week | month | year
const showErrorPopup = ref(false);
const popupMessage = ref('');

// Show error popup
function showError(msg) {
  popupMessage.value = msg;
  showErrorPopup.value = true;
  setTimeout(() => {
    showErrorPopup.value = false;
  }, 3000);
}

// Login with backend
async function login() {
  if (!usernameInput.value) return;

  errorMessage.value = '';
  loading.value = true;

  try {
    const inputName = usernameInput.value.toLowerCase();
    const res = await fetch('http://localhost:3000/users');
    if (!res.ok) throw new Error('Server error');

    const users = await res.json();
    const foundUser = users.find(u => u.name.toLowerCase() === inputName);

    if (!foundUser) throw new Error('User not found');

    user.value = {
  id: foundUser.id,
  name: foundUser.name,
  company_role: foundUser.company_role,
  editor_permission: foundUser.editor_permission,
};
  } catch (err) {
    showError(err.message);
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div id="app-root">
    <!-- Error Popup -->
    <div v-if="showErrorPopup" class="error-popup">
      {{ popupMessage }}
    </div>

    <!-- Login Screen -->
    <div v-if="!user" class="login-container">
      <div class="login-card">
        <h1>Welcome Back</h1>
        <p>Please sign in to your account</p>
        <div class="form-group">
          <label>Username</label>
          <input
            v-model="usernameInput"
            placeholder="Enter your name..."
            @keyup.enter="login"
          />
        </div>
        <button class="btn-primary btn-large" @click="login">Sign In</button>
      </div>
    </div>

    <!-- Main App Layout -->
    <div v-else class="app-layout">
      <aside class="sidebar">
        <div class="user-profile">
          <div class="avatar">{{ user.name[0].toUpperCase() }}</div>
          <span>{{ user.name }} ({{ user.company_role }})</span>
        </div>

        <nav class="nav-links">
          <!-- Admin Mode Button -->  
<button
  v-if="user.editor_permission === 'admin'"
  :class="['nav-item', { active: activeTab === 'admin' }]"
  @click="activeTab = 'admin'"
>
  🛠 Admin Mode
</button>

          <button
            :class="['nav-item', { active: activeTab === 'dashboard' }]"
            @click="activeTab = 'dashboard'"
          >
            📊 Dashboard
          </button>
          <button
            :class="['nav-item', { active: activeTab === 'charts' }]"
            @click="activeTab = 'charts'"
          >
            📈 Analytics
          </button>
        </nav>
      </aside>

      <main class="main-content">
        <UserDashboard v-if="activeTab === 'dashboard'" :user="user" />
        <AdminDashboard v-else-if="activeTab === 'admin'" />
        <AnalyticsView v-else />
      </main>
    </div>
  </div>
</template>

<style>
:root {
  --bg-dark: #0f1115;
  --bg-card: #1c1f26;
  --bg-input: #2a2f36;
  --primary: #3b82f6;
  --primary-hover: #2563eb;
  --text-main: #f3f4f6;
  --text-dim: #9ca3af;
  --border: #374151;
}

body {
  margin: 0;
  background: var(--bg-dark);
  color: var(--text-main);
  font-family: 'Inter', system-ui, sans-serif;
}

/* Auth Styles */
.login-container {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.login-card {
  background: var(--bg-card);
  padding: 2.5rem;
  border-radius: 16px;
  width: 100%;
  max-width: 400px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3);
  text-align: center;
}

/* Sidebar & Nav */
.app-layout {
  display: flex;
  height: 100vh;
}

.sidebar {
  width: 240px;
  background: var(--bg-card);
  border-right: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--border);
}

.avatar {
  width: 32px;
  height: 32px;
  background: var(--primary);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.nav-links {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.nav-item {
  text-align: left;
  background: transparent;
  border: none;
  color: var(--text-dim);
  padding: 0.8rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.nav-item:hover {
  background: var(--bg-input);
  color: white;
}

.nav-item.active {
  background: var(--primary);
  color: white;
}

/* Main Content */
.main-content {
  flex: 1;
  padding: 2rem;
  overflow-y: auto;
}

/* Buttons */
.btn-primary {
  background: var(--primary);
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-primary:hover {
  background: var(--primary-hover);
}

.btn-large {
  width: 100%;
  padding: 1rem;
  font-size: 1rem;
}

/* Form */
.form-group {
  text-align: left;
  margin-bottom: 1.5rem;
}

label {
  display: block;
  font-size: 0.85rem;
  color: var(--text-dim);
  margin-bottom: 0.5rem;
}

input {
  width: 100%;
  box-sizing: border-box;
  padding: 0.8rem;
  background: var(--bg-input);
  border: 1px solid var(--border);
  border-radius: 8px;
  color: white;
  outline: none;
}

input:focus {
  border-color: var(--primary);
}

/* Error Popup */
.error-popup {
  position: fixed;
  top: 20px;
  right: 20px;
  background: #ef4444;
  color: white;
  padding: 0.75rem 1.2rem;
  border-radius: 8px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.3);
  font-weight: 500;
  z-index: 999;
  animation: fadeIn 0.2s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>