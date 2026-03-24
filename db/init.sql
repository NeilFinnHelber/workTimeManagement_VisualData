CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    role ENUM('manager','developer','admin') NOT NULL
);

-- testdaten
INSERT INTO users (name, email, role) VALUES
('Alice', 'alice@example.com', 'developer'),
('Bob', 'bob@example.com', 'manager'),
('Charlie', 'charlie@example.com', 'developer');


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


CREATE TABLE time_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    project_id INT NOT NULL,
    total_start_time DATETIME NOT NULL,
    total_end_time DATETIME NOT NULL,
    break_duration INT DEFAULT 0, -- in Minuten
    note TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) on delete cascade ,
    FOREIGN KEY (project_id) REFERENCES projects(id) on delete cascade
);

-- testdaten
INSERT INTO time_table (user_id, project_id, total_start_time, total_end_time, break_duration, note)
VALUES
(1, 1, '2026-03-21 08:00:00', '2026-03-21 12:00:00', 15, 'Morning shift'),
(2, 1, '2026-03-21 09:00:00', '2026-03-21 17:00:00', 60, 'Full day work'),
(3, 2, '2026-03-21 10:00:00', '2026-03-21 14:00:00', 0, 'Afternoon shift');


CREATE TABLE shift_parts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT NOT NULL,
    issue_text TEXT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    note TEXT,
    FOREIGN KEY (shift_id) REFERENCES time_table(id) on delete cascade
);

-- testdaten
INSERT INTO shift_parts (shift_id, issue_text, start_time, end_time, note)
VALUES
(1, 'Fix login bug', '2026-03-21 08:00:00', '2026-03-21 10:00:00', 'Critical bugfix'),
(1, 'Update README', '2026-03-21 10:15:00', '2026-03-21 12:00:00', 'Documentation'),
(2, 'Implement feature X', '2026-03-21 09:00:00', '2026-03-21 13:00:00', ''),
(2, 'Team meeting', '2026-03-21 14:00:00', '2026-03-21 17:00:00', 'Weekly sync'),
(3, 'Code review', '2026-03-21 10:00:00', '2026-03-21 12:00:00', '');


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

