data "google_container_registry_image" "image" {
  name = var.name
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

        resources {
          limits = {
            memory = var.memory
            cpu    = "1000m"
          }
        }

      }
      service_account_name = google_service_account.level.email
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
  count    = var.enable_domain_mapping ? 1 : 0
  location = var.proxy_service.location
  name     = "${var.subdomain}.hack2012.app"

  metadata {
    namespace = var.proxy_service.project
  }

  spec {
    route_name = var.proxy_service.name
  }
}

resource "google_cloud_run_service_iam_binding" "caller" {
  location = google_cloud_run_service.service.location
  project  = google_cloud_run_service.service.project
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  members  = var.invokers
}

resource "google_secret_manager_secret_iam_member" "secret" {
  provider  = google-beta
  secret_id = var.secret.name
  role      = "roles/secretmanager.secretAccessor"
  member    = format("serviceAccount:%s", google_service_account.level.email)
}

resource "google_secret_manager_secret_iam_member" "caller" {
  provider  = google-beta
  secret_id = var.secret.name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.proxy_service.service_account_name}"
}

resource "google_storage_bucket_iam_member" "storage_viewer" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.objectViewer"
  member = format("serviceAccount:%s", google_service_account.level.email)
}

output "service" {
  value = google_cloud_run_service.service
}
