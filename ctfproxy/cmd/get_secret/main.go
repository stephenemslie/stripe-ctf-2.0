package main

import (
	"context"
	"fmt"
	"log"

	"github.com/docopt/docopt-go"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	secretmanagerpb "google.golang.org/genproto/googleapis/cloud/secretmanager/v1"
)

func main() {
	usage := `get_secret

Usage:
	get_secret <name>

<name> 		Secret name in the form projects/PROJECT/secrets/SECRET/versions/VERSION`

	arguments, _ := docopt.ParseDoc(usage)
	name, _ := arguments.String("name")
	ctx := context.Background()
	client, err := secretmanager.NewClient(ctx)
	if err != nil {
		log.Fatalf("failed to setup secrets client: %v", err)
	}
	accessRequest := &secretmanagerpb.AccessSecretVersionRequest{
		Name: name,
	}
	result, err := client.AccessSecretVersion(ctx, accessRequest)
	if err != nil {
		log.Fatalf("failed to access secret version: %v", err)
	}
	value := result.Payload.Data
	fmt.Printf(string(value))
}
