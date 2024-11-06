package main

import (
	"fmt"
	"net/http"
	"os"
)

func hello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("<h1> hello world! </h1>"))
	w.Write([]byte(fmt.Sprintf("Envrionment env: %s<br> Secret env: %s", os.Getenv("test"), os.Getenv("secret"))))
}
func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /", hello)
	http.ListenAndServe(":8080", mux)
}
