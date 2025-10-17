DROP TABLE IF EXISTS datas; -- reset

CREATE TABLE datas (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    due_date TEXT,
    done BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_datas_done ON datas(done);

INSERT INTO datas (title, content, due_date, done) VALUES
('1stdata', 'Testestestestest', '2025-10-15', FALSE),
('2nddata', 'attempt01', '2025-10-20', TRUE);