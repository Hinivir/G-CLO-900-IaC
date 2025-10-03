
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"sync"
	"sync/atomic"

	"github.com/gorilla/mux"
)

// Item correspond à la structure utilisée en C++
type Item struct {
	ID          int64  `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// Base de données en mémoire
var (
	db      = make(map[int64]Item)
	dbMutex sync.Mutex
	nextID  int64 = 1
)

// GET /items
func getAllItems(w http.ResponseWriter, r *http.Request) {
	dbMutex.Lock()
	items := make([]Item, 0, len(db))
	for _, item := range db {
		items = append(items, item)
	}
	dbMutex.Unlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(items)
}

// GET /items/{id}
func getItem(w http.ResponseWriter, r *http.Request) {
	idStr := mux.Vars(r)["id"]
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		http.Error(w, `{"error":"invalid id"}`, http.StatusBadRequest)
		return
	}

	dbMutex.Lock()
	item, ok := db[id]
	dbMutex.Unlock()

	if !ok {
		http.Error(w, `{"error":"not found"}`, http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(item)
}

// POST /items
func createItem(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Name        string `json:"name"`
		Description string `json:"description"`
	}

	if err := json.NewDecoder(r.Body).Decode(&input); err != nil || input.Name == "" {
		http.Error(w, `{"error":"invalid json or missing 'name'"}`, http.StatusBadRequest)
		return
	}

	id := atomic.AddInt64(&nextID, 1)
	item := Item{
		ID:          id,
		Name:        input.Name,
		Description: input.Description,
	}

	dbMutex.Lock()
	db[id] = item
	dbMutex.Unlock()

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(item)
}

// PUT /items/{id}
func updateItem(w http.ResponseWriter, r *http.Request) {
	idStr := mux.Vars(r)["id"]
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		http.Error(w, `{"error":"invalid id"}`, http.StatusBadRequest)
		return
	}

	var input struct {
		Name        *string `json:"name"`
		Description *string `json:"description"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, `{"error":"invalid json"}`, http.StatusBadRequest)
		return
	}

	dbMutex.Lock()
	item, ok := db[id]
	if !ok {
		dbMutex.Unlock()
		http.Error(w, `{"error":"not found"}`, http.StatusNotFound)
		return
	}

	if input.Name != nil {
		item.Name = *input.Name
	}
	if input.Description != nil {
		item.Description = *input.Description
	}
	db[id] = item
	dbMutex.Unlock()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(item)
}

// DELETE /items/{id}
func deleteItem(w http.ResponseWriter, r *http.Request) {
	idStr := mux.Vars(r)["id"]
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		http.Error(w, `{"error":"invalid id"}`, http.StatusBadRequest)
		return
	}

	dbMutex.Lock()
	_, ok := db[id]
	if ok {
		delete(db, id)
	}
	dbMutex.Unlock()

	if !ok {
		http.Error(w, `{"error":"not found"}`, http.StatusNotFound)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/items", getAllItems).Methods("GET")
	r.HandleFunc("/items/{id:[0-9]+}", getItem).Methods("GET")
	r.HandleFunc("/items", createItem).Methods("POST")
	r.HandleFunc("/items/{id:[0-9]+}", updateItem).Methods("PUT")
	r.HandleFunc("/items/{id:[0-9]+}", deleteItem).Methods("DELETE")

	port := ":18080"
	log.Printf("🚀 API Go lancée sur http://localhost%s", port)
	log.Fatal(http.ListenAndServe(port, r))
}
