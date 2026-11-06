variable "name_context" {
  description = "Collection of objects used to assemble resource names in a consistent manner"
  type = object({
    cloud = object({
      name = string
      code = string
    })
    account = object({
      id   = string
      code = string
    })
    project = object({
      name = string
      code = string
    })
    environment = object({
      name = string
      code = string
      id   = string
    })
    region = object({
      name = string
      code = string
      id   = string
    })
  })
}

variable "tags" {
  description = "Metadata key/values"
  type        = map(string)
}
