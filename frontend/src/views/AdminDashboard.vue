<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import ModalForm from '../components/Modal.vue';
import api from '../api';

const entities = ['users', 'projects'];
const entity = ref('users');
const items = ref([]);

const showModal = ref(false);
const modalTitle = ref('');
const modalSubmitText = ref('');
const formData = reactive({});
const itemToDelete = ref(null);
const showDeleteModal = ref(false);

// Modal form configs
const configs = {
  users: {
  name: { label: 'Name', type: 'text' },
  email: { label: 'Email', type: 'text' },
  password: { label: 'Password', type: 'password' }, // <-- new
  company_role: { label: 'Company Role', type: 'text' },
  editor_permission: {
    label: 'Editor Permission',
    type: 'select',
    options: [
      { label: 'User', value: 'user' },
      { label: 'Admin', value: 'admin' }
    ]
  }
},
  projects: {
    name: { label: 'Project Name', type: 'text' },
    description: { label: 'Description', type: 'textarea' },
    completed: {
      label: 'Completed',
      type: 'select',
      options: [
        { label: 'Yes', value: true },
        { label: 'No', value: false }
      ]
    }
  }
};

// Fetch data
async function fetchAll() {
  try {
    const res = await api.get(`/${entity.value}`);
    items.value = res.data;
  } catch (err) {
    console.error(err);
    items.value = [];
  }
}

// Create / Edit
function openCreateModal() {
  modalTitle.value = `New ${entity.value}`;
  modalSubmitText.value = 'Create';
  Object.keys(formData).forEach(key => delete formData[key]);
  Object.keys(configs[entity.value]).forEach(key => (formData[key] = ''));
  showModal.value = true;
}

function openUpdateModal(item) {
  modalTitle.value = `Edit ${entity.value}`;
  modalSubmitText.value = 'Update';
  Object.assign(formData, item);
  formData.password = ''; // clear password so it's optional
  showModal.value = true;
}

async function handleFormSubmit(data) {
  try {
    if (modalSubmitText.value === 'Create') {
      await api.post(`/${entity.value}`, data);
    } else {
      await api.put(`/${entity.value}/${data.id}`, data);
    }
    showModal.value = false;
    fetchAll();
  } catch (err) {
    alert('Action failed. Check console.');
    console.error(err);
  }
}

// Delete
function confirmDelete(item) {
  itemToDelete.value = item;
  showDeleteModal.value = true;
}

async function executeDelete() {
  try {
    await api.delete(`/${entity.value}/${itemToDelete.value.id}`);
    showDeleteModal.value = false;
    fetchAll();
  } catch (err) {
    alert('Delete failed');
  }
}

onMounted(fetchAll);
</script>

<template>
  <div class="admin-dashboard">
    <header>
      <h2>Admin Dashboard</h2>
      <select v-model="entity" @change="fetchAll">
        <option v-for="e in entities" :key="e" :value="e">
          {{ e.toUpperCase() }}
        </option>
      </select>
      <button @click="openCreateModal">+ Create {{ entity }}</button>
    </header>

    <table v-if="items.length">
      <thead>
        <tr>
          <th v-for="key in Object.keys(items[0])" :key="key">{{ key }}</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in items" :key="item.id">
          <td v-for="key in Object.keys(item)" :key="key">{{ item[key] }}</td>
          <td>
            <button @click="openUpdateModal(item)">Edit</button>
            <button @click="confirmDelete(item)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-else>No data found.</div>

    <ModalForm
      :show="showModal"
      :title="modalTitle"
      :fields="configs[entity]"
      :formData="formData"
      :submitText="modalSubmitText"
      :disableId="true"
      @close="showModal = false"
      @submit="handleFormSubmit"
    />

    <div v-if="showDeleteModal" class="delete-confirm-overlay">
      <div class="delete-confirm-card">
        <h3>Are you sure?</h3>
        <button @click="showDeleteModal = false">Cancel</button>
        <button @click="executeDelete">Confirm Delete</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-dashboard { padding: 2rem; }
header { display: flex; gap: 1rem; align-items: center; margin-bottom: 1rem; }
table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
th, td { padding: 0.75rem; border: 1px solid #ccc; }
button { cursor: pointer; }
.delete-confirm-overlay { position: fixed; inset:0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; }
.delete-confirm-card { background: #1c1f26; color: white; padding: 2rem; border-radius: 12px; }
</style>