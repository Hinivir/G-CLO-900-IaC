DROP TABLE IF EXISTS datas; -- reset


CREATE TABLE datas (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    due_date TEXT,
    done BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_datas_done ON datas(done);

INSERT INTO datas (id, title, content, due_date, done) VALUES
('1', 'TEST', 'Testestestestest', '2025-10-15', FALSE),
('2', 'deploy ?', 'attempt01', '2025-10-20', TRUE);