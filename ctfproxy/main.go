package main

import (
	"context"
	"encoding/json"
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"path/filepath"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	secretmanagerpb "google.golang.org/genproto/googleapis/cloud/secretmanager/v1"
)

type SourceFile struct {
	Level    int    `json:"level"`
	Name     string `json:"name"`
	Language string `json:"language"`
}

func (s *SourceFile) getCode() string {
	path := filepath.Join(os.Getenv("LEVELCODE"), strconv.Itoa(s.Level), s.Name)
	code, _ := ioutil.ReadFile(path)
	return string(code)
}

func (s *SourceFile) getBasename() string {
	return filepath.Base(s.Name)
}

func (s *SourceFile) MarshalJSON() ([]byte, error) {
	data := struct {
		Name     string `json:"name"`
		Basename string `json:"basename"`
		Language string `json:"language"`
		Code     string `json:"code"`
	}{s.Name, s.getBasename(), s.Language, s.getCode()}
	return json.Marshal(data)
}

type Level struct {
	Index   int           `json:"index"`
	Host    string        `json:"host"`
	Port    int           `json:"port"`
	Name    string        `json:"name"`
	Emoji   string        `json:"emoji"`
	Sources []*SourceFile `json:"sources"`
}

func (l *Level) getPasswordPath() string {
	return fmt.Sprintf("/mnt/level%d/password.txt", l.Index)
}

func (l *Level) checkPassword(pwAttempt string) bool {
	password, err := ioutil.ReadFile(l.getPasswordPath())
	if os.IsNotExist(err) {
		fmt.Println(err)
		return false
	}
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

func (l *Level) reset() {
	path := fmt.Sprintf("/mnt/level%d/reset.txt", l.Index)
	os.Remove(path)
	file, err := os.Create(path)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
}

var (
	baseTemplate *template.Template
	sessionStore *sessions.CookieStore
	levels       []*Level
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
	session := r.Context().Value("session").(*sessions.Session)
	t, _ := baseTemplate.Clone()
	t.ParseFiles("templates/index.html")
	data := struct {
		Handler       string
		Level         Level
		Levels        []*Level
		LevelProgress int
	}{"home", Level{Index: -1}, levels, session.Values["levelProgress"].(int)}
	err := t.Execute(w, data)
	if err != nil {
		fmt.Println(err)
	}
}

func levelHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	levelIndex, _ := strconv.Atoi(vars["index"])
	level := levels[levelIndex]
	session := r.Context().Value("session").(*sessions.Session)
	levelProgress := session.Values["levelProgress"].(int)
	if levelProgress < level.Index {
		http.Redirect(w, r, fmt.Sprintf("/levels/%d/unlock/", levelIndex), http.StatusFound)
		return
	}
	path := fmt.Sprintf("templates/levels/%d.html", level.Index)
	t, _ := baseTemplate.Clone()
	t.ParseFiles(path)
	data := struct {
		Handler       string
		Levels        []*Level
		Level         *Level
		LevelProgress int
	}{"level", levels, level, levelProgress}
	err := t.Execute(w, data)
	if err != nil {
		fmt.Println(err)
	}
}

func codeLevelHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	session := r.Context().Value("session").(*sessions.Session)
	levelIndex, _ := strconv.Atoi(vars["index"])
	levelProgress := session.Values["levelProgress"].(int)
	if levelProgress < levelIndex {
		http.Error(
			w,
			http.StatusText(http.StatusUnauthorized),
			http.StatusUnauthorized)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(levels[levelIndex])
}

func unlockLevelHandler(w http.ResponseWriter, r *http.Request) {
	session := r.Context().Value("session").(*sessions.Session)
	vars := mux.Vars(r)
	levelProgress := session.Values["levelProgress"].(int)
	levelIndex, _ := strconv.Atoi(vars["index"])
	level := levels[levelIndex]
	if r.Method == http.MethodGet {
		if levelProgress >= levelIndex {
			http.Redirect(w, r, fmt.Sprintf("/levels/%d/", levelIndex), http.StatusFound)
		} else {
			t, _ := baseTemplate.Clone()
			t.ParseFiles("templates/locked.html")
			data := struct {
				Handler       string
				Levels        []*Level
				Level         *Level
				LevelProgress int
			}{"unlock", levels, level, levelProgress}
			t.Execute(w, data)
		}
	} else if r.Method == http.MethodPost {
		if level.checkPassword(r.FormValue("password")) {
			session.Values["levelProgress"] = level.Index + 1
			err := session.Save(r, w)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			level.reset()
		}
		if level.Index == 8 {
			http.Redirect(w, r, fmt.Sprintf("/levels/flag/"), http.StatusFound)
		} else {
			http.Redirect(w, r, fmt.Sprintf("/levels/%d/", level.Index+1), http.StatusFound)
		}
	}
}

func flagHandler(w http.ResponseWriter, r *http.Request) {
	session := r.Context().Value("session").(*sessions.Session)
	levelProgress := session.Values["levelProgress"].(int)
	var t *template.Template
	if levelProgress < 9 {
		t, _ = baseTemplate.Clone()
		t.ParseFiles("templates/flag_locked.html")
	} else {
		t, _ = baseTemplate.Clone()
		t.ParseFiles("templates/flag.html")
	}
	data := struct {
		Handler       string
		Levels        []*Level
		Level         Level
		LevelProgress int
	}{"flag", levels, Level{Index: -1}, levelProgress}
	err := t.Execute(w, data)
	if err != nil {
		fmt.Println(err)
	}
}

func init() {
	key := []byte(os.Getenv("SECRET"))
	if len(key) == 0 && os.Getenv("GCLOUD_SECRET_KEY_NAME") != "" {
		ctx := context.Background()
		client, err := secretmanager.NewClient(ctx)
		if err != nil {
			log.Fatalf("failed to setup secrets client: %v", err)
		}
		accessRequest := &secretmanagerpb.AccessSecretVersionRequest{
			Name: os.Getenv("GCLOUD_SECRET_KEY_NAME"),
		}
		result, err := client.AccessSecretVersion(ctx, accessRequest)
		if err != nil {
			log.Fatalf("failed to access secret version: %v", err)
		}
		key = result.Payload.Data
	}
	sessionStore = sessions.NewCookieStore(key)
	baseTemplate, _ = template.ParseGlob("templates/layout/*.html")
	path := filepath.Join(os.Getenv("LEVELCODE"), "levels.json")
	levelsJson, _ := ioutil.ReadFile(path)
	json.Unmarshal(levelsJson, &levels)
}

func main() {
	r := mux.NewRouter()
	r.Use(sessionMiddleware)
	for i := range levels {
		level := levels[i]
		s := r.Host(level.Host).Subrouter()
		s.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			session := r.Context().Value("session").(*sessions.Session)
			levelProgress := session.Values["levelProgress"].(int)
			if levelProgress < level.Index {
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
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
