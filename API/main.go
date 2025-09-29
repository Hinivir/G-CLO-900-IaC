package main

import (
    "encoding/json"
    "fmt"
    "log"
    "math/rand"
    "net/http"
    "strconv"
    "github.com/gorilla/mux"
)

type Data struct {
    ID      string `json:"id"`
    Title   string `json:"title"`
    Content string `json:"content"`
	DueDate string `json:"due_date"`
	Done   bool   `json:"done"`
}

var datas []Data

func getDatas(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(datas)
}

func getData(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    params := mux.Vars(r)
    for _, item := range datas {
        if item.ID == params["id"] {
            json.NewEncoder(w).Encode(item)
            return
        }
    }
    http.NotFound(w, r)
}

func createData(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    var data Data
    _ = json.NewDecoder(r.Body).Decode(&data)
    data.ID = strconv.Itoa(rand.Intn(100000))
    datas = append(datas, data)
    json.NewEncoder(w).Encode(data)
}

func updateData(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    params := mux.Vars(r)
    for index, item := range datas {
        if item.ID == params["id"] {
            datas = append(datas[:index], datas[index+1:]...)
            var data Data
            _ = json.NewDecoder(r.Body).Decode(&data)
            data.ID = params["id"]
            datas = append(datas, data)
            json.NewEncoder(w).Encode(data)
            return
        }
    }
    http.NotFound(w, r)
}

func deleteData(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    params := mux.Vars(r)
    for index, item := range datas {
        if item.ID == params["id"] {
            datas = append(datas[:index], datas[index+1:]...)
            json.NewEncoder(w).Encode(map[string]string{"message": "Données supprimées"})
            return
        }
    }
    http.NotFound(w, r)
}

func main() {
    datas = append(datas, Data{ID: "1", Title: "Première data", Content: "Contenu de data 1"})
    datas = append(datas, Data{ID: "2", Title: "Deuxième data", Content: "Contenu de data 2"})

    r := mux.NewRouter()

    r.HandleFunc("/data", getDatas).Methods("GET")
    r.HandleFunc("/data/{id}", getData).Methods("GET")
    r.HandleFunc("/data", createData).Methods("POST")
    r.HandleFunc("/data/{id}", updateData).Methods("PUT")
    r.HandleFunc("/data/{id}", deleteData).Methods("DELETE")

    fmt.Println("Serveur démarré sur le port 8000")
    log.Fatal(http.ListenAndServe(":8000", r))
}
