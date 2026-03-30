<template>
  <div class="container">
    <header class="dashboard-header">
      <div class="header-left">
        <h1>API Dashboard</h1>
        <p class="subtitle">Managing <strong>{{ entity }}</strong></p>
      </div>
      <div class="controls">
        <select v-model="entity" @change="fetchAll" class="entity-select">
          <option v-for="e in entities" :key="e" :value="e">{{ e.replace('_', ' ').toUpperCase() }}</option>
        </select>
        <button class="btn-add" @click="openCreateModal">
          <span class="icon">+</span> Create {{ entity.replace('_', ' ') }}
        </button>
      </div>
    </header>

    <div class="table-container">
      <table v-if="items.length">
        <thead>
          <tr>
            <th v-for="key in tableHeaders" :key="key">{{ key.replace('_', ' ') }}</th>
            <th class="text-right">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.id">
            <td v-for="key in tableHeaders" :key="key",  
              :class="{ clickable: entity === 'projects' }"
              @click="entity === 'projects' ? openProject(item) : null">
              <span v-if="key === 'completed'">{{ item[key] ? '✅ Yes' : '❌ No' }}</span>
              <span v-else>{{ item[key] }}</span>
            </td>
            <td class="text-right">
              <button class="btn-edit" @click="openUpdateModal(item)">Edit</button>
              <button class="btn-delete" @click="confirmDelete(item)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-else class="empty-state">
        <p>No data found for {{ entity.replace('_', ' ') }}.</p>
        <button @click="fetchAll" class="btn-secondary">Retry Fetch</button>
      </div>
    </div>

    <ModalForm
      :show="showModal"
      :title="modalTitle"
      :fields="activeFields"
      :formData="formData"
      :submitText="modalSubmitText"
      :disableId="true"
      @close="showModal = false"
      @submit="handleFormSubmit"
    />

    <div v-if="showDeleteModal" class="delete-confirm-overlay">
      <div class="delete-confirm-card">
        <h3>Are you sure?</h3>
        <p>You are about to delete an item from <strong>{{ entity }}</strong>. This cannot be undone.</p>
        <div class="delete-actions">
          <button @click="showDeleteModal = false" class="btn-secondary">Cancel</button>
          <button @click="executeDelete" class="btn-danger">Confirm Delete</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import ModalForm from "../components/Modal.vue";
import api from "../api";
// Added Router for navigation actions for projects
import { useRouter } from "vue-router";

const router = useRouter();

const entities = ["users", "projects", "time_table", "shift_parts", "charts"];
const entity = ref("users");
const items = ref([]);
const usersList = ref([]);
const projectsList = ref([]);

const showModal = ref(false);
const showDeleteModal = ref(false);
const modalTitle = ref("");
const modalSubmitText = ref("");
const formData = reactive({});
const itemToDelete = ref(null);

// Navigation function to open project details in UserDashboard
function openProject(project) {
  router.push({
    path: "/user-dashboard",
    query: { projectId: project.id }
  });
}

// 1. ALL CONFIGS DEFINED HERE
const configs = computed(() => ({
  users: {
    name: { label: "Name", type: "text" },
    email: { label: "Email", type: "text" },
    role: { label: "Role", type: "select", options: [{label: "Admin", value: "admin"}, {label: "User", value: "user"}] }
  },
  projects: {
    name: { label: "Project Name", type: "text" },
    description: { label: "Description", type: "textarea" },
    completed: { label: "Completed", type: "select", options: [{label: "Yes", value: true}, {label: "No", value: false}] }
  },
  time_table: {
    user_id: { label: "User", type: "select", options: usersList.value.map(u => ({ label: u.name || `User ${u.id}`, value: u.id })) },
    project_id: { label: "Project", type: "select", options: projectsList.value.map(p => ({ label: p.name || `Proj ${p.id}`, value: p.id })) },
    total_start_time: { label: "Start Time", type: "text" },
    total_end_time: { label: "End Time", type: "text" },
    note: { label: "Note", type: "textarea" }
  },
  shift_parts: {
    shift_id: { label: "Shift ID", type: "number" },
    issue_text: { label: "Issue", type: "text" },
    start_time: { label: "Start Time", type: "text" },
    end_time: { label: "End Time", type: "text" },
    note: { label: "Note", type: "textarea" }
  },
  charts: {
    name: { label: "Chart Name", type: "text" },
    type: { label: "Type", type: "select", options: [{label: "Bar", value: "bar"}, {label: "Line", value: "line"}] },
    metric: { label: "Metric", type: "select", options: [{label: "Hours", value: "total_hours"}, {label: "Count", value: "count"}] }
  }
}));

