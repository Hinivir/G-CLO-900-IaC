package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

type Data struct {
	ID      string `json:"id"`
	Title   string `json:"title"`
	Content string `json:"content"`
	DueDate string `json:"due_date"`
	Done    bool   `json:"done"`
}

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

func createData(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	var d Data
	_ = json.NewDecoder(r.Body).Decode(&d)
	d.ID = strconv.Itoa(rand.Intn(100000))

	_, err := db.Exec(
		"INSERT INTO datas (id, title, content, due_date, done) VALUES ($1, $2, $3, $4, $5)",
		d.ID, d.Title, d.Content, d.DueDate, d.Done,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(d)
}

func main() {
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")

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

	fmt.Println("Connexion PostgreSQL réussie")

	r := mux.NewRouter()
	r.HandleFunc("/data", func(w http.ResponseWriter, r *http.Request) { getDatas(w, r, db) }).Methods("GET")
	r.HandleFunc("/data", func(w http.ResponseWriter, r *http.Request) { createData(w, r, db) }).Methods("POST")

	fmt.Println("Serveur démarré sur le port 8000")
	log.Fatal(http.ListenAndServe(":8000", r))
}