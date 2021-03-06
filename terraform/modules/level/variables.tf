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

variable "memory" {
  type    = string
  default = "256M"
}

variable "enable_domain_mapping" {
  type    = bool
  default = false
}

variable "subdomain" {
  type    = string
  default = ""
}

variable "invokers" {
  type = list(string)
}
