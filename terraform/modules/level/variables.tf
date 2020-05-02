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

variable "caller" {
  type = string
}

variable "proxy_service" {
  type = object({
    name     = string
    project  = string
    location = string
  })
}

variable "enable_domain_mapping" {
  type    = bool
  default = false
}
