import express from "express";
import cors from "cors";
import * as mariadb from "mariadb";
import bcrypt from "bcryptjs";


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
  bigIntAsNumber: true
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

// hardcoded for first user, would normally use auth to determine who is logged in
app.get("/users/me", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const CURRENT_USER_ID = 1;

    const rows = await connection.query(
      "SELECT * FROM users WHERE id = ?",
      [CURRENT_USER_ID]
    );

    if (!rows || rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error("Error fetching current user:", err);
    res.status(500).json({ message: "Error fetching current user" });
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

// Not fully adjusted: Normally would check if user is in project
// or maybe do something like me/projects instead in future

app.get("/projects/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { id } = req.params;

    const rows = await connection.query(
      "SELECT * FROM projects WHERE id = ?",
      [id]
    );

    if (!rows || rows.length === 0) {
      return res.status(404).json({ message: "Project not found" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error("Error fetching project:", err);
    res.status(500).json({ message: "Server error" });
  } finally {
    if (connection) connection.release();
  }
});




app.get("/shift_parts", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { project_id, user_id } = req.query;

    // Base query with joins
    let query = `
      SELECT 
        sp.*, 
        u.name AS user_name, 
        p.name AS project_name
      FROM shift_parts sp
      LEFT JOIN users u ON sp.user_id = u.id
      LEFT JOIN projects p ON sp.project_id = p.id
      WHERE 1=1
    `;

    const params = [];

    if (project_id) {
      query += " AND sp.project_id = ?";
      params.push(project_id);
    }

    if (user_id) {
      query += " AND sp.user_id = ?";
      params.push(user_id);
    }

    const rows = await connection.query(query, params);
res.json(rows);



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
  try {
    connection = await pool.getConnection();
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
  finally {
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



app.put("/shift_parts/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { id } = req.params;
    const { user_id, project_id, task_type, issue_text, start_time, end_time, note } = req.body;

if (!user_id || !task_type || !start_time || !end_time) {
  return res.status(400).json({ message: "Required fields missing" });
}

const result = await connection.query(
  `UPDATE shift_parts
   SET user_id = ?, project_id = ?, task_type = ?, issue_text = ?, start_time = ?, end_time = ?, note = ?
   WHERE id = ?`,
  [user_id, project_id || null, task_type, issue_text, start_time, end_time, note, id]
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


// ---------- all posts ----------

// Create User
app.post("/users", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { name, email, role } = req.body;

    if (!name || !email || !role) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const result = await connection.query(
      "INSERT INTO users (name, email, role) VALUES (?, ?, ?)",
      [name, email, role]
    );

    res.status(201).json({
      message: "User created successfully",
      id: Number(result.insertId),
    });
  } catch (err) {
    console.error("Error creating user:", err);
    res.status(500).json({ message: "Error creating user" });
  } finally {
    if (connection) connection.release();
  }
});


// Create Project
app.post("/projects", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const { name, description, completed } = req.body;

    if (!name || description === undefined || completed === undefined) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const result = await connection.query(
      `INSERT INTO projects (name, description, completed)
       VALUES (?, ?, ?)`,
      [name, description, completed]
    );

    res.status(201).json({
      message: "Project created successfully",
      id: Number(result.insertId),
    });
  } catch (err) {
    console.error("Error creating project:", err);
    res.status(500).json({ message: "Error creating project" });
  } finally {
    if (connection) connection.release();
  }
});



// Create Shift Part
// Create Shift Part
app.post("/shift_parts", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const {
      user_id,
      project_id,
      task_type,
      issue_text,
      start_time,
      end_time,
      note
    } = req.body;

    // validation
    if (!user_id || !task_type || !start_time || !end_time) {
      return res.status(400).json({ message: "Required fields missing" });
    }

    const result = await connection.query(
      `INSERT INTO shift_parts 
       (user_id, project_id, task_type, issue_text, start_time, end_time, note)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        user_id,
        project_id || null,
        task_type,
        issue_text || null,
        start_time,
        end_time,
        note || null
      ]
    );

    res.status(201).json({
      message: "Shift part created successfully",
      id: Number(result.insertId),
    });

  } catch (err) {
    console.error("Error creating shift part:", err);
    res.status(500).json({ message: "Error creating shift part" });
  } finally {
    if (connection) connection.release();
  }
});


// Create Chart
app.post("/charts", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();

    const {
      name,
      type,
      metric,
      group_by,
      filter_project_id,
      filter_user_id,
      created_by,
    } = req.body;

    if (
      name === undefined ||
      type === undefined ||
      metric === undefined ||
      group_by === undefined ||
      filter_project_id === undefined ||
      filter_user_id === undefined ||
      created_by === undefined
    ) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const result = await connection.query(
      `INSERT INTO charts 
       (name, type, metric, group_by, filter_project_id, filter_user_id, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        name,
        type,
        metric,
        group_by,
        filter_project_id,
        filter_user_id,
        created_by,
      ]
    );

    res.status(201).json({
      message: "Chart created successfully",
      id: Number(result.insertId),
    });
  } catch (err) {
    console.error("Error creating chart:", err);
    res.status(500).json({ message: "Error creating chart" });
  } finally {
    if (connection) connection.release();
  }
});

//  ---------- all deletes ----------

app.delete("/users/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const { id } = req.params;
    const result = await connection.query("DELETE FROM users WHERE id = ?", [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "User not found" });
    }
    else {
      res.json({ message: "User deleted successfully" });
    }
  }
  catch (err) {
    console.error("Error deleting user:", err);
    res.status(500).json({ message: "Error deleting user" });
  } finally {
    if (connection) connection.release();
  }
})

app.delete("/projects/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const { id } = req.params;
    const result = await connection.query("DELETE FROM projects WHERE id = ?", [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Project not found" });
    }
    else {
      res.json({ message: "Project part deleted successfully" });
    }
  }
  catch (err) {
    console.error("Error deleting project:", err);
    res.status(500).json({ message: "Error deleting project" });
  } finally {
    if (connection) connection.release();
  }
})



app.delete("/shift_parts/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const { id } = req.params;
    const result = await connection.query("DELETE FROM shift_parts WHERE id = ?", [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Shift part not found" });
    }
    else {
      res.json({ message: "Shift part deleted successfully" });
    }
  }
  catch (err) {
    console.error("Error deleting shift part:", err);
    res.status(500).json({ message: "Error deleting shift part" });
  } finally {
    if (connection) connection.release();
  }
})

app.delete("/charts/:id", async (req, res) => {
  let connection;
  try {
    connection = await pool.getConnection();
    const { id } = req.params;
    const result = await connection.query("DELETE FROM charts WHERE id = ?", [id]);


    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Chart not found" });
    }
    else {
      res.json({ message: "Chart deleted successfully" });
    }
  }
  catch (err) {
    console.error("Error deleting chart:", err);
    res.status(500).json({ message: "Error deleting chart" });
  } finally {
    if (connection) connection.release();
  }
})

// ------------------ Start server ------------------
app.listen(port, () => {
  console.log(`Backend running at http://localhost/:${port}/api-v1`);
});