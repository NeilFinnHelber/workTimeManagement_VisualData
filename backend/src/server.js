// server.js
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import * as mariadb from "mariadb";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config();
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// MariaDB Pool
const pool = mariadb.createPool({
  host: "localhost",
  user: "root",
  password: "rootpassword",
  database: "visual_data",
  port: 3306,
});


//  ---------- all gets ----------
app.get("/users", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const users = await connection.query("SELECT * FROM users");
    res.json(users);
  } catch (err) {
    console.error("Error fetching users:", err);
    res.status(500).json({ message: "Error fetching users" });
  } finally {
    if (connection) connection.release();
  }
});



app.get("/projects", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const projects = await connection.query("SELECT * FROM projects");
    res.json(projects);
  } catch (err) {
    console.error("Error fetching projects:", err);
    res.status(500).json({ message: "Error fetching projects" });
  } finally {
    if (connection) connection.release();
  }
});



app.get("/time_table", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const shifts = await connection.query(
      `SELECT t.*, u.name AS user_name, p.name AS project_name
       FROM time_table t
       JOIN users u ON t.user_id = u.id
       JOIN projects p ON t.project_id = p.id`
    );
    res.json(shifts);
  } catch (err) {
    console.error("Error fetching shifts:", err);
    res.status(500).json({ message: "Error fetching shifts" });
  } finally {
    if (connection) connection.release();
  }
});



app.get("/shift_parts", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const shiftParts = await connection.query(
      `SELECT sp.*, t.user_id, t.project_id, u.name AS user_name, p.name AS project_name
       FROM shift_parts sp
       JOIN time_table t ON sp.shift_id = t.id
       JOIN users u ON t.user_id = u.id
       JOIN projects p ON t.project_id = p.id`
    );
    res.json(shiftParts);
  } catch (err) {
    console.error("Error fetching shift parts:", err);
    res.status(500).json({ message: "Error fetching shift parts" });
  } finally {
    if (connection) connection.release();
  }
});



app.get("/charts", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const charts = await connection.query(
      `SELECT c.*, u.name AS created_by_name
       FROM charts c
       LEFT JOIN users u ON c.created_by = u.id`
    );
    res.json(charts);
  } catch (err) {
    console.error("Error fetching charts:", err);
    res.status(500).json({ message: "Error fetching charts" });
  } finally {
    if (connection) connection.release();
  }
});


//  ---------- all puts ----------

app.put("/users/:id", async (req, res) => {
let connection;
try {  connection = await pool.getConnection();
  const { id } = req.params;
  const { name, email, role } = req.body;
    
  if (!name || !email || !role) {
      return res.status(400).json({ message: "All fields are required" });
  }
  const result = await connection.query("UPDATE users SET name = ?, email = ?, role = ? WHERE id = ?", [name, email, role, id]);
  
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "User entry not found" });
    }
  
  res.json({ message: "User updated successfully" });
} 
catch (err) {
  console.error("Error updating user:", err);
  res.status(500).json({ message: "Error updating user" });
}
finally 
{
    if (connection) connection.release();
}
});


app.put("/projects/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { id } = req.params;
    const { name, description, completed } = req.body;

    if (name === undefined || description === undefined || completed === undefined) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const result = await connection.query(
      `UPDATE projects
       SET name = ?, description = ?, completed = ?
       WHERE id = ?`,
      [name, description, completed, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Project not found" });
    }

    res.json({ message: "Project updated successfully" });
  } catch (err) {
    console.error("Error updating project:", err);
    res.status(500).json({ message: "Error updating project" });
  } finally {
    if (connection) connection.release();
  }
});

app.put("/time_table/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { id } = req.params;
    const {
      user_id,
      project_id,
      total_start_time,
      total_end_time,
      break_duration,
      note,
    } = req.body;

    if (
      user_id === undefined ||
      project_id === undefined ||
      total_start_time === undefined ||
      total_end_time === undefined ||
      break_duration === undefined ||
      note === undefined
    ) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const result = await connection.query(
      `UPDATE time_table
       SET user_id = ?, project_id = ?, total_start_time = ?, 
           total_end_time = ?, break_duration = ?, note = ?
       WHERE id = ?`,
      [
        user_id,
        project_id,
        total_start_time,
        total_end_time,
        break_duration,
        note,
        id,
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Time entry not found" });
    }

    res.json({ message: "Time entry updated successfully" });
  } catch (err) {
    console.error("Error updating time entry:", err);
    res.status(500).json({ message: "Error updating time entry" });
  } finally {
    if (connection) connection.release();
    }
  });

app.put("/shift_parts/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { id } = req.params;
    const { shift_id, issue_text, start_time, end_time, note } = req.body;

    if (
      shift_id === undefined ||
      issue_text === undefined ||
      start_time === undefined ||
      end_time === undefined ||
      note === undefined
    ) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const result = await connection.query(
      `UPDATE shift_parts
       SET shift_id = ?, issue_text = ?, start_time = ?, end_time = ?, note = ?
       WHERE id = ?`,
      [shift_id, issue_text, start_time, end_time, note, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Shift part not found" });
    }

    res.json({ message: "Shift part updated successfully" });
  } catch (err) {
    console.error("Error updating shift part:", err);
    res.status(500).json({ message: "Error updating shift part" });
  } finally {
    if (connection) connection.release();
  }
});

app.put("/charts/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { id } = req.params;
    const {
      name,
      type,
      metric,
      group_by,
      filter_project_id,
      filter_user_id,
    } = req.body;

    if (
      name === undefined ||
      type === undefined ||
      metric === undefined ||
      group_by === undefined ||
      filter_project_id === undefined ||
      filter_user_id === undefined
    ) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const result = await connection.query(
      `UPDATE charts
       SET name = ?, type = ?, metric = ?, group_by = ?, 
           filter_project_id = ?, filter_user_id = ?
       WHERE id = ?`,
      [
        name,
        type,
        metric,
        group_by,
        filter_project_id,
        filter_user_id,
        id,
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Chart not found" });
    }

    res.json({ message: "Chart updated successfully" });
  } catch (err) {
    console.error("Error updating chart:", err);
    res.status(500).json({ message: "Error updating chart" });
  } finally {
    if (connection) connection.release();
  }
});

// ------------------ Start server ------------------
app.listen(port, () => {
  console.log(`Backend running at http://localhost/:${port}/api-v1`);
});