
# level6_server can be invoked by level6_browser
resource "google_cloud_run_service_iam_member" "level6_browser_invoker" {
  location = module.level6_server.service.location
  project  = module.level6_server.service.project
  service  = module.level6_server.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${module.level6_browser.service.template[0].spec[0].service_account_name}"
}

# schedule to trigger level6_browser every minute, using a service account
# with permission to invoke level6_browser

resource "google_service_account" "level6_browser_scheduler" {
  account_id = "level6-browser-scheduler"
}

resource "google_cloud_run_service_iam_member" "level6_browser_sheduler_invoker" {
  location = module.level6_browser.service.location
  project  = module.level6_browser.service.project
  service  = module.level6_browser.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.level6_browser_scheduler.email}"
}

resource "google_cloud_scheduler_job" "level6_browser" {
  name             = "level6-browser-trigger"
  schedule         = "* * * * *"
  time_zone        = "America/New_York"
  attempt_deadline = "320s"
  depends_on       = [google_app_engine_application.app]

  http_target {
    http_method = "POST"
    uri         = "${module.level6_browser.service.status[0].url}/"

    oidc_token {
      service_account_email = google_service_account.level6_browser_scheduler.email
    }

  }

}

