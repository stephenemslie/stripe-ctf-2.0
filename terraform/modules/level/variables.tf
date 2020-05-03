variable "name" {
  type = string
}

variable "secret" {
  type = object({
    id   = string
    name = string
  })
}

variable "env" {
  type    = map(string)
  default = {}
}

variable "proxy_service" {
  type = object({
    name                 = string
    project              = string
    location             = string
    service_account_name = string
  })
}

variable "enable_domain_mapping" {
  type    = bool
  default = false
}
