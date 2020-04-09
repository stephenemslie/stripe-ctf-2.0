package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"
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
	path := filepath.Join(os.Getenv("LEVELCODE"), strconv.Itoa(s.Level), s.Name)
	code, _ := ioutil.ReadFile(path)
	return string(code)
}

func (s *SourceFile) Basename() string {
	return filepath.Base(s.Name)
}

func (s *SourceFile) MarshalJSON() ([]byte, error) {
	data := struct {
		Name     string
		Basename string
		Language string
		Code     string
	}{s.Name, s.Basename(), s.Language, s.Code()}
	return json.Marshal(data)
}

type Level struct {
	Index  int
	Host   string
	Port   int
	Name   string
	Color  string
	Emoji  string
	Source []*SourceFile
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

func (l *Level) IsComplete() bool {
	path := fmt.Sprintf("/mnt/levels/%d.completed", l.Index)
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		return false
	}
	return true
}

func (l *Level) IsLocked() bool {
	if l.Index == 0 {
		return false
	}
	return !levels[l.Index-1].IsComplete()
}

func (l *Level) proxy() *httputil.ReverseProxy {
	u, _ := url.Parse(fmt.Sprintf("http://%s:%d/", l.Host, l.Port))
	return httputil.NewSingleHostReverseProxy(u)
}

// Next returns the next level and an error if there isn't one
func (l *Level) Next() (*Level, error) {
	var nextLevel *Level
	index := l.Index + 1
	if index >= len(levels) {
		return nextLevel, fmt.Errorf("No such level %d", index)
	}
	nextLevel = levels[index]
	return nextLevel, nil
}

func (l *Level) unlock() {
	path := fmt.Sprintf("/mnt/levels/%d.completed", l.Index)
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		file, err := os.Create(path)
		if err != nil {
			log.Fatal(err)
		}
		defer file.Close()
	}
}

var levels = []*Level{
	{0, "level0-stripe-ctf", 3000, "The Secret Safe", "blue", "🔐",
		[]*SourceFile{
			{0, "level00.html", "html"},
			{0, "level00.js", "javascript"},
		}},
	{1, "level1-stripe-ctf", 8000, "The Guessing Game", "teal", "🎲",
		[]*SourceFile{
			{1, "index.php", "php"},
			{1, "routing.php", "php"},
		}},
	{2, "level2-stripe-ctf", 8000, "The Social Network", "green", "👥",
		[]*SourceFile{
			{2, "index.php", "php"},
			{2, "routing.php", "php"},
		}},
	{3, "level3-stripe-ctf", 5000, "The Secret Vault", "yellow", "🙊",
		[]*SourceFile{
			{3, "index.html", "html"},
			{3, "secretvault.py", "python"},
		}},
	{4, "level4-stripe-ctf", 4567, "Karma Trader", "orange", "🙏",
		[]*SourceFile{
			{4, "server/srv.rb", "ruby"},
			{4, "server/views/layout.erb", "ruby"},
			{4, "server/views/home.erb", "ruby"},
			{4, "server/views/login.erb", "ruby"},
			{4, "server/views/register.erb", "ruby"},
		}},
	{5, "level5-stripe-ctf", 4568, "DomainAuthenticator", "red", "🌐",
		[]*SourceFile{
			{5, "srv.rb", "ruby"},
		}},
	{6, "level6-stripe-ctf", 4569, "Streamer", "pink", "💬",
		[]*SourceFile{
			{6, "server/srv.rb", "ruby"},
			{6, "server/views/layout.erb", "ruby"},
			{6, "server/views/login.erb", "ruby"},
			{6, "server/views/register.erb", "ruby"},
			{6, "server/views/user_info.erb", "ruby"},
		}},
	{7, "level7-stripe-ctf", 9233, "WaffleCopter", "purple", "🚁",
		[]*SourceFile{
			{7, "wafflecopter.py", "python"},
			{7, "client.py", "python"},
			{7, "db.py", "python"},
			{7, "initialize_db.py", "python"},
			{7, "settings.py", "python"},
			{7, "templates/index.html", "html"},
			{7, "templates/login.html", "html"},
			{7, "templates/logs.html", "html"},
		}},
	{8, "level8-stripe-ctf", 4000, "PasswordDB", "indigo", "🔑",
		[]*SourceFile{
			{8, "primary_server", "python"},
			{8, "password_db_launcher", "python"},
			{8, "common.py", "python"},
			{8, "chunk_server", "python"},
		}},
}

