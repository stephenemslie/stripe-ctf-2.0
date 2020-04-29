package main

import (
	"context"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"

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
	parsedExternalURL, _ := url.Parse(os.Getenv("CTFPROXY_EXTERNAL_URL"))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		session, _ := sessionStore.Get(r, "ctf")
		session.Options.Domain = parsedExternalURL.Hostname()
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

func levelJsonHandler(w http.ResponseWriter, r *http.Request) {
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
		}
		if currentLevel.Index == 8 {
			http.Redirect(w, r, fmt.Sprintf("/flag/"), http.StatusFound)
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
	secret := os.Getenv("SECRET")
	gsm_prefix := "GSM:"
	if strings.HasPrefix(secret, gsm_prefix) {
		ctx := context.Background()
		client, err := secretmanager.NewClient(ctx)
		if err != nil {
			log.Fatalf("failed to setup secrets client: %v", err)
		}
		secret_key := secret[len(gsm_prefix):]
		accessRequest := &secretmanagerpb.AccessSecretVersionRequest{
			Name: secret_key,
		}
		result, err := client.AccessSecretVersion(ctx, accessRequest)
		if err != nil {
			log.Fatalf("failed to access secret version: %v", err)
		}
		secret = string(result.Payload.Data)
	}
	sessionStore = sessions.NewCookieStore([]byte(secret))
	baseTemplate, _ = template.ParseGlob("templates/layout/*.html")
}

func main() {
	r := mux.NewRouter()
	r.Use(sessionMiddleware)
	for i := range level.Levels {
		level := level.Levels[i]
		externalURL, _ := level.GetExternalURL()
		parsedExternalURL, _ := url.Parse(externalURL)
		s := r.Host(parsedExternalURL.Host).Subrouter()
		s.PathPrefix("/").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			session := r.Context().Value("session").(*sessions.Session)
			levelProgress := session.Values["levelProgress"].(int)
			if levelProgress < level.Index {
				ctfproxyURL := os.Getenv("CTFPROXY_EXTERNAL_URL")
				redirectURL := fmt.Sprintf("%s/levels/%d/", ctfproxyURL, level.Index)
				http.Redirect(w, r, redirectURL, http.StatusFound)
			} else {
				level.Proxy().ServeHTTP(w, r)
			}
		})
	}
	r.PathPrefix("/static/").Handler(http.StripPrefix("/static/", http.FileServer(http.Dir(os.Getenv("STATIC_DIR")))))
	r.HandleFunc("/", indexHandler).Methods("GET")
	r.HandleFunc("/levels/{index:[0-8]}/unlock/", unlockLevelHandler).Methods("GET", "POST")
	r.HandleFunc("/levels/{index:[0-8]}.json", levelJsonHandler).Methods("GET")
	r.HandleFunc("/levels/{index:[0-8]}/", levelHandler).Methods("GET")
	r.HandleFunc("/flag/", flagHandler).Methods("GET")
	http.Handle("/", r)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}
	fmt.Printf("Listening on port %s\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
