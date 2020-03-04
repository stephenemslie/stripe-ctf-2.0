package main

import (
	"fmt"
	"github.com/gorilla/mux"
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
)

type SourceFile struct {
	Level    int
	Name     string
	Language string
}

func (s *SourceFile) Code() string {
	path := filepath.Join(".", "levels", strconv.Itoa(s.Level), s.Name)
	code, _ := ioutil.ReadFile(path)
	return string(code)
}

func (s *SourceFile) Basename() string {
	return filepath.Base(s.Name)
}

type Level struct {
	Index  int
	Host   string
	Port   int
	Name   string
	Source map[string]*SourceFile
}

func (l *Level) getPasswordPath() string {
	return fmt.Sprintf("/mnt/level%d/password.txt", l.Index)
}

func (l *Level) checkPassword(pwAttempt string) bool {
	password, _ := ioutil.ReadFile(l.getPasswordPath())
	return (string(password) == pwAttempt)
}

func (l *Level) setPassword(password string) {
	ioutil.WriteFile(l.getPasswordPath(), []byte(password), 0644)
}

func (l *Level) IsLocked() bool {
	path := fmt.Sprintf("/mnt/levels/%d.unlocked", l.Index)
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		return true
	}
	return false
}

func (l *Level) ExecuteTemplate(w http.ResponseWriter) {
	path := fmt.Sprintf("templates/levels/%d.html", l.Index)
	t, _ := template.ParseFiles("templates/base.html", "templates/levels/base.html", path)
	t.Execute(w, l)
}

func (l *Level) ExecuteLockedTemplate(w http.ResponseWriter) {
	t, _ := template.ParseFiles("templates/base.html", "templates/locked.html")
	t.Execute(w, l)
}

func (l *Level) Proxy() *httputil.ReverseProxy {
	u, _ := url.Parse(fmt.Sprintf("http://level%d:%d/", l.Index, l.Port))
	return httputil.NewSingleHostReverseProxy(u)
}

var levels = []Level{
	{0, "level0-stripe-ctf", 3000, "The Secret Safe"},
	{1, "level1-stripe-ctf", 8000, "The Guessing Game"},
	{2, "level2-stripe-ctf", 8000, "The Social Network"},
	{3, "level3-stripe-ctf", 5000, "The Secret Vault"},
	{4, "level4-stripe-ctf", 4567, "Karma Trader"},
	{5, "level5-stripe-ctf", 4568, "DomainAuthenticator"},
	{6, "level6-stripe-ctf", 4569, "Streamer"},
	{7, "level7-stripe-ctf", 9233, "WaffleCopter"},
	{8, "level8-stripe-ctf", 4000, "PasswordDB"},
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	t, _ := template.ParseFiles("templates/base.html", "templates/index.html")
	t.Execute(w, levels)
}

func levelHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	levelIndex, _ := strconv.Atoi(vars["index"])
	level := levels[levelIndex]
	if level.IsLocked() {
		level.ExecuteLockedTemplate(w)
	} else {
		level.ExecuteTemplate(w)
	}
}

func main() {
	r := mux.NewRouter()
	for i := range levels {
		level := levels[i]
		s := r.Host(level.Host).Subrouter()
		s.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
			if level.IsLocked() {
				level.ExecuteLockedTemplate(w)
			} else {
				level.Proxy().ServeHTTP(w, r)
			}
		})
	}
	r.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))
	r.HandleFunc("/", indexHandler).Methods("GET")
	r.HandleFunc("/levels/{index:[0-8]}/", levelHandler).Methods("GET")
	http.Handle("/", r)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
