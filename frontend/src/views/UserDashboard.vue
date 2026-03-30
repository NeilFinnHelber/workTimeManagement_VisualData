<script setup>
import { ref, computed, onMounted, watch } from 'vue';

// --- STATE ---
const projects = ref([]);
const selectedProjectId = ref(null);
const shiftParts = ref([]);

const project = computed(() =>
  projects.value.find(p => p.id === selectedProjectId.value)
);

// --- TIME ---
const currentTime = ref(new Date());
setInterval(() => currentTime.value = new Date(), 1000);

// --- FORM ---
const shiftPart = ref({
  issue_text: '',
  start_time: '',
  end_time: '',
  note: ''
});

// --- FETCH PROJECTS ---
async function fetchProjects() {
  try {
    const res = await fetch('http://localhost:3000/projects');
    const data = await res.json();
    projects.value = data;
  } catch (err) {
    console.error('Error fetching projects:', err);
  }
}

// --- FETCH SHIFT PARTS ---
async function fetchShiftParts() {
  if (!selectedProjectId.value) return;

  try {
    const res = await fetch(
      `http://localhost:3000/shift_parts?project_id=${selectedProjectId.value}`
    );

    const data = await res.json();
    shiftParts.value = data;
  } catch (err) {
    console.error('Error fetching shift parts:', err);
  }
}

// --- CREATE SHIFT PART ---
async function submitShiftPart() {
  if (!shiftPart.value.issue_text) return;

  try {
    const res = await fetch('http://localhost:3000/shift_parts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...shiftPart.value,
        project_id: selectedProjectId.value
      })
    });

    const data = await res.json();

    if (!res.ok) {
      throw new Error(data.message || 'Error creating shift part');
    }

    // reload list from backend
    await fetchShiftParts();

    // reset form
    shiftPart.value = {
      issue_text: '',
      start_time: '',
      end_time: '',
      note: ''
    };

  } catch (err) {
    console.error(err);
  }
}

// --- AUTO FILL ---
function fillNow() {
  const now = new Date().toISOString().slice(0, 16);
  shiftPart.value.start_time = now;
  shiftPart.value.end_time = now;
}

// --- TODAY FILTER ---
const todayShiftParts = computed(() => {
  const today = new Date().toDateString();

  return shiftParts.value
    .filter(p => new Date(p.start_time).toDateString() === today)
    .sort((a, b) => new Date(b.start_time) - new Date(a.start_time));
});

// --- WATCH PROJECT CHANGE ---
watch(selectedProjectId, () => {
  fetchShiftParts();
});

// --- INIT ---
onMounted(() => {
  fetchProjects();
});
</script>



<template>
  <div class="dashboard-wrapper">
    <header class="dashboard-header">
      <div class="time-display">
        <span class="dot"></span>
        {{ currentTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }}
      </div>
      
      <div class="project-selector">
        <span class="label">Project:</span>
        <div class="chip-group">
          <button
            v-for="p in projects"
            :key="p.id"
            :class="['chip', { active: selectedProjectId === p.id }]"
            @click="selectedProjectId = p.id"
          >
            {{ p.name }}
          </button>
        </div>
      </div>
    </header>

    <div v-if="!project" class="empty-state">
      <div class="icon">📁</div>
      <h2>No Project Selected</h2>
      <p>Please select a project from the top bar to begin logging time.</p>
    </div>

    <div v-else class="dashboard-grid">
      <section class="view-card">
        <div class="card-header">
          <h3>Log New Activity</h3>
          <button class="btn-ghost" @click="fillNow">Set to Now</button>
        </div>

        <div class="form-grid">
          <div class="form-group">
            <label>Issue / Task Name</label>
            <input v-model="shiftPart.issue_text" placeholder="What are you working on?" />
          </div>
          
          <div class="row">
            <div class="form-group">
              <label>Start Time</label>
              <input v-model="shiftPart.start_time" type="datetime-local" />
            </div>
            <div class="form-group">
              <label>End Time</label>
              <input v-model="shiftPart.end_time" type="datetime-local" />
            </div>
          </div>

          <div class="form-group">
            <label>Notes (Optional)</label>
            <input v-model="shiftPart.note" placeholder="Add additional details..." />
          </div>

          <button class="btn-primary btn-large" @click="submitShiftPart">
            Create Shift Entry
          </button>
        </div>
      </section>

      <section class="view-card">
        <div class="card-header">
          <h3>Today's History</h3>
          <span class="count-badge">{{ todayShiftParts.length }} entries</span>
        </div>

        <div class="shift-list">
          <div v-if="todayShiftParts.length === 0" class="empty-list">
            No activities recorded today.
          </div>

          <div v-for="(p, i) in todayShiftParts" :key="i" class="shift-card">
            <div class="shift-info">
              <span class="shift-title">{{ p.issue_text }}</span>
              <span class="shift-time">{{ new Date(p.start_time).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) }}</span>
            </div>
            <p v-if="p.note" class="shift-note">{{ p.note }}</p>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.dashboard-wrapper {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.time-display {
  font-size: 1.2rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.dot {
  width: 8px;
  height: 8px;
  background: #10b981;
  border-radius: 50%;
  box-shadow: 0 0 8px #10b981;
}

.project-selector {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.chip-group {
  display: flex;
  gap: 0.5rem;
}

.chip {
  background: var(--bg-card);
  border: 1px solid var(--border);
  color: var(--text-dim);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.2s;
}

.chip.active {
  background: var(--primary);
  border-color: var(--primary);
  color: white;
}

/* Grid Layout */
.dashboard-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}

@media (max-width: 900px) {
  .dashboard-grid { grid-template-columns: 1fr; }
}

.view-card {
  background: var(--bg-card);
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid var(--border);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.card-header h3 { margin: 0; }

.row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.btn-ghost {
  background: transparent;
  color: var(--primary);
  border: 1px solid var(--primary);
  padding: 0.4rem 0.8rem;
  border-radius: 6px;
  cursor: pointer;
}

/* List Styles */
.shift-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.shift-card {
  background: var(--bg-input);
  padding: 1rem;
  border-radius: 8px;
  border-left: 4px solid var(--primary);
}

.shift-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.4rem;
}

.shift-title { font-weight: 600; }
.shift-time { font-size: 0.85rem; color: var(--text-dim); }
.shift-note { font-size: 0.9rem; color: var(--text-dim); margin: 0; }

.count-badge {
  background: var(--bg-input);
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.8rem;
}

.empty-state {
  text-align: center;
  padding: 4rem;
  color: var(--text-dim);
}

.icon { font-size: 4rem; margin-bottom: 1rem; }
</style>