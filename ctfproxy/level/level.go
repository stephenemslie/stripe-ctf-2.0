package level

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"cloud.google.com/go/compute/metadata"
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
	Port    int           `json:"port"`
	Name    string        `json:"name"`
	Emoji   string        `json:"emoji"`
	Sources []*SourceFile `json:"sources"`
}

func (l *Level) GetExternalURL() (string, error) {
	key := fmt.Sprintf("LEVEL%d_EXTERNAL_URL", l.Index)
	url := os.Getenv(key)
	if len(url) > 0 {
		return url, nil
	}
	return "", fmt.Errorf("Missing or empty %s environment variable", key)
}

func (l *Level) GetInternalURL() (string, error) {
	key := fmt.Sprintf("LEVEL%d_INTERNAL_URL", l.Index)
	url := os.Getenv(key)
	if len(url) > 0 {
		return url, nil
	}
	return "", fmt.Errorf("Missing or empty %s environment variable", key)
}

func (l *Level) CheckPassword(pwAttempt string) bool {
	pw := os.Getenv(fmt.Sprintf("LEVEL%d_PW", l.Index))
	gsm_prefix := "GSM:"
	if strings.HasPrefix(pw, gsm_prefix) {
		ctx := context.Background()
		client, err := secretmanager.NewClient(ctx)
		if err != nil {
			log.Fatalf("failed to setup secrets client: %v", err)
		}
		secret_key := pw[len(gsm_prefix):]
		accessRequest := &secretmanagerpb.AccessSecretVersionRequest{
			Name: secret_key,
		}
		result, err := client.AccessSecretVersion(ctx, accessRequest)
		if err != nil {
			log.Fatalf("failed to access secret version: %v", err)
		}
		pw = string(result.Payload.Data)
	}
	return (pw == pwAttempt)
}

func (l *Level) Proxy() *httputil.ReverseProxy {
	targetURL, err := l.GetInternalURL()
	u, err := url.Parse(targetURL)
	if err != nil {
		log.Fatalf("%s is not valid", targetURL)
	}
	proxy := httputil.NewSingleHostReverseProxy(u)
	if os.Getenv("ENABLE_PROXY_TOKEN") != "1" {
		return proxy
	}
	originalDirector := proxy.Director
	proxy.Director = func(r *http.Request) {
		originalDirector(r)

		// originalDirector doesn't set the Host header, but this is required
		// by Google Cloud Run.
		r.Host = r.URL.Host

		// originalDirector doesn't set X-Forwarded-Host, but this is required
		// to ensure that downstread redirects use the external URL
		forwardedHost, _ := l.GetExternalURL()
		forwardedHostURL, _ := url.Parse(forwardedHost)
		r.Header.Set("X-Forwarded-Host", forwardedHostURL.Hostname())

		// levels require authorization as the ctfproxy service account
		tokenURL := fmt.Sprintf("/instance/service-accounts/default/identity?audience=%s", r.URL.String())
		idToken, err := metadata.Get(tokenURL)
		if err != nil {
			fmt.Printf("metadata.Get: failed to query id_token: %+v\n", err)
		}
		r.Header.Set("Authorization", fmt.Sprintf("Bearer %s", idToken))
	}
	return proxy
}

// Next returns the next level and an error if there isn't one
func (l *Level) Next() (*Level, error) {
	var nextLevel *Level
	index := l.Index + 1
	if index >= len(Levels) {
		return nextLevel, fmt.Errorf("No such level %d", index)
	}
	nextLevel = Levels[index]
	return nextLevel, nil
}

var (
	Levels []*Level
)

func init() {
	path := filepath.Join("/usr/src/app", "levels.json")
	levelsJson, _ := ioutil.ReadFile(path)
	json.Unmarshal(levelsJson, &Levels)
}
