package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

// 🔹 Structure de données principale
type Data struct {
	ID      int    `json:"id"`
	Title   string `json:"title"`
	Content string `json:"content"`
	DueDate string `json:"due_date"`
	Done    bool   `json:"done"`
}

// 🔹 GET /data → récupérer toutes les entrées
func getDatas(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	rows, err := db.Query("SELECT id, title, content, due_date, done FROM datas ORDER BY id")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var datas []Data
	for rows.Next() {
		var d Data
		if err := rows.Scan(&d.ID, &d.Title, &d.Content, &d.DueDate, &d.Done); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		datas = append(datas, d)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(datas)
}

// 🔹 GET /data/{id} → récupérer une entrée spécifique
func getData(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	params := mux.Vars(r)
	id := params["id"]

	var d Data
	err := db.QueryRow("SELECT id, title, content, due_date, done FROM datas WHERE id=$1", id).Scan(
		&d.ID, &d.Title, &d.Content, &d.DueDate, &d.Done,
	)
	if err == sql.ErrNoRows {
		http.Error(w, "Donnée non trouvée", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(d)
}

// 🔹 POST /data → créer une nouvelle entrée
func createData(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var d Data
	if err := json.NewDecoder(r.Body).Decode(&d); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	err := db.QueryRow(
		"INSERT INTO datas (title, content, due_date, done) VALUES ($1, $2, $3, $4) RETURNING id",
		d.Title, d.Content, d.DueDate, d.Done,
	).Scan(&d.ID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(d)
}

// 🔹 PUT /data/{id} → mettre à jour une entrée existante
func updateData(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	params := mux.Vars(r)
	id := params["id"]

	var d Data
	if err := json.NewDecoder(r.Body).Decode(&d); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	res, err := db.Exec(
		"UPDATE datas SET title=$1, content=$2, due_date=$3, done=$4 WHERE id=$5",
		d.Title, d.Content, d.DueDate, d.Done, id,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, _ := res.RowsAffected()
	if rowsAffected == 0 {
		http.Error(w, "Donnée non trouvée", http.StatusNotFound)
		return
	}

	// On renvoie la donnée mise à jour
	d.ID = atoiSafe(id)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(d)
}

// 🔹 DELETE /data/{id} → supprimer une entrée
func deleteData(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	params := mux.Vars(r)
	id := params["id"]

	res, err := db.Exec("DELETE FROM datas WHERE id=$1", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, _ := res.RowsAffected()
	if rowsAffected == 0 {
		http.Error(w, "Donnée non trouvée", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Donnée supprimée"})
}

// 🔹 helper pour convertir string → int
func atoiSafe(s string) int {
	var i int
	fmt.Sscanf(s, "%d", &i)
	return i
}

func main() {
	// 🧩 Lecture des variables d’environnement (Docker Compose)
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")

	if dbHost == "" || dbUser == "" || dbPassword == "" || dbName == "" {
		log.Fatal("❌ Variables d'environnement DB manquantes")
	}

	connStr := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName,
	)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Erreur de connexion à la base :", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatal("Impossible de se connecter à la base :", err)
	}

	fmt.Println("✅ Connexion PostgreSQL réussie")

	// 🔧 Définition des routes
	r := mux.NewRouter()
	r.HandleFunc("/data", func(w http.ResponseWriter, r *http.Request) { getDatas(w, r, db) }).Methods("GET")
	r.HandleFunc("/data/{id}", func(w http.ResponseWriter, r *http.Request) { getData(w, r, db) }).Methods("GET")
	r.HandleFunc("/data", func(w http.ResponseWriter, r *http.Request) { createData(w, r, db) }).Methods("POST")
	r.HandleFunc("/data/{id}", func(w http.ResponseWriter, r *http.Request) { updateData(w, r, db) }).Methods("PUT")
	r.HandleFunc("/data/{id}", func(w http.ResponseWriter, r *http.Request) { deleteData(w, r, db) }).Methods("DELETE")

	fmt.Println("🚀 Serveur démarré sur le port 8000")
	log.Fatal(http.ListenAndServe(":8000", r))
}