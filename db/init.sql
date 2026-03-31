create database visual_data;
use visual_data;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    company_role VARCHAR(50) NOT NULL,
    editor_permission ENUM ('user', 'admin') DEFAULT 'user'
);

-- testdaten
INSERT INTO users (name, email, password_hash, company_role, editor_permission) VALUES
('Alice admin', 'alice@example.com', '$2b$12$...', 'developer', 'admin'),
('Bob', 'bob@example.com', '$2b$12$...', 'manager', 'user'),
('Charlie', 'charlie@example.com', '$2b$12$...', 'developer', 'user');


CREATE TABLE projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE
);

-- testdaten
INSERT INTO projects (name, description, completed) VALUES
('Project Alpha', 'Erstes Testprojekt', FALSE),
('Project Beta', 'Zweites Testprojekt', FALSE),
('Project Gamma', 'Drittes Testprojekt', TRUE);



CREATE TABLE shift_parts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_type ENUM('fix','meeting','documentation', 'feature', 'chore', 'break', 'review', 'other') NOT NULL,
    issue_text TEXT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    note TEXT,
    project_id INT,
    user_id INT,
    FOREIGN KEY (project_id) REFERENCES projects(id) on delete set null,
    FOREIGN KEY (user_id) REFERENCES users(id) on delete set null
);

-- testdaten
INSERT INTO shift_parts (user_id, project_id, task_type, issue_text, start_time, end_time, note) 
VALUES
(1, 1, 'fix', 'Fix login bug', '2026-03-21 08:00:00', '2026-03-21 10:00:00', 'Critical bugfix'),
(1, 2, 'chore', 'Update README', '2026-03-21 10:15:00', '2026-03-21 12:00:00', 'Documentation'),
(2, 1, 'feature', 'Implement feature X', '2026-03-21 09:00:00', '2026-03-21 13:00:00', ''),
(2, NULL, 'meeting', 'Team meeting', '2026-03-21 14:00:00', '2026-03-21 17:00:00', 'Weekly sync'),
(3, 1, 'review', 'Code review', '2026-03-21 10:00:00', '2026-03-21 12:00:00', ''),
(3, NULL, 'break', 'Lunch break', '2026-03-21 12:00:00', '2026-03-21 13:00:00', '');


CREATE TABLE charts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    type ENUM('bar','line','pie'),
    metric VARCHAR(50),
    group_by VARCHAR(50),
    filter_project_id INT,
    filter_user_id INT,
    created_by INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) on delete set null
);

-- testdaten
INSERT INTO charts (name, type, metric, group_by, filter_project_id, filter_user_id, created_by)
VALUES
('Time per Project', 'bar', 'time_per_project', 'project', NULL, NULL, 2),
('Time per User', 'line', 'time_per_user', 'user', NULL, NULL, 2),
('Activity Over Time', 'line', 'activity_over_time', 'day', NULL, NULL, 1);

