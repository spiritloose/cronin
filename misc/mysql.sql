DROP TABLE IF EXISTS tasks;
CREATE TABLE tasks (
    id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARBINARY(767) NOT NULL,
    pid INT UNSIGNED,
    last_log_id INT UNSIGNED,
    last_executed_at DATETIME,
    created_at DATETIME NOT NULL,
    updated_at TIMESTAMP
) CHARSET utf8;
CREATE UNIQUE INDEX tasks_name ON tasks(name);
CREATE INDEX tasks_list ON tasks(last_executed_at, pid);

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
    id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    task_id INT UNSIGNED NOT NULL,
    pid INT UNSIGNED,
    user VARCHAR(32) NOT NULL,
    hostname VARCHAR(255) NOT NULL,
    argv TEXT NOT NULL,
    exit_code INT UNSIGNED,
    stdout TEXT,
    stderr TEXT,
    started_at DATETIME NOT NULL,
    finished_at DATETIME,
    updated_at TIMESTAMP
) CHARSET utf8;
CREATE INDEX logs_list ON logs(task_id, started_at);
