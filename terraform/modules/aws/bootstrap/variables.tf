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

variable "max_session_duration" {
  description = "Maximum IAM role session duration in seconds"
  type        = number
  default     = 3600

  validation {
    condition = (
      var.max_session_duration >= 3600 &&
      var.max_session_duration <= 10800
    )
    error_message = "Session duration must be between 3600 - 10800 seconds."
  }
}
