CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    host TEXT NOT NULL,
    name TEXT NOT NULL,
    pid INTEGER,
    last_log_id INTEGER,
    last_executed_at DATETIME,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);
CREATE UNIQUE INDEX tasks_host_name ON tasks(host, name);
CREATE INDEX tasks_list ON tasks(last_executed_at, pid);

CREATE TABLE logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    pid INTEGER,
    user TEXT NOT NULL,
    host TEXT NOT NULL,
    command TEXT NOT NULL,
    exit_code INTEGER,
    stdout TEXT,
    stderr TEXT,
    started_at DATETIME NOT NULL,
    finished_at DATETIME,
    updated_at DATETIME NOT NULL
);
CREATE INDEX logs_host_list ON logs(host, started_at);
CREATE INDEX logs_task_id_list ON logs(task_id, started_at);
