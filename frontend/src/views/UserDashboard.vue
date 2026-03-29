<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const projectId = computed(() => route.query.projectId);

// --- STATE ---
const project = ref(null);
const loading = ref(false);

// Shift part form
const shiftPart = ref({
  shift_id: '',
  issue_text: '',
  start_time: '',
  end_time: '',
  note: ''
});

const successMessage = ref('');
const errorMessage = ref('');

// --- FETCH PROJECT ---
async function fetchProject() {
  if (!projectId.value) {
    project.value = null;
    return;
  }

  loading.value = true;

  try {
    const res = await fetch(`http://localhost:3000/projects/${projectId.value}`);
    const data = await res.json();

    project.value = data;
  } catch (err) {
    console.error(err);
  } finally {
    loading.value = false;
  }
}

// --- SUBMIT SHIFT PART ---
async function submitShiftPart() {
  errorMessage.value = '';
  successMessage.value = '';

  try {
    const res = await fetch('http://localhost:3000/shift_parts', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(shiftPart.value)
    });

    const data = await res.json();

    if (!res.ok) {
      throw new Error(data.message || 'Error');
    }

    successMessage.value = 'Shift part created successfully';

    // reset form
    shiftPart.value = {
      shift_id: '',
      issue_text: '',
      start_time: '',
      end_time: '',
      note: ''
    };

  } catch (err) {
    errorMessage.value = err.message;
  }
}

// --- WATCH PROJECT CHANGE ---
watch(projectId, () => {
  fetchProject();
});

// initial load
onMounted(() => {
  fetchProject();
});
</script>

<template>
  <div class="page">

    <h1>User Dashboard</h1>

    <!-- EMPTY STATE -->
    <div v-if="!projectId" class="empty">
      <p>Please select a project from the sidebar.</p>
    </div>

    <!-- LOADING -->
    <div v-else-if="loading">
      <p>Loading project...</p>
    </div>

    <!-- PROJECT VIEW -->
    <div v-else-if="project" class="project">

      <section class="card">
        <h2>Project Details</h2>
        <p><strong>Name:</strong> {{ project.name }}</p>
        <p><strong>Description:</strong> {{ project.description }}</p>
        <p><strong>Completed:</strong> {{ project.completed ? 'Yes' : 'No' }}</p>
      </section>

      <section class="card">
        <h2>Create Shift Part</h2>

        <div class="form">
          <input v-model="shiftPart.shift_id" placeholder="Shift ID (time_table.id)" />
          <input v-model="shiftPart.issue_text" placeholder="Issue text" />
          <input v-model="shiftPart.start_time" type="datetime-local" />
          <input v-model="shiftPart.end_time" type="datetime-local" />
          <input v-model="shiftPart.note" placeholder="Note" />

          <button @click="submitShiftPart">Submit</button>

          <p v-if="successMessage" class="success">{{ successMessage }}</p>
          <p v-if="errorMessage" class="error">{{ errorMessage }}</p>
        </div>
      </section>

    </div>

  </div>
</template>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

h1 {
  margin: 0;
}

.empty {
  padding: 2rem;
  background: #0f172a;
  border: 1px dashed #1e293b;
  border-radius: 10px;
  color: #94a3b8;
}

.card {
  background: #0f172a;
  border: 1px solid #1e293b;
  border-radius: 10px;
  padding: 1.5rem;
  margin-top: 20px;
}

.card h2 {
  margin-top: 0;
}

.form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

input {
  padding: 0.5rem;
  border-radius: 6px;
  border: 1px solid #1e293b;
  background: #020617;
  color: white;
}

button {
  padding: 0.6rem;
  background: #3b82f6;
  border: none;
  border-radius: 6px;
  color: white;
  cursor: pointer;
}

button:hover {
  background: #2563eb;
}

.success {
  color: #22c55e;
}

.error {
  color: #ef4444;
}
</style>