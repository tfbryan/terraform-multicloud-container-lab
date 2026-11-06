#----------------------------------------------------------------------------------------------------
#
# Project name and code for tags and name schema. Project.code must be between 2-10 characters [a-z0-9]{2,10}, and as short as possible
#
#----------------------------------------------------------------------------------------------------

project = {
  name = "multicloud"
  code = "mc"
}

#----------------------------------------------------------------------------------------------------
#
# GitHub repository information
#
#----------------------------------------------------------------------------------------------------

github_owner = "tfbryan"
github_repo  = "terraform-multicloud-container-lab"

#----------------------------------------------------------------------------------------------------
#
# Establish an optional organizational tag prefix that will be applied in locals.tf. Short but descriptive is best.
#
#----------------------------------------------------------------------------------------------------

tag_prefix = "tfb"

#----------------------------------------------------------------------------------------------------
#
# Common tags for all resources
#
#----------------------------------------------------------------------------------------------------

common_tags = {
  managed-by = "terraform"
  repository = "terraform-multicloud-container-lab"
}

#----------------------------------------------------------------------------------------------------
#
# Standardized environment catalog. Environment.code must be 2-3 characters [a-z0-9]{2,3}. Environment.id must be  single digit [0-9].
#
#----------------------------------------------------------------------------------------------------

environment_list = {
  lab = {
    name = "lab"
    code = "lab"
    id   = "0"
  }
  dev = {
    name = "development"
    code = "dev"
    id   = "1"
  }
  tst = {
    name = "test"
    code = "tst"
    id   = "2"
  }
  stg = {
    name = "staging"
    code = "stg"
    id   = "3"
  }
  prd = {
    name = "production"
    code = "prd"
    id   = "4"
  }
}

#----------------------------------------------------------------------------------------------------
#
# Server catalog for standardized server roles. Server_role code must be
#
#----------------------------------------------------------------------------------------------------

server_role = {
  web = {
    name = "webserver"
    code = "web"
  }
  app = {
    name = "appserver"
    code = "app"
  }
  dns = {
    name = "nameserver"
    code = "dns"
  }
}
