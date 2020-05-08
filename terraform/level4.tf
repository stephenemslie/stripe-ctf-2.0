
# level4_server can be invoked by level4_browser
resource "google_cloud_run_service_iam_member" "level4_browser_invoker" {
  location = module.level4_server.service.location
  project  = module.level4_server.service.project
  service  = module.level4_server.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${module.level4_browser.service.template[0].spec[0].service_account_name}"
}

# schedule to trigger level4_browser every minute, using a service account
# with permission to invoke level4_browser

resource "google_service_account" "level4_browser_scheduler" {
  account_id = "level4-browser-scheduler"
}

resource "google_cloud_run_service_iam_member" "level4_browser_sheduler_invoker" {
  location = module.level4_browser.service.location
  project  = module.level4_browser.service.project
  service  = module.level4_browser.service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.level4_browser_scheduler.email}"
}

resource "google_cloud_scheduler_job" "level4_browser" {
  name             = "level4-browser-trigger"
  schedule         = "* * * * *"
  time_zone        = "America/New_York"
  attempt_deadline = "320s"
  depends_on       = [google_app_engine_application.app]

  http_target {
    http_method = "POST"
    uri         = "${module.level4_browser.service.status[0].url}/"

    oidc_token {
      service_account_email = google_service_account.level4_browser_scheduler.email
    }

  }

}

