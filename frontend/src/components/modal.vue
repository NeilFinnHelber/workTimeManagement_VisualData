<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="show" class="modal-overlay" @click.self="$emit('close')">
        <Transition name="pop">
          <div v-if="show" class="modal-content">
            
            <div class="modal-header">
              <h2>{{ title }}</h2>
              <button class="close-btn" @click="$emit('close')">&times;</button>
            </div>

            <form @submit.prevent="handleSubmit" class="modal-body">
              <div v-for="(field, key) in fields" :key="key" class="form-group">
                <label>{{ field.label }}</label>

                <input
                  v-if="field.type === 'text' || field.type === 'number'"
                  :type="field.type"
                  v-model="localData[key]"
                  :disabled="key === 'id' && disableId"
                  :placeholder="'Enter ' + field.label.toLowerCase()"
                />

                <textarea
                  v-else-if="field.type === 'textarea'"
                  v-model="localData[key]"
                  rows="3"
                ></textarea>

                <select v-else-if="field.type === 'select'" v-model="localData[key]">
                  <option value="" disabled selected>Select an option</option>
                  <option v-for="opt in field.options" :key="opt.value" :value="opt.value">
                    {{ opt.label }}
                  </option>
                </select>
              </div>

              <div class="modal-footer">
                <button type="button" class="btn-secondary" @click="$emit('close')">Cancel</button>
                <button type="submit" class="btn-primary">{{ submitText }}</button>
              </div>
            </form>
          </div>
        </Transition>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { reactive, watch } from "vue";

const props = defineProps({
  show: Boolean,
  title: String,
  fields: Object,
  formData: Object,
  submitText: String,
  disableId: Boolean
});

const emit = defineEmits(["close", "submit"]);
const localData = reactive({});

// Deep watch to sync incoming data and clear old data
watch(
  () => props.formData,
  (val) => {
    // Clear existing keys first
    Object.keys(localData).forEach(key => delete localData[key]);
    // Assign new ones
    Object.assign(localData, val);
  },
  { immediate: true, deep: true }
);

function handleSubmit() {
  emit("submit", { ...localData });
}
</script>

<style scoped>
/* Color Palette:
   Base: #020617 (Deep Space)
   Surface: #0f172a (Navy)
   Accent: #3b82f6 (Electric Blue)
   Focus: #60a5fa (Sky Blue)
*/

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(2, 6, 23, 0.85); /* Deep space backdrop */
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal-content {
  background: #0f172a; 
  width: 90%;
  max-width: 520px;
  border-radius: 20px;
  border: 1px solid #1e293b;
  box-shadow: 0 0 40px rgba(59, 130, 246, 0.15);
  overflow: hidden;
  color: #f8fafc;
}

.modal-header {
  padding: 1.5rem 2rem;
  /* Clean Blue Gradient */
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.modal-header h2 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: #ffffff;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.close-btn {
  background: rgba(255, 255, 255, 0.15);
  border: none;
  width: 30px;
  height: 30px;
  border-radius: 8px;
  color: white;
  cursor: pointer;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #ef4444; /* Small hint of red for close */
  transform: rotate(90deg);
}

.modal-body {
  padding: 2rem;
  background: #0f172a;
}

.form-group label {
  display: block;
  font-size: 0.75rem;
  font-weight: 700;
  color: #60a5fa; /* Electric Blue labels */
  margin-bottom: 0.5rem;
  text-transform: uppercase;
}

input, textarea, select {
  width: 100%;
  padding: 0.8rem 1rem;
  background: #1e293b;
  border: 1px solid #334155;
  border-radius: 10px;
  color: white;
  font-size: 1rem;
  transition: border-color 0.2s, box-shadow 0.2s;
}

input:focus, select:focus {
  outline: none;
  border-color: #3b82f6;
  background: #020617;
  box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
}

.modal-footer {
  padding: 1.5rem 2rem;
  background: #1e293b;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.btn-primary {
  background: linear-gradient(90deg, #2563eb 0%, #3b82f6 100%);
  color: white;
  padding: 0.8rem 2rem;
  border-radius: 10px;
  border: none;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary:hover {
  filter: brightness(1.2);
  box-shadow: 0 4px 15px rgba(37, 99, 235, 0.4);
}

.btn-secondary {
  background: transparent;
  color: #94a3b8;
  border: 1px solid #334155;
  padding: 0.8rem 2rem;
  border-radius: 10px;
  cursor: pointer;
}
</style>