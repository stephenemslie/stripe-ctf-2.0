data "google_container_registry_image" "image" {
  name   = var.name
}

resource "google_container_registry" "registry" {
}

resource "google_service_account" "level" {
  account_id = var.name
}

resource "google_cloud_run_service" "service" {
  name                       = var.name
  location                   = "us-central1"
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = data.google_container_registry_image.image.image_url
        env {
          name  = "GSM_PASSWORD_KEY"
          value = format("%s/versions/latest", var.secret.id)
        }
        dynamic "env" {
          for_each = var.env
          content {
            name  = env.key
            value = env.value
          }
        }
      }
      service_account_name = google_service_account.level.email
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
  location = var.proxy_service.location
  name     = "${var.name}.hack2012.app"

  metadata {
    namespace = var.proxy_service.project
  }

  spec {
    route_name = var.proxy_service.name
  }
}

resource "google_cloud_run_service_iam_member" "caller" {
  location = google_cloud_run_service.service.location
  project  = google_cloud_run_service.service.project
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.caller}"
}

resource "google_secret_manager_secret_iam_member" "secret" {
  provider  = google-beta
  secret_id = var.secret.name
  role      = "roles/secretmanager.secretAccessor"
  member    = format("serviceAccount:%s", google_service_account.level.email)
}

resource "google_storage_bucket_iam_member" "storage_viewer" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.objectViewer"
  member = format("serviceAccount:%s", google_service_account.level.email)
}

output "service_url" {
  value = google_cloud_run_service.service.status[0].url
}
