<script setup>
import { ref, onMounted, nextTick, watch } from "vue";
import {
  Chart,
  BarController,
  BarElement,
  LineController,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement
} from "chart.js";

Chart.register(
    BarController, BarElement,
    LineController, LineElement,
    CategoryScale, LinearScale, PointElement
);

// Reactive state
const charts = ref([]);
const shiftParts = ref([]);
const timeRange = ref("year");
const selectedProjectId = ref(null);     // ← NEW: Project filter
const projects = ref([]);                // ← NEW: List of projects for dropdown

// Fetch data
async function fetchData() {
  const [chartsRes, shiftRes] = await Promise.all([
    fetch("http://localhost:3000/charts"),
    fetch("http://localhost:3000/shift_parts")
  ]);

  charts.value = await chartsRes.json();
  shiftParts.value = await shiftRes.json();

  // Extract unique projects for filter dropdown
  extractProjects();

  await nextTick();
  renderCharts();
}

// NEW: Extract unique projects
function extractProjects() {
  const projectMap = new Map();

  shiftParts.value.forEach(s => {
    if (s.project_id && s.project_name) {
      projectMap.set(s.project_id, s.project_name);
    }
  });

  projects.value = Array.from(projectMap, ([id, name]) => ({
    id: Number(id),
    name
  })).sort((a, b) => a.name.localeCompare(b.name));
}

// Transform data with project filter
function buildDataset(chartConfig) {
  let filtered = filterByTime(shiftParts.value);

  // === NEW: Apply Project Filter ===
  if (selectedProjectId.value !== null) {
    filtered = filtered.filter(
        s => Number(s.project_id) === selectedProjectId.value
    );
  }

  // Filter by user/project from chart config (if any)
  if (chartConfig.filter_user_id) {
    filtered = filtered.filter(s => Number(s.user_id) === Number(chartConfig.filter_user_id));
  }

  if (chartConfig.filter_project_id && !selectedProjectId.value) {
    filtered = filtered.filter(s => Number(s.project_id) === Number(chartConfig.filter_project_id));
  }

  // Special case: average hours
  if (chartConfig.metric === "avg_hours") {
    const durations = filtered.map(s => {
      const start = new Date(s.start_time);
      const end = new Date(s.end_time);
      return (end - start) / (1000 * 60 * 60);
    });

    const avg = durations.length ? durations.reduce((a, b) => a + b, 0) / durations.length : 0;
    return { labels: ["Average"], data: [avg] };
  }

  // Grouped metrics
  const map = {};
  filtered.forEach(s => {
    let key;

    switch (chartConfig.group_by) {
      case "user":
        key = s.user_name || "Unknown User";
        break;
      case "project":
        key = s.project_name || "Unassigned";
        break;
      case "day":
        const d = new Date(s.start_time);
        key = d.toISOString().split("T")[0];
        break;
      default:
        key = s[chartConfig.group_by] || "N/A";
    }

    if (!map[key]) map[key] = 0;

    if (chartConfig.metric === "time_per_project" || chartConfig.metric === "time_per_user") {
      const start = new Date(s.start_time);
      const end = new Date(s.end_time);
      map[key] += (end - start) / (1000 * 60 * 60);
    }

    if (chartConfig.metric === "activity_over_time") {
      map[key] += 1;
    }
  });

  return {
    labels: Object.keys(map),
    data: Object.values(map)
  };
}

// Time filtering (unchanged)
function filterByTime(data) {
  const now = new Date();
  return data.filter(s => {
    const date = new Date(s.start_time);

    switch (timeRange.value) {
      case "today":
        return date.toDateString() === now.toDateString();
      case "week":
        const weekAgo = new Date(now);
        weekAgo.setDate(now.getDate() - 7);
        return date >= weekAgo && date <= now;
      case "month":
        return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear();
      case "year":
        return date.getFullYear() === now.getFullYear();
      default:
        return true;
    }
  });
}

// Render charts
const chartInstances = {};

function renderCharts() {
  charts.value.forEach(chartConfig => {
    const canvas = document.getElementById(`chart-${chartConfig.id}`);
    if (!canvas) return;

    const ctx = canvas.getContext("2d");

    if (chartInstances[chartConfig.id]) {
      chartInstances[chartConfig.id].destroy();
    }

    const dataset = buildDataset(chartConfig);

    chartInstances[chartConfig.id] = new Chart(ctx, {
      type: chartConfig.type,
      data: {
        labels: dataset.labels,
        datasets: [{
          label: chartConfig.name,
          data: dataset.data,
          backgroundColor: "rgba(59, 130, 246, 0.5)",
          borderColor: "#3b82f6",
          borderWidth: 2,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
      }
    });
  });
}

// Watchers
watch([timeRange, selectedProjectId], () => {
  nextTick(() => renderCharts());
});

// Initial fetch
onMounted(fetchData);
</script>

<template>
  <div class="controls">
    <!-- Time Range -->
    <div class="filter-bar">
      <button :class="{ active: timeRange === 'today' }" @click="timeRange = 'today'">Today</button>
      <button :class="{ active: timeRange === 'week' }" @click="timeRange = 'week'">Week</button>
      <button :class="{ active: timeRange === 'month' }" @click="timeRange = 'month'">Month</button>
      <button :class="{ active: timeRange === 'year' }" @click="timeRange = 'year'">Year</button>
    </div>

    <!-- NEW: Project Filter -->
    <div class="project-filter">
      <label for="project-select">Project:</label>
      <select id="project-select" v-model="selectedProjectId">
        <option :value="null">All Projects</option>
        <option v-for="p in projects" :key="p.id" :value="p.id">
          {{ p.name }}
        </option>
      </select>
    </div>
  </div>

  <div class="analytics-container">
    <h2>Analytics Dashboard</h2>

    <div class="charts-grid">
      <div v-for="c in charts" :key="c.id" class="chart-card">
        <h3>{{ c.name }}</h3>
        <canvas :id="`chart-${c.id}`" height="200"></canvas>
      </div>
    </div>
  </div>
</template>

<style scoped>
.analytics-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 2rem;
}

.chart-card {
  background: var(--bg-card);
  padding: 1rem;
  border-radius: 12px;
}

.filter-bar {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.filter-bar button {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  background: #3b82f6;
  color: white;
  cursor: pointer;
}

.filter-bar button:hover {
  background: #2563eb;
}
</style>