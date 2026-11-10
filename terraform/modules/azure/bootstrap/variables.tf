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

variable "github_owner" {
  description = "The GitHub organization or owner of the repository"
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name"
  type        = string
}

variable "tags" {
  description = "Metadata key/values"
  type        = map(string)
}
