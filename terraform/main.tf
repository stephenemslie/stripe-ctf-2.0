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

resource "google_storage_bucket" "ctfproxy_static" {
  name               = "ctfproxy-static"
  bucket_policy_only = true
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_binding" "ctfproxy_static_public" {
  bucket = google_storage_bucket.ctfproxy_static.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers"
  ]
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

data "google_container_registry_image" "ctfproxy" {
  name = "ctfproxy"
}


resource "google_cloud_run_service" "ctfproxy" {
  name                       = "ctfproxy"
  location                   = "us-central1"
  autogenerate_revision_name = true
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"]
    ]
  }

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
        dynamic "env" {
          for_each = toset([0, 1, 2, 3, 4, 5, 6, 7, 8])
          content {
            name  = "LEVEL${env.value}_EXTERNAL_URL"
            value = "https://level${env.value}.hack2012.app"
          }
        }
        env {
          name  = "LEVEL0_INTERNAL_URL"
          value = module.level0.service_url
        }
        env {
          name  = "LEVEL1_INTERNAL_URL"
          value = module.level1.service_url
        }
        env {
          name  = "LEVEL2_INTERNAL_URL"
          value = module.level2.service_url
        }
        env {
          name  = "LEVEL3_INTERNAL_URL"
          value = module.level3.service_url
        }
        env {
          name  = "LEVEL4_INTERNAL_URL"
          value = module.level4_server.service_url
        }
        env {
          name  = "LEVEL5_INTERNAL_URL"
          value = module.level5.service_url
        }
        env {
          name  = "LEVEL6_INTERNAL_URL"
          value = module.level6_server.service_url
        }
        env {
          name  = "LEVEL7_INTERNAL_URL"
          value = module.level7.service_url
        }
        env {
          name  = "LEVEL8_INTERNAL_URL"
          value = module.level8.service_url
        }
        env {
          name  = "CTFPROXY_EXTERNAL_URL"
          value = "https://hack2012.app"
        }
        env {
          name  = "LEVELCODE"
          value = "/usr/src/levels"
        }
        env {
          name  = "ENABLE_PROXY_TOKEN"
          value = "1"
        }
        env {
          name  = "STATIC_URL"
          value = "https://storage.googleapis.com/${google_storage_bucket.ctfproxy_static.name}/static"
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
        "autoscaling.knative.dev/maxScale"  = "1",
        "client.knative.dev/user-image"     = ""
        "run.googleapis.com/client-name"    = ""
        "run.googleapis.com/client-version" = ""
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

locals {
  ctfproxy_service = {
    name                 = google_cloud_run_service.ctfproxy.name
    project              = google_cloud_run_service.ctfproxy.project
    location             = google_cloud_run_service.ctfproxy.location
    service_account_name = google_service_account.ctfproxy.email
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
  source                = "./modules/level"
  name                  = "level0"
  secret                = google_secret_manager_secret.password[0]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level1" {
  source                = "./modules/level"
  name                  = "level1"
  secret                = google_secret_manager_secret.password[1]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level2" {
  source                = "./modules/level"
  name                  = "level2"
  secret                = google_secret_manager_secret.password[2]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level3" {
  source = "./modules/level"
  name   = "level3"
  secret = google_secret_manager_secret.password[3]
  env = {
    DATA_DIR = "/var/level/data"
  }
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level4_server" {
  source                = "./modules/level"
  name                  = "level4-server"
  secret                = google_secret_manager_secret.password[4]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level4_browser" {
  source        = "./modules/level"
  name          = "level4-browser"
  secret        = google_secret_manager_secret.password[4]
  proxy_service = local.ctfproxy_service
}

module "level5" {
  source                = "./modules/level"
  name                  = "level5"
  secret                = google_secret_manager_secret.password[5]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level6_server" {
  source                = "./modules/level"
  name                  = "level6-server"
  secret                = google_secret_manager_secret.password[6]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level6_browser" {
  source        = "./modules/level"
  name          = "level6-browser"
  secret        = google_secret_manager_secret.password[6]
  proxy_service = local.ctfproxy_service
}

module "level7" {
  source                = "./modules/level"
  name                  = "level7"
  secret                = google_secret_manager_secret.password[7]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}

module "level8" {
  source                = "./modules/level"
  name                  = "level8"
  secret                = google_secret_manager_secret.password[8]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
}
