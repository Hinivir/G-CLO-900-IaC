CREATE TABLE IF NOT EXISTS datas (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    due_date TIMESTAMP NULL,
    done BOOLEAN DEFAULT false
);

-- Exemple de données initiales (facultatif)
INSERT INTO datas (title, content, due_date, done) VALUES
('Première data', 'Contenu de data 1', NOW() + INTERVAL '7 days', false),
('Deuxième data', 'Contenu de data 2', NOW() + INTERVAL '14 days', false);  