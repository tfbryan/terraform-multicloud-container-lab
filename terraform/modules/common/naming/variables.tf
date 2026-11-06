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

variable "type" {
  description = "Type of resource being created"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{2,10}$", var.type))
    error_message = "Resource type must be 2-10 alphanumeric characters; rendered names use lowercase."
  }
}

variable "descriptor" {
  description = "Optional descriptor value is used for resource uniqness, e.g. common, web, app, etc. Must be 3-10 characters."
  type        = string
  default     = null

  validation {
    condition = (
      var.descriptor == null || (
        var.role == null && can(regex("^[a-z0-9]{3,10}$", var.descriptor))
      )
    )
    error_message = "Descriptor must be 3-10 lowercase alphanumeric characters and is only supported for general resources."
  }
}

variable "random_suffix" {
  description = "Optional flag to append for resource uniqueness"
  type        = bool
  default     = false
}

variable "compact" {
  description = "Optional flag to produce a compact resource name that does not include hyphens."
  type        = bool
  default     = false
}

variable "role" {
  description = "Optional role value is used for compute resources, used to differentiate between server types, e.g. web, app, dns, etc. Must be paired with instance for compute resources."
  type        = string
  default     = null

  validation {
    condition = (
      var.role == null ? var.instance == null :
      var.instance != null && can(regex("^[a-z]{3,4}$", var.role))
    )

    error_message = "Role requires instance when used for compute naming, and must be 3-4 lowercase letters."
  }
}

variable "global" {
  description = "Optional flag to indicate that the resource is global and should not include the region value in the resource name."
  type        = bool
  default     = false
}

variable "instance" {
  description = "Optional instance value is used for compute resource uniqueness, 01, 02, etc. Must be present if role is used for compute resources."
  type        = string
  default     = null

  validation {
    condition = (
      var.instance == null || can(regex("^(0[1-9]|[1-9][0-9])$", var.instance))
    )
    error_message = "Instance requires role when used for compute naming, and must be between 01-99."
  }
}