var (
	baseTemplate *template.Template
	sessionStore *sessions.CookieStore
)

func sessionMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		session, _ := sessionStore.Get(r, "ctf")
		if _, ok := session.Values["levelProgress"]; !ok {
			session.Values["levelProgress"] = 0
			session.Save(r, w)
		}
		r = r.WithContext(context.WithValue(r.Context(), "session", session))
		next.ServeHTTP(w, r)
	})
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	t, _ := baseTemplate.Clone()
	t.ParseFiles("templates/index.html")
	data := struct {
		Handler string
		Level   Level
		Levels  []*Level
	}{"home", Level{Index: -1}, levels}
	err := t.Execute(w, data)
	if err != nil {
		fmt.Println(err)
	}
}

func levelHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	levelIndex, _ := strconv.Atoi(vars["index"])
	level := levels[levelIndex]
	if level.IsLocked() {
		http.Redirect(w, r, fmt.Sprintf("/levels/%d/unlock/", levelIndex), http.StatusFound)
		return
	}
	path := fmt.Sprintf("templates/levels/%d.html", level.Index)
	t, _ := baseTemplate.Clone()
	t.ParseFiles(path)
	data := struct {
		Handler string
		Levels  []*Level
		Level   *Level
	}{"level", levels, level}
	err := t.Execute(w, data)
	if err != nil {
		fmt.Println(err)
	}
}

func codeLevelHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	levelIndex, _ := strconv.Atoi(vars["index"])
	level := levels[levelIndex]
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(level)
}

func unlockLevelHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	levelIndex, _ := strconv.Atoi(vars["index"])
	level := levels[levelIndex]
	if r.Method == http.MethodGet {
		if !level.IsLocked() {
			http.Redirect(w, r, fmt.Sprintf("/levels/%d/", levelIndex), http.StatusFound)
		} else {
			t, _ := baseTemplate.Clone()
			t.ParseFiles("templates/locked.html")
			data := struct {
				Handler string
				Levels  []*Level
				Level   *Level
			}{"unlock", levels, level}
			t.Execute(w, data)
		}
	} else if r.Method == http.MethodPost {
		if level.checkPassword(r.FormValue("password")) {
			level.unlock()
		}
		http.Redirect(w, r, fmt.Sprintf("/levels/%d/", levelIndex+1), http.StatusFound)
	}
}

func flagHandler(w http.ResponseWriter, r *http.Request) {
	data := struct {
		Handler string
		Levels  []*Level
		Level   Level
	}{"flag", levels, Level{Index: -1}}
	var t *template.Template
	if levels[8].IsComplete() {
		t, _ = baseTemplate.Clone()
		t.ParseFiles("templates/flag.html")
	} else {
		t, _ = baseTemplate.Clone()
		t.ParseFiles("templates/flag_locked.html")
	}
	err := t.Execute(w, data)
	if err != nil {
		fmt.Println(err)
	}
}

func main() {
	key := []byte(os.Getenv("SECRET"))
	sessionStore = sessions.NewCookieStore(key)
	baseTemplate, _ = template.ParseGlob("templates/layout/*.html")
	r := mux.NewRouter()
	r.Use(sessionMiddleware)
	for i := range levels {
		level := levels[i]
		s := r.Host(level.Host).Subrouter()
		s.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if level.IsLocked() {
				http.Redirect(w, r, fmt.Sprintf("http://stripe-ctf:8000/levels/%d/unlock/", level.Index), http.StatusFound)
			} else {
				level.proxy().ServeHTTP(w, r)
			}
		})
	}
	r.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))
	r.HandleFunc("/", indexHandler).Methods("GET")
	r.HandleFunc("/levels/{index:[0-8]}/unlock/", unlockLevelHandler).Methods("GET", "POST")
	r.HandleFunc("/levels/{index:[0-8]}.json", codeLevelHandler).Methods("GET")
	r.HandleFunc("/levels/{index:[0-8]}/", levelHandler).Methods("GET")
	r.HandleFunc("/flag/", flagHandler).Methods("GET")
	http.Handle("/", r)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
