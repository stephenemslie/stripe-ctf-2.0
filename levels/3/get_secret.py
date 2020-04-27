import sys
import argparse
from google.cloud import secretmanager

def get_secret(name):
    client = secretmanager.SecretManagerServiceClient()
    response = client.access_secret_version(name)
    payload = response.payload.data.decode('UTF-8')
    sys.stdout.write(payload)

if __name__ == "__main__":
    get_secret(sys.argv[1])
