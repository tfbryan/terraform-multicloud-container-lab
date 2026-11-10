variable "project" {
  description = "Object contains the projet name and code"
  type = object({
    name = string
    code = string
  })

  validation {
    condition = alltrue([
      can(regex("^[a-z0-9]{2,10}$", var.project.code))
    ])
    error_message = "Project.code must be 2-10 characters, lowercase alphanumeric"
  }
}

variable "tag_prefix" {
  description = "Custom prefix for tags"
  type        = string

  validation {
    condition = alltrue([
      can(regex("^[a-z0-9]{2,5}$", var.tag_prefix))
    ])
    error_message = "tag_prefix must be 2-5 characters, lowercase alphanumeric"
  }
}

variable "environment_list" {
  description = "Environment catalog containing name, code, and id"
  type = object({
    lab = object({
      name = string
      code = string
      id   = string
    })
    dev = object({
      name = string
      code = string
      id   = string
    })
    tst = object({
      name = string
      code = string
      id   = string
    })
    stg = object({
      name = string
      code = string
      id   = string
    })
    prd = object({
      name = string
      code = string
      id   = string
    })
  })

  validation {
    condition = alltrue([
      for env in values(var.environment_list) :
      can(regex("^[a-z0-9]{2,3}$", env.code)) &&
      can(regex("^[0-9]{1}$", env.id))
    ])
    error_message = "Environment codes must be 2-3, lowercase alphanumeric characters. Environment ids must be single digits"
  }
}

variable "server_role" {
  description = "List of server roles for naming"
  type = object({
    web = object({
      name = string
      code = string
    })
    app = object({
      name = string
      code = string
    })
    dns = object({
      name = string
      code = string
    })
  })

  validation {
    condition = alltrue([
      for role in values(var.server_role) :
      can(regex("^[a-z]{3,4}$", role.code))
    ])
    error_message = "Server role code must be 3-4 lowercase letters."
  }
}

variable "environment" {
  description = "Environment key that maps to a specific environment index"
  type        = string
}

variable "github_owner" {
  description = "The GitHub organization or owner of the repository"
  type        = string
}

variable "github_repo" {
  description = "The GitHub repository name"
  type        = string
}


variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)

  validation {
    condition = alltrue([
      for key in keys(var.common_tags) :
      length(key) >= 2 &&
      length(key) <= 40 &&
      can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", key))
    ])
    error_message = "common_tags keys must be 2-40 characters, lowercase alphanumeric, and may contain single hyphens as segement delimeters"
  }

  # Additional validation could be done to help expose non-common tags from being incorrectly added to common_tags
}

variable "aws_region" {
  description = "The AWS region properties where resources will be deployed"
  type = object({
    primary = object({
      name = string
      code = string
      id   = string
    })
    secondary = object({
      name = string
      code = string
      id   = string
    })
  })

  validation {
    condition = alltrue([
      for region in values(var.aws_region) :
      can(regex("^(us|eu|ap|sa|ca|me|af|il|mx)-[a-z]+(-[a-z]+)*-[0-9]{1}$", region.name)) &&
      can(regex("^[a-z0-9]{3}$", region.code)) &&
      can(regex("^[0-9]{1}$", region.id))
    ])
    error_message = "Region name must match defined 2 character, lowercase alpha prefix, + alpha characters + single digit all separated by hyphens. Region code must be 3 character, lowercase alphanumeric. Region id must be a single digit, typically 1 for Primary and 2 for Secondary, etc."
  }
}

variable "cloud" {
  description = "Cloud provider properties"
  type = object({
    name = string
    code = string
  })

  validation {
    condition = contains(
      ["aw"],
      var.cloud.code
    )
    error_message = "AWS cloud code must = aw and is case sensitive"
  }
}
