package main

import (
	"context"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"
	"github.com/stephenemslie/stripe-ctf-2.0/ctfproxy/level"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	secretmanagerpb "google.golang.org/genproto/googleapis/cloud/secretmanager/v1"
)

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
	session := r.Context().Value("session").(*sessions.Session)
	t, _ := baseTemplate.Clone()
	t.ParseFiles("templates/index.html")
	data := struct {
		Handler       string
		Level         level.Level
		Levels        []*level.Level
		LevelProgress int
	}{"home", level.Level{Index: -1}, level.Levels, session.Values["levelProgress"].(int)}
	err := t.Execute(w, data)
	if err != nil {
		fmt.Println(err)
	}
}

func levelHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	levelIndex, _ := strconv.Atoi(vars["index"])
	currentLevel := level.Levels[levelIndex]
	session := r.Context().Value("session").(*sessions.Session)
	levelProgress := session.Values["levelProgress"].(int)
	if levelProgress < currentLevel.Index {
		http.Redirect(w, r, fmt.Sprintf("/levels/%d/unlock/", levelIndex), http.StatusFound)
		return
	}
	path := fmt.Sprintf("templates/levels/%d.html", currentLevel.Index)
	t, _ := baseTemplate.Clone()
	t.ParseFiles(path)
	data := struct {
		Handler       string
		Levels        []*level.Level
		Level         *level.Level
		LevelProgress int
	}{"level", level.Levels, currentLevel, levelProgress}
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
	json.NewEncoder(w).Encode(level.Levels[levelIndex])
}

func unlockLevelHandler(w http.ResponseWriter, r *http.Request) {
	session := r.Context().Value("session").(*sessions.Session)
	vars := mux.Vars(r)
	levelProgress := session.Values["levelProgress"].(int)
	levelIndex, _ := strconv.Atoi(vars["index"])
	currentLevel := level.Levels[levelIndex]
	if r.Method == http.MethodGet {
		if levelProgress >= levelIndex {
			http.Redirect(w, r, fmt.Sprintf("/levels/%d/", levelIndex), http.StatusFound)
		} else {
			t, _ := baseTemplate.Clone()
			t.ParseFiles("templates/locked.html")
			data := struct {
				Handler       string
				Levels        []*level.Level
				Level         *level.Level
				LevelProgress int
			}{"unlock", level.Levels, currentLevel, levelProgress}
			t.Execute(w, data)
		}
	} else if r.Method == http.MethodPost {
		if currentLevel.CheckPassword(r.FormValue("password")) {
			session.Values["levelProgress"] = currentLevel.Index + 1
			err := session.Save(r, w)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			currentLevel.Reset()
		}
		if currentLevel.Index == 8 {
			http.Redirect(w, r, fmt.Sprintf("/levels/flag/"), http.StatusFound)
		} else {
			http.Redirect(w, r, fmt.Sprintf("/levels/%d/", currentLevel.Index+1), http.StatusFound)
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
		Levels        []*level.Level
		Level         level.Level
		LevelProgress int
	}{"flag", level.Levels, level.Level{Index: -1}, levelProgress}
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
}

func main() {
	r := mux.NewRouter()
	r.Use(sessionMiddleware)
	for i := range level.Levels {
		level := level.Levels[i]
		s := r.Host(level.Host).Subrouter()
		s.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			session := r.Context().Value("session").(*sessions.Session)
			levelProgress := session.Values["levelProgress"].(int)
			if levelProgress < level.Index {
				http.Redirect(w, r, fmt.Sprintf("http://stripe-ctf:8000/levels/%d/unlock/", level.Index), http.StatusFound)
			} else {
				level.Proxy().ServeHTTP(w, r)
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
