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
	{0, "level0-stripe-ctf", 3000, "The Secret Safe",
		map[string]*SourceFile{
			"level00.html": &SourceFile{0, "level00.html", "html"},
			"level00.js":   &SourceFile{0, "level00.js", "javascript"},
		}},
	{1, "level1-stripe-ctf", 8000, "The Guessing Game",
		map[string]*SourceFile{
			"index.php":   &SourceFile{1, "index.php", "php"},
			"routing.php": &SourceFile{1, "routing.php", "php"},
		}},
	{2, "level2-stripe-ctf", 8000, "The Social Network",
		map[string]*SourceFile{
			"index.php":   &SourceFile{2, "index.php", "php"},
			"routing.php": &SourceFile{2, "routing.php", "php"},
		}},
	{3, "level3-stripe-ctf", 5000, "The Secret Vault",
		map[string]*SourceFile{
			"index.html":     &SourceFile{3, "index.html", "html"},
			"secretvault.py": &SourceFile{3, "secretvault.py", "python"},
		}},
	{4, "level4-stripe-ctf", 4567, "Karma Trader",
		map[string]*SourceFile{
			"srv.rb":       &SourceFile{4, "server/srv.rb", "ruby"},
			"layout.erb":   &SourceFile{4, "server/views/layout.erb", "ruby"},
			"home.erb":     &SourceFile{4, "server/views/home.erb", "ruby"},
			"login.erb":    &SourceFile{4, "server/views/login.erb", "ruby"},
			"register.erb": &SourceFile{4, "server/views/register.erb", "ruby"},
		}},
	{5, "level5-stripe-ctf", 4568, "DomainAuthenticator",
		map[string]*SourceFile{
			"srv.rb": &SourceFile{5, "srv.rb", "ruby"},
		}},
	{6, "level6-stripe-ctf", 4569, "Streamer",
		map[string]*SourceFile{
			"srv.rb":        &SourceFile{6, "server/srv.rb", "ruby"},
			"layout.erb":    &SourceFile{6, "server/views/layout.erb", "ruby"},
			"login.erb":     &SourceFile{6, "server/views/login.erb", "ruby"},
			"register.erb":  &SourceFile{6, "server/views/register.erb", "ruby"},
			"user_info.erb": &SourceFile{6, "server/views/user_info.erb", "ruby"},
		}},
	{7, "level7-stripe-ctf", 9233, "WaffleCopter",
		map[string]*SourceFile{
			"client.py":       &SourceFile{7, "client.py", "python"},
			"db.py":           &SourceFile{7, "db.py", "python"},
			"settings.py":     &SourceFile{7, "settings.py", "python"},
			"wafflecopter.py": &SourceFile{7, "wafflecopter.py", "python"},
		}},
	{8, "level8-stripe-ctf", 4000, "PasswordDB",
		map[string]*SourceFile{
			"primary_server":       &SourceFile{8, "primary_server", "python"},
			"password_db_launcher": &SourceFile{8, "password_db_launcher", "python"},
			"common.py":            &SourceFile{8, "common.py", "python"},
			"chunk_server":         &SourceFile{8, "chunk_server", "python"},
		}},
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
