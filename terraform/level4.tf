
# schedule to trigger level4_browser every minute, using a service account
# with permission to invoke level4_browser

resource "google_service_account" "level4_browser_scheduler" {
  account_id = "level4-browser-scheduler"
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

