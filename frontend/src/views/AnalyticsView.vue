<script setup>
import { ref, onMounted, nextTick } from "vue";
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
  BarController,
  BarElement,
  LineController,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement
);

// Reactive state
const charts = ref([]);
const shiftParts = ref([]);
const timeRange = ref("today"); // ← Added reactive timeRange

// Fetch data
async function fetchData() {
  const [chartsRes, shiftRes] = await Promise.all([
    fetch("http://localhost:3000/charts"),
    fetch("http://localhost:3000/shift_parts")
  ]);

  charts.value = await chartsRes.json();
  shiftParts.value = await shiftRes.json();

  // Ensure DOM is ready
  await nextTick();
  renderCharts();
}

// Transform data
function buildDataset(chartConfig) {
  let filtered = filterByTime(shiftParts.value);

  // Filter by user/project safely
  if (chartConfig.filter_user_id) {
    filtered = filtered.filter(
      s => Number(s.user_id) === Number(chartConfig.filter_user_id)
    );
  }

  if (chartConfig.filter_project_id) {
    filtered = filtered.filter(
      s => Number(s.project_id) === Number(chartConfig.filter_project_id)
    );
  }

  // Special case: average hours
  if (chartConfig.metric === "avg_hours") {
    const durations = filtered.map(s => {
      const start = new Date(s.start_time);
      const end = new Date(s.end_time);
      return (end - start) / (1000 * 60 * 60);
    });

    const avg = durations.length
      ? durations.reduce((a, b) => a + b, 0) / durations.length
      : 0;

    return {
      labels: ["Average"],
      data: [avg]
    };
  }

  // Grouped metrics
  const map = {};
  filtered.forEach(s => {
    let key = s[chartConfig.group_by] || "N/A";
    if (!map[key]) map[key] = 0;

    if (chartConfig.metric === "count") map[key] += 1;

    if (chartConfig.metric === "total_hours") {
      const start = new Date(s.start_time);
      const end = new Date(s.end_time);
      map[key] += (end - start) / (1000 * 60 * 60);
    }
  });

  return {
    labels: Object.keys(map),
    data: Object.values(map)
  };
}

// Time filtering
function filterByTime(data) {
  const now = new Date();

  return data.filter(s => {
    const date = new Date(s.start_time);

    switch (timeRange.value) {
      case "today":
        return date.toDateString() === now.toDateString();

      case "week":
        const weekAgo = new Date();
        weekAgo.setDate(now.getDate() - 7);
        return date >= weekAgo && date <= now;

      case "month":
        return (
          date.getMonth() === now.getMonth() &&
          date.getFullYear() === now.getFullYear()
        );

      case "year":
        return date.getFullYear() === now.getFullYear();

      default:
        return true;
    }
  });
}

// Render charts
function renderCharts() {
  charts.value.forEach(chartConfig => {
    const ctx = document.getElementById(`chart-${chartConfig.id}`);
    if (!ctx) return;

    const dataset = buildDataset(chartConfig);

    new Chart(ctx, {
      type: chartConfig.type,
      data: {
        labels: dataset.labels,
        datasets: [
          {
            label: chartConfig.name,
            data: dataset.data,
            backgroundColor: "rgba(54, 162, 235, 0.6)",
            borderColor: "rgba(54, 162, 235, 1)",
            borderWidth: 1
          }
        ]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: true },
          tooltip: { enabled: true }
        },
        scales: {
          y: { beginAtZero: true }
        }
      }
    });
  });
}

// Initial fetch
onMounted(fetchData);
</script>

<template>
  <div class="filter-bar">
    <button @click="timeRange = 'today'">Today</button>
    <button @click="timeRange = 'week'">Week</button>
    <button @click="timeRange = 'month'">Month</button>
    <button @click="timeRange = 'year'">Year</button>
  </div>

  <div class="analytics-container">
    <h2>Analytics Dashboard</h2>

    <div class="charts-grid">
      <div v-for="c in charts" :key="c.id" class="chart-card">
        <h3>{{ c.name }}</h3>
        <canvas :id="`chart-${c.id}`"></canvas>
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