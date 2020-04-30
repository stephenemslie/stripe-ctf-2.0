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
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level1" {
  source        = "./modules/level"
  name          = "level1"
  secret        = google_secret_manager_secret.password[1]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level2" {
  source        = "./modules/level"
  name          = "level2"
  secret        = google_secret_manager_secret.password[2]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level3" {
  source = "./modules/level"
  name   = "level3"
  secret = google_secret_manager_secret.password[3]
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
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level4_browser" {
  source        = "./modules/level"
  name          = "level4-browser"
  secret        = google_secret_manager_secret.password[4]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level5" {
  source        = "./modules/level"
  name          = "level5"
  secret        = google_secret_manager_secret.password[5]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level6_server" {
  source        = "./modules/level"
  name          = "level6-server"
  secret        = google_secret_manager_secret.password[6]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level6_browser" {
  source        = "./modules/level"
  name          = "level6-browser"
  secret        = google_secret_manager_secret.password[6]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level7" {
  source        = "./modules/level"
  name          = "level7"
  secret        = google_secret_manager_secret.password[7]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}

module "level8" {
  source        = "./modules/level"
  name          = "level8"
  secret        = google_secret_manager_secret.password[8]
  caller        = google_service_account.ctfproxy.email
  proxy_service = google_cloud_run_service.ctfproxy
}
