
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
          value = module.level0.service.status[0].url
        }
        env {
          name  = "LEVEL1_INTERNAL_URL"
          value = module.level1.service.status[0].url
        }
        env {
          name  = "LEVEL2_INTERNAL_URL"
          value = module.level2.service.status[0].url
        }
        env {
          name  = "LEVEL3_INTERNAL_URL"
          value = module.level3.service.status[0].url
        }
        env {
          name  = "LEVEL4_INTERNAL_URL"
          value = module.level4_server.service.status[0].url
        }
        env {
          name  = "LEVEL5_INTERNAL_URL"
          value = module.level5.service.status[0].url
        }
        env {
          name  = "LEVEL6_INTERNAL_URL"
          value = module.level6_server.service.status[0].url
        }
        env {
          name  = "LEVEL7_INTERNAL_URL"
          value = module.level7.service.status[0].url
        }
        env {
          name  = "LEVEL8_INTERNAL_URL"
          value = module.level8.service.status[0].url
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