const activeFields = computed(() => configs.value[entity.value] || {});
const tableHeaders = computed(() => items.value.length ? Object.keys(items.value[0]) : []);

// 2. FETCH LOGIC
async function fetchAll() {
  try {
    const [resItems, resUsers, resProjects] = await Promise.all([
      api.get(`/${entity.value}`),
      api.get('/users'),
      api.get('/projects')
    ]);
    items.value = resItems.data;
    usersList.value = resUsers.data;
    projectsList.value = resProjects.data;
  } catch (err) {
    console.error("Fetch error:", err);
    items.value = [];
  }
}

// 3. MODAL LOGIC
function openCreateModal() {
  modalTitle.value = `New ${entity.value.replace('_', ' ')}`;
  modalSubmitText.value = "Create";
  
  // Clear the existing data
  for (let key in formData) delete formData[key];

  // Pre-fill with empty values based on current entity config
  const fields = configs.value[entity.value];
  if (fields) {
    Object.keys(fields).forEach(key => {
      formData[key] = ""; 
    });
  }
  
  showModal.value = true;
}

function openUpdateModal(item) {
  modalTitle.value = `Edit ${entity.value.replace('_', ' ')}`;
  modalSubmitText.value = "Update";
  Object.assign(formData, item);
  showModal.value = true;
}

async function handleFormSubmit(data) {
  try {
    if (modalSubmitText.value === "Create") {
      await api.post(`/${entity.value}`, data);
    } else {
      await api.put(`/${entity.value}/${data.id}`, data);
    }
    showModal.value = false;
    fetchAll();
  } catch (err) { alert("Action failed: Check console"); }
}

function confirmDelete(item) {
  itemToDelete.value = item;
  showDeleteModal.value = true;
}

async function executeDelete() {
  try {
    await api.delete(`/${entity.value}/${itemToDelete.value.id}`);
    showDeleteModal.value = false;
    fetchAll();
  } catch (err) { alert("Delete failed"); }
}

onMounted(fetchAll);
</script>

<style scoped>
/* Main Container - Responsive & Fluid */
.container { 
  width: 95%; 
  margin: 2rem auto; 
  padding: 0 20px;
  /* Allows the container to grow as wide as the table needs */
  display: inline-block; 
  min-width: 95%;
}

.table-container { 
  background: rgb(0, 0, 0); 
  border-radius: 12px; 
  border: 1px solid #e2e8f0; 
  box-shadow: 0 4px 20px rgba(0,0,0,0.05);
  /* This ensures the horizontal scroll only appears if the screen is tiny */
  overflow-x: auto; 
  width: 100%;
}

table { 
  width: 100%; 
  border-collapse: collapse;
  /* Prevents text from wrapping too aggressively */
  white-space: nowrap; 
}

th, td { 
  padding: 1rem 1.5rem; 
  text-align: left;
}

/* For columns with long notes/text, allow them to be wider */
td:nth-child(n) {
  max-width: 400px;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* DELETE CONFIRMATION (Matching the new theme) */
.delete-confirm-card { 
  background: #1e1b4b; 
  border: 1px solid #ef4444;
  padding: 2rem; 
  border-radius: 16px; 
  color: white;
  text-align: center; 
}

.btn-danger {
  background: #ef4444;
  color: white;
  border: none;
  padding: 0.7rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
}

.clickable {
  cursor: pointer;
}
</style>