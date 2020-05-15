
# schedule to trigger level6_browser every minute, using a service account
# with permission to invoke level6_browser

resource "google_service_account" "level6_browser_scheduler" {
  account_id = "level6-browser-scheduler"
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

