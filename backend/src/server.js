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




// ------------------ Start server ------------------
app.listen(port, () => {
  console.log(`Backend running at http://localhost/:${port}/api-v1`);
});