variable "name" {
  type = string
}

variable "secret" {
  type = object({
    id   = string
    name = string
  })
}

variable "digest" {
  type = string
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
