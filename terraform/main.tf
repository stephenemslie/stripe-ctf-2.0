terraform {
  backend "gcs" {
    bucket = "tf-state-ctf"
    prefix = "terraform/state"
  }
}

provider "google" {

  project = "stripe-ctf-demo"
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {

  project = "stripe-ctf-demo"
  region  = "us-central1"
  zone    = "us-central1-c"
}

data "google_client_config" "current" {
}

resource "google_service_account" "ctfproxy" {
  account_id = "ctfproxy"
}

resource "google_secret_manager_secret" "ctfproxy_key" {
  provider  = google-beta
  secret_id = "ctfproxy-key"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_binding" "ctfproxy_key" {
  provider  = google-beta
  project   = google_secret_manager_secret.ctfproxy_key.project
  secret_id = google_secret_manager_secret.ctfproxy_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    format("serviceAccount:%s", google_service_account.ctfproxy.email)
  ]
}

variable "ctfproxy_image_digest" {
  type    = string
  default = "sha256:6b6106655aa87322d953b58d604fa74b6314ad0061c95f566ea96bc4b53ee32c"
}

data "google_container_registry_image" "ctfproxy" {
  name   = "ctfproxy"
  digest = var.ctfproxy_image_digest
}


resource "google_cloud_run_service" "ctfproxy" {
  name     = "ctfproxy"
  location = "us-central1"

  template {
    spec {
      containers {
        image = data.google_container_registry_image.ctfproxy.image_url
        env {
          name  = "STATIC_DIR"
          value = "/usr/src/app/static"
        }
        env {
          name  = "SECRET"
          value = format("GSM:%s/versions/latest", google_secret_manager_secret.ctfproxy_key.id)
        }
        dynamic "env" {
          for_each = toset([0, 1, 2, 3, 4, 5, 6, 7, 8])
          content {
            name  = "LEVEL${env.value}_PW"
            value = format("GSM:%s/versions/latest", google_secret_manager_secret.password[env.value].id)
          }
        }
        env {
          name  = "LEVEL0_EXTERNAL_URL"
          value = module.level0.service_url
        }
        env {
          name  = "LEVEL1_EXTERNAL_URL"
          value = module.level1.service_url
        }
        env {
          name  = "LEVEL2_EXTERNAL_URL"
          value = module.level2.service_url
        }
        env {
          name  = "LEVEL3_EXTERNAL_URL"
          value = module.level3.service_url
        }
        env {
          name  = "LEVEL4_EXTERNAL_URL"
          value = module.level4_server.service_url
        }
        env {
          name  = "LEVEL5_EXTERNAL_URL"
          value = module.level5.service_url
        }
        env {
          name  = "LEVEL6_EXTERNAL_URL"
          value = module.level6_server.service_url
        }
        env {
          name  = "LEVEL7_EXTERNAL_URL"
          value = module.level7.service_url
        }
        env {
          name  = "LEVEL8_EXTERNAL_URL"
          value = module.level8.service_url
        }
        env {
          name  = "LEVELCODE"
          value = "/usr/src/levels"
        }
        resources {
          limits = {
            memory = "512M"
            cpu    = "1000m"
          }
        }
      }
      service_account_name = google_service_account.ctfproxy.email
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_domain_mapping" "ctfproxy" {
  location = google_cloud_run_service.ctfproxy.location
  name     = "hack2012.app"

  metadata {
    namespace = google_cloud_run_service.ctfproxy.project
  }

  spec {
    route_name = google_cloud_run_service.ctfproxy.name
  }
}

resource "google_cloud_run_service_iam_binding" "invoker" {
  location = google_cloud_run_service.ctfproxy.location
  project  = google_cloud_run_service.ctfproxy.project
  service  = google_cloud_run_service.ctfproxy.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

resource "google_secret_manager_secret" "password" {
  provider  = google-beta
  count     = 9
  secret_id = "level${count.index}-password"
  replication {
    automatic = true
  }
}

module "level0" {
  source        = "./modules/level"
  name          = "level0"
  secret        = google_secret_manager_secret.password[0]
  digest        = "sha256:5c5a602447848c5846e35265acce83330713aac7a86fe65924246779501b3b75"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level1" {
  source        = "./modules/level"
  name          = "level1"
  secret        = google_secret_manager_secret.password[1]
  digest        = "sha256:bf015a293e820af6f840a36dab47ce878c0a464d19fa023021908c1feb1536ec"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level2" {
  source        = "./modules/level"
  name          = "level2"
  secret        = google_secret_manager_secret.password[2]
  digest        = "sha256:fbd86455f768723a74ed89c652526ff35e4a97975f9bd00edd9997d89878ee2c"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level3" {
  source = "./modules/level"
  name   = "level3"
  secret = google_secret_manager_secret.password[3]
  digest = "sha256:9d5e126a0a01db126f5d53b7b40abaafa2acc08eeffc25be941147f22531f26e"
  env = {
    DATA_DIR = "/var/level/data"
  }
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level4_server" {
  source        = "./modules/level"
  name          = "level4-server"
  secret        = google_secret_manager_secret.password[4]
  digest        = "sha256:ec1569edc44a1b5b41e9dc321970ec9d1336ac56762ed79c2730f4f2ce6c7fc8"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level4_browser" {
  source        = "./modules/level"
  name          = "level4-browser"
  secret        = google_secret_manager_secret.password[4]
  digest        = "sha256:ec2d4898042080344504569b24a0faef1681edeef0e09eb53d25927c8f9ad858"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level5" {
  source        = "./modules/level"
  name          = "level5"
  secret        = google_secret_manager_secret.password[5]
  digest        = "sha256:58c2a88dfdcbd7418fa6a9f8aff5fce48f9c42c65c5b2299a5dbb3c9a513b64a"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level6_server" {
  source        = "./modules/level"
  name          = "level6-server"
  secret        = google_secret_manager_secret.password[6]
  digest        = "sha256:b60525a95199a28fc7f4835c565582ba2fa259c228d6a4d7c2522a46e4018d98"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level6_browser" {
  source        = "./modules/level"
  name          = "level6-browser"
  secret        = google_secret_manager_secret.password[6]
  digest        = "sha256:786c3756add864e73ccc99d2cb19a87b2a310893543435462ad004e91157a525"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level7" {
  source        = "./modules/level"
  name          = "level7"
  secret        = google_secret_manager_secret.password[7]
  digest        = "sha256:97ecd22c5c8082dfb0bc3574b64e646ab48df7bf6264fdd12013c27d11620d73"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level8" {
  source        = "./modules/level"
  name          = "level8"
  secret        = google_secret_manager_secret.password[8]
  digest        = "sha256:1c8c18f6d86fac31ccabeb68e4c247eb10bb56f34d8372040463ace114837b9a"
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}
