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

# Cloud scheduler requires an app engine application to be present in the region
resource "google_app_engine_application" "app" {
  project     = "stripe-ctf-demo"
  location_id = "us-central"
}

data "google_client_config" "current" {
}

locals {
  ctfproxy_service = {
    name                 = google_cloud_run_service.ctfproxy.name
    project              = google_cloud_run_service.ctfproxy.project
    location             = google_cloud_run_service.ctfproxy.location
    service_account_name = google_service_account.ctfproxy.email
  }
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
  subdomain             = "level0"
  invokers              = ["serviceAccount:${google_service_account.ctfproxy.email}"]
}

module "level1" {
  source                = "./modules/level"
  name                  = "level1"
  secret                = google_secret_manager_secret.password[1]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
  subdomain             = "level1"
  invokers              = ["serviceAccount:${google_service_account.ctfproxy.email}"]
}

module "level2" {
  source                = "./modules/level"
  name                  = "level2"
  secret                = google_secret_manager_secret.password[2]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
  subdomain             = "level2"
  invokers = [
    "serviceAccount:${google_service_account.ctfproxy.email}",
    "serviceAccount:${module.level5.service.template[0].spec[0].service_account_name}"
  ]
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
  subdomain             = "level3"
  invokers              = ["serviceAccount:${google_service_account.ctfproxy.email}"]
}

module "level4_server" {
  source                = "./modules/level"
  name                  = "level4-server"
  secret                = google_secret_manager_secret.password[4]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
  subdomain             = "level4"
  invokers = [
    "serviceAccount:${google_service_account.ctfproxy.email}",
    "serviceAccount:${module.level4_browser.service.template[0].spec[0].service_account_name}"
  ]
}

module "level4_browser" {
  source        = "./modules/level"
  name          = "level4-browser"
  secret        = google_secret_manager_secret.password[4]
  proxy_service = local.ctfproxy_service
  memory        = "1024Mi"
  env = {
    URL           = module.level4_server.service.status[0].url,
    ENABLE_TOKENS = "1"
  }
  invokers = ["serviceAccount:${google_service_account.level4_browser_scheduler.email}"]
}

module "level5" {
  source                = "./modules/level"
  name                  = "level5"
  secret                = google_secret_manager_secret.password[5]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
  subdomain             = "level5"
  invokers              = ["serviceAccount:${google_service_account.ctfproxy.email}"]
}

module "level6_server" {
  source                = "./modules/level"
  name                  = "level6-server"
  secret                = google_secret_manager_secret.password[6]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
  subdomain             = "level6"
  invokers = [
    "serviceAccount:${google_service_account.ctfproxy.email}",
    "serviceAccount:${module.level6_browser.service.template[0].spec[0].service_account_name}"
  ]
}

module "level6_browser" {
  source        = "./modules/level"
  name          = "level6-browser"
  secret        = google_secret_manager_secret.password[6]
  proxy_service = local.ctfproxy_service
  env = {
    URL           = module.level6_server.service.status[0].url,
    ENABLE_TOKENS = "1"
  }
  invokers = ["serviceAccount:${google_service_account.level6_browser_scheduler.email}"]
}

module "level7" {
  source                = "./modules/level"
  name                  = "level7"
  secret                = google_secret_manager_secret.password[7]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
  subdomain             = "level7"
  invokers              = ["serviceAccount:${google_service_account.ctfproxy.email}"]
}

module "level8" {
  source                = "./modules/level"
  name                  = "level8"
  secret                = google_secret_manager_secret.password[8]
  proxy_service         = local.ctfproxy_service
  enable_domain_mapping = true
  subdomain             = "level8"
  invokers              = ["serviceAccount:${google_service_account.ctfproxy.email}"]
}
