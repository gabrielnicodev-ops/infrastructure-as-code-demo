package main

import (
    "encoding/json"
    "net/http"
    "os"
    "time"
)

type SystemStatus struct {
    Hostname string `json:"hostname"`
    Time     string `json:"server_time"`
    Status   string `json:"status"`
    Message  string `json:"message"`
}

func enableCors(w *http.ResponseWriter) {
    (*w).Header().Set("Access-Control-Allow-Origin", "*")
}

func statusHandler(w http.ResponseWriter, r *http.Request) {
    enableCors(&w)

    hostname, _ := os.Hostname()

    status := SystemStatus{
        Hostname: hostname,
        Time:     time.Now().Format(time.RFC1123),
        Status:   "operational",
        Message:  "Hello from the Cloud! 🚀",
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(status)
}

func main() {
    http.HandleFunc("/api/status", statusHandler)
    println("Backend running on port 8080...")
    http.ListenAndServe(":8080", nil)
}
