DROP TABLE IF EXISTS datas; -- reset


CREATE TABLE datas (
    id SERIAL PRIMARY KEY,
    title SERIAL NOT NULL,
    content SERIAL,
    due_date SERIAL,
    done BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_datas_done ON datas(done);

INSERT INTO datas (id, title, content, due_date, done) VALUES
('1', '1stdata', 'Testestestestest', '2025-10-15', FALSE),
('2', '2nddata', 'attempt01', '2025-10-20', TRUE);