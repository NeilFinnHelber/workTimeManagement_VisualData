<script setup>
import { ref, onMounted, nextTick, watch } from "vue";
import {
  Chart,
  BarController,
  BarElement,
  LineController,
  LineElement,
  PieController,
  ArcElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Title,
  Tooltip,
  Legend
} from "chart.js";

Chart.register(
    BarController, BarElement,
    LineController, LineElement,
    PieController, ArcElement,
    CategoryScale, LinearScale, PointElement,
    Title, Tooltip, Legend
);

// Reactive state
const shiftParts = ref([]);
const timeRange = ref("month");
const startDate = ref("");
const endDate = ref("");
const selectedProjectId = ref(null);
const projects = ref([]);

// All available charts
const allCharts = ref([
  {
    id: 1,
    name: "Hours by Project",
    type: "bar",
    metric: "time_per_project",
    group_by: "project",
    color: "rgba(59, 130, 246, 0.7)"
  },
  {
    id: 2,
    name: "Hours by User",
    type: "bar",
    metric: "time_per_user",
    group_by: "user",
    color: "rgba(16, 185, 129, 0.7)"
  },
  {
    id: 3,
    name: "Daily Activity Trend",
    type: "line",
    metric: "activity_over_time",
    group_by: "day",
    color: "rgba(245, 158, 11, 0.8)"
  },
  {
    id: 4,
    name: "Project Distribution",
    type: "pie",
    metric: "time_per_project",
    group_by: "project"
  },
  {
    id: 5,
    name: "Average Shift Duration",
    type: "bar",
    metric: "avg_hours"
  },
  {
    id: 6,
    name: "Hours per Day of Week",
    type: "bar",
    metric: "time_per_project",
    group_by: "weekday",
    color: "rgba(139, 92, 246, 0.7)"
  },
  {
    id: 7,
    name: "Top Users by Hours",
    type: "bar",
    metric: "time_per_user",
    group_by: "user",
    color: "rgba(249, 115, 22, 0.7)"
  },
  {
    id: 8,
    name: "Monthly Trend",
    type: "line",
    metric: "activity_over_time",
    group_by: "month",
    color: "rgba(14, 165, 233, 0.8)"
  },
]);

// User-selected chart IDs
const selectedChartIds = ref([]);
const visibleCharts = ref([]);
const showModal = ref(false);

const chartInstances = {};

// Load saved chart preferences
function loadSelectedCharts() {
  const saved = localStorage.getItem('selectedChartIds');
  if (saved) {
    selectedChartIds.value = JSON.parse(saved);
  } else {
    selectedChartIds.value = allCharts.value.slice(0, 6).map(c => c.id);
  }
}

function saveSelectedCharts() {
  localStorage.setItem('selectedChartIds', JSON.stringify(selectedChartIds.value));
}

function toggleChart(id) {
  if (selectedChartIds.value.includes(id)) {
    selectedChartIds.value = selectedChartIds.value.filter(cid => cid !== id);
  } else {
    selectedChartIds.value.push(id);
  }
  saveSelectedCharts();
  updateVisibleCharts();
}

function selectAll() {
  selectedChartIds.value = allCharts.value.map(c => c.id);
  saveSelectedCharts();
  updateVisibleCharts();
}

function deselectAll() {
  selectedChartIds.value = [];
  saveSelectedCharts();
  updateVisibleCharts();
}

function updateVisibleCharts() {
  visibleCharts.value = allCharts.value.filter(chart =>
      selectedChartIds.value.includes(chart.id)
  );
}

// Fetch data
async function fetchData() {
  try {
    const res = await fetch("http://localhost:3000/shift_parts");
    shiftParts.value = await res.json();

    extractProjects();
    updateVisibleCharts();
    await nextTick();
    renderAllCharts();
  } catch (err) {
    console.error("Failed to fetch data:", err);
  }
}

function extractProjects() {
  const projectMap = new Map();
  shiftParts.value.forEach(s => {
    if (s.project_id && s.project_name) {
      projectMap.set(Number(s.project_id), s.project_name);
    }
  });
  projects.value = Array.from(projectMap, ([id, name]) => ({ id, name }))
      .sort((a, b) => a.name.localeCompare(b.name));
}

// Build Dataset
function buildDataset(config) {
  let filtered = filterByTime(shiftParts.value);

  if (selectedProjectId.value !== null) {
    filtered = filtered.filter(s => Number(s.project_id) === selectedProjectId.value);
  }

  const map = {};

  filtered.forEach(s => {
    let key = "N/A";

    switch (config.group_by) {
      case "user":
        key = s.user_name || "Unknown";
        break;
      case "project":
        key = s.project_name || "Unassigned";
        break;
      case "day":
        key = new Date(s.start_time).toISOString().split("T")[0];
        break;
      case "month":
        const d = new Date(s.start_time);
        key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
        break;
      case "weekday":
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        key = days[new Date(s.start_time).getDay()];
        break;
    }

    if (!map[key]) map[key] = 0;

    if (config.metric.includes("time")) {
      const duration = (new Date(s.end_time) - new Date(s.start_time)) / (1000 * 60 * 60);
      map[key] += duration;
    } else if (config.metric === "activity_over_time") {
      map[key] += 1;
    }
  });

  if (config.metric === "avg_hours") {
    const durations = filtered.map(s =>
        (new Date(s.end_time) - new Date(s.start_time)) / (1000 * 60 * 60)
    );
    const avg = durations.length ? durations.reduce((a, b) => a + b, 0) / durations.length : 0;
    return { labels: ["Average"], data: [Number(avg.toFixed(2))] };
  }

  return { labels: Object.keys(map), data: Object.values(map) };
}

// Fixed filterByTime function
function filterByTime(data) {
  if (!data || data.length === 0) return [];

  return data.filter(s => {
    const shiftDate = new Date(s.start_time);

    if (timeRange.value === "custom") {
      if (!startDate.value || !endDate.value) return false;
      const from = new Date(startDate.value);
      const to = new Date(endDate.value);
      to.setHours(23, 59, 59, 999);
      return shiftDate >= from && shiftDate <= to;
    }

    const now = new Date();

    switch (timeRange.value) {
      case "today":
        return shiftDate.toDateString() === now.toDateString();
      case "week":
        const weekAgo = new Date(now);
        weekAgo.setDate(weekAgo.getDate() - 7);
        return shiftDate >= weekAgo;
      case "month":
        return shiftDate.getMonth() === now.getMonth() &&
            shiftDate.getFullYear() === now.getFullYear();
      case "year":
        return shiftDate.getFullYear() === now.getFullYear();
      default:
        return true;
    }
  });
}

// Render charts
function renderAllCharts() {
  visibleCharts.value.forEach(config => {
    const canvas = document.getElementById(`chart-${config.id}`);
    if (!canvas) return;

    if (chartInstances[config.id]) {
      chartInstances[config.id].destroy();
    }

    const dataset = buildDataset(config);
    const isPie = config.type === "pie";

    chartInstances[config.id] = new Chart(canvas.getContext("2d"), {
      type: config.type,
      data: {
        labels: dataset.labels,
        datasets: [{
          label: config.name,
          data: dataset.data,
          backgroundColor: isPie
              ? generateColors(dataset.labels.length)
              : config.color || "#3b82f6",
          borderColor: "#fff",
          borderWidth: isPie ? 2 : 1,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: isPie ? "bottom" : "top" },
          title: { display: true, text: config.name, font: { size: 16 } }
        },
        scales: !isPie ? { y: { beginAtZero: true } } : undefined
      }
    });
  });
}

function generateColors(count) {
  const palette = ["#3b82f6", "#10b981", "#f59e0b", "#ec4899", "#8b5cf6", "#f97316", "#06b67f", "#14b8a6"];
  return Array.from({ length: count }, (_, i) => palette[i % palette.length] + "dd");
}

// Watchers
watch([timeRange, startDate, endDate, selectedProjectId], () => {
  if (timeRange.value !== "custom") {
    startDate.value = "";
    endDate.value = "";
  }
  nextTick(renderAllCharts);
});

// Initialize
onMounted(() => {
  loadSelectedCharts();
  fetchData();
});
</script>

<template>
  <div class="dashboard">
    <div class="controls">
      <!-- Time Range -->
      <div class="filter-bar">
        <button :class="{ active: timeRange === 'today' }" @click="timeRange = 'today'">Today</button>
        <button :class="{ active: timeRange === 'week' }" @click="timeRange = 'week'">Week</button>
        <button :class="{ active: timeRange === 'month' }" @click="timeRange = 'month'">Month</button>
        <button :class="{ active: timeRange === 'year' }" @click="timeRange = 'year'">Year</button>
        <button :class="{ active: timeRange === 'custom' }" @click="timeRange = 'custom'">Custom</button>
      </div>

      <!-- Custom Date Range -->
      <div v-if="timeRange === 'custom'" class="custom-date-range">
        <div>
          <label>From:</label>
          <input type="date" v-model="startDate" />
        </div>
        <div>
          <label>To:</label>
          <input type="date" v-model="endDate" />
        </div>
      </div>

      <!-- Project Filter -->
      <div class="project-filter">
        <label>Project:</label>
        <select v-model="selectedProjectId">
          <option :value="null">All Projects</option>
          <option v-for="p in projects" :key="p.id" :value="p.id">
            {{ p.name }}
          </option>
        </select>
      </div>

      <button @click="showModal = true" class="manage-btn">
        Manage Charts ({{ visibleCharts.length }}/{{ allCharts.length }})
      </button>
    </div>

    <div class="analytics-container">
      <h1>Analytics Dashboard</h1>

      <div v-if="visibleCharts.length === 0" class="empty-state">
        <p>No charts selected. Click "Manage Charts" to choose graphs.</p>
      </div>

      <div class="charts-grid">
        <div v-for="config in visibleCharts" :key="config.id" class="chart-card">
          <canvas :id="`chart-${config.id}`" height="300"></canvas>
        </div>
      </div>
    </div>

    <!-- Manage Charts Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h2>Manage Charts</h2>
        <p>Select which graphs to display:</p>

        <div class="chart-list">
          <label v-for="chart in allCharts" :key="chart.id" class="chart-option">
            <input
                type="checkbox"
                :checked="selectedChartIds.includes(chart.id)"
                @change="toggleChart(chart.id)"
            />
            <span>{{ chart.name }}</span>
          </label>
        </div>

        <div class="modal-actions">
          <button @click="selectAll" class="secondary">Select All</button>
          <button @click="deselectAll" class="secondary">Deselect All</button>
          <button @click="showModal = false" class="primary">Done</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.dashboard {
  padding: 1.5rem;
}

.controls {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  align-items: center;
  margin-bottom: 2rem;
}

.filter-bar button {
  padding: 0.65rem 1.25rem;
  border: none;
  border-radius: 8px;
  background: #3b82f6;
  color: white;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.filter-bar button.active,
.filter-bar button:hover {
  background: #1e40af;
  transform: translateY(-1px);
}

.custom-date-range {
  display: flex;
  gap: 1.5rem;
  align-items: center;
  flex-wrap: wrap;
}

.custom-date-range div {
  display: flex;
  align-items: center;
  gap: 8px;
}

.custom-date-range label {
  font-weight: 500;
  color: #cbd5e1;
}

.custom-date-range input[type="date"] {
  padding: 0.5rem;
  border-radius: 6px;
  border: 1px solid #475569;
  background: #1e2937;
  color: white;
}

.project-filter {
  display: flex;
  align-items: center;
  gap: 8px;
}

.project-filter select {
  padding: 0.5rem;
  border-radius: 6px;
  background: #1e2937;
  color: white;
  border: 1px solid #475569;
}

.manage-btn {
  padding: 0.65rem 1.25rem;
  background: #64748b;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.manage-btn:hover {
  background: #475569;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(420px, 1fr));
  gap: 1.8rem;
}

.chart-card {
  background: var(--bg-card, #1f2937);
  padding: 1.25rem;
  border-radius: 16px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  min-height: 340px;
}

h1 {
  margin: 0 0 1.5rem 0;
  color: #e2e8f0;
}

.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: var(--bg-card, #1f2937);
  padding: 2rem;
  border-radius: 16px;
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.chart-list {
  margin: 1.5rem 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.chart-option {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0.5rem;
  border-radius: 8px;
  cursor: pointer;
}

.chart-option:hover {
  background: rgba(255, 255, 255, 0.05);
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 1.5rem;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: #94a3b8;
  font-size: 1.1rem;
}
</style>