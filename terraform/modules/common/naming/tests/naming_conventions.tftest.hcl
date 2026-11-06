#----------------------------------------------------------------------------------------------------
#
# File /tests/naming_conventions.tftest.hcl
#
#----------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------
#
# Global test configurations passed to all test cases
#
#----------------------------------------------------------------------------------------------------

variables {
  name_context = {
    cloud = {
      name = "Amazon Web Services"
      code = "aw"
    }
    account = {
      id   = "18675309"
      code = "5309"
    }
    project = {
      name = "Multicloud Container Lab"
      code = "mc"
    }
    environment = {
      name = "lab"
      code = "lab"
      id   = "0"
    }
    region = {
      name = "ue-east-1"
      code = "ue1"
      id   = "1"
    }
  }
}

#----------------------------------------------------------------------------------------------------
#
# Positive test cases for random_suffix state
#
#----------------------------------------------------------------------------------------------------

run "random_suffix_state_created" {
  command   = apply
  state_key = "random-suffix-stability"

  variables {
    type          = "sg"
    random_suffix = true
  }

  assert {
    condition     = can(regex("-[a-z0-9]{4}$", output.resource_name))
    error_message = "Random suffix was not generated with the expected format"
  }
}

run "random_suffix_stable_across_plans" {
  command   = plan
  state_key = "random-suffix-stability"

  variables {
    type          = "sg"
    random_suffix = true
  }

  assert {
    condition     = output.resource_name == run.random_suffix_state_created.resource_name
    error_message = "Random suffix changed while its random resource remained in state"
  }
}

#----------------------------------------------------------------------------------------------------
#
# Positive test cases for naming conventions
#
#----------------------------------------------------------------------------------------------------

run "standard_naming_full" {
  command = apply

  variables {
    type          = "sg"
    descriptor    = "common"
    random_suffix = true
  }

  assert {
    condition     = can(regex("aw-5309-mc-lab-ue1-sg-common-[a-z0-9]{4}$", output.resource_name))
    error_message = "Standard naming convention with all components failed to match the expected pattern"
  }
}

run "compact_naming_full" {
  command = apply

  variables {
    type          = "sg"
    descriptor    = "common"
    random_suffix = true
    compact       = true
  }

  assert {
    condition     = can(regex("aw5309mclabue1sgcommon[a-z0-9]{4}$", output.resource_name))
    error_message = "Compact naming convention with all components failed to match the expected pattern"
  }
}

run "standard_naming_no_random_suffix" {
  command = plan

  variables {
    type       = "sg"
    descriptor = "common"
  }

  assert {
    condition     = output.resource_name == "aw-5309-mc-lab-ue1-sg-common"
    error_message = "Standard naming convention without random_suffix did not match the expected output"
  }
}

run "standard_naming_uppercase_type" {
  command = plan

  variables {
    type = "SG"
  }

  assert {
    condition     = output.resource_name == "aw-5309-mc-lab-ue1-sg"
    error_message = "Uppercase resource type was not normalized to lowercase"
  }
}

run "standard_naming_null_random_suffix" {
  command = plan

  variables {
    type          = "sg"
    random_suffix = null
  }

  assert {
    condition     = output.resource_name == "aw-5309-mc-lab-ue1-sg"
    error_message = "Null random_suffix should be treated as disabled"
  }

  assert {
    condition     = length(random_string.suffix) == 0
    error_message = "Null random_suffix should not create a random_id resource"
  }
}

run "compact_naming_no_random_suffix" {
  command = plan

  variables {
    type       = "sg"
    descriptor = "common"
    compact    = true
  }

  assert {
    condition     = output.resource_name == "aw5309mclabue1sgcommon"
    error_message = "Compact naming convention without random_suffix did not match the expected output"
  }
}

run "standard_naming_no_descriptor" {
  command = apply

  variables {
    type          = "sg"
    random_suffix = true
  }

  assert {
    condition     = can(regex("aw-5309-mc-lab-ue1-sg-[a-z0-9]{4}$", output.resource_name))
    error_message = "Standard naming convention without descriptor failed to match the expected pattern"
  }
}

run "compact_naming_no_descriptor" {
  command = apply

  variables {
    type          = "sg"
    random_suffix = true
    compact       = true
  }

  assert {
    condition     = can(regex("aw5309mclabue1sg[a-z0-9]{4}$", output.resource_name))
    error_message = "Compact naming convention without descriptor failed to match the expected pattern"
  }
}

run "standard_naming_no_region" {
  command = apply

  variables {
    type          = "role"
    descriptor    = "web"
    random_suffix = true
    global        = true
  }

  assert {
    condition     = can(regex("aw-5309-mc-lab-role-web-[a-z0-9]{4}$", output.resource_name))
    error_message = "Standard naming convention without region failed to match the expected pattern"
  }
}

run "Compact_naming_no_region" {
  command = apply

  variables {
    type          = "role"
    descriptor    = "web"
    random_suffix = true
    global        = true
    compact       = true
  }

  assert {
    condition     = can(regex("aw5309mclabroleweb[a-z0-9]{4}$", output.resource_name))
    error_message = "Compact naming convention without region failed to match the expected pattern"
  }
}

run "standard_naming_minimal" {
  command = plan

  variables {
    type   = "cloudfront"
    global = true
  }

  assert {
    condition     = output.resource_name == "aw-5309-mc-lab-cloudfront"
    error_message = "Standard naming convention without region, descriptor, and random_suffix failed to match the expected pattern"
  }
}

run "compact_naming_minimal" {
  command = plan

  variables {
    type    = "cloudfront"
    global  = true
    compact = true
  }

  assert {
    condition     = output.resource_name == "aw5309mclabcloudfront"
    error_message = "Standard naming convention without region, descriptor, and random_suffix failed to match the expected pattern"
  }
}

run "compute_resource_naming" {
  command = plan

  variables {
    type     = "vm"
    role     = "web"
    instance = "01"
  }

  assert {
    condition     = output.resource_name == "aw5309-web1001"
    error_message = "Compute naming convention failed to match the expected pattern"
  }
}

run "compute_resource_naming_with_global" {
  command = plan

  variables {
    type     = "vm"
    role     = "web"
    instance = "01"
    global   = true
  }

  assert {
    condition     = output.resource_name == "aw5309-web1001"
    error_message = "Compute naming convention with global = true failed to match the expected pattern"
  }
}

run "compute_resource_naming_with_random" {
  command = plan

  variables {
    type          = "vm"
    role          = "web"
    instance      = "01"
    random_suffix = true
    compact       = true
  }

  assert {
    condition     = output.resource_name == "aw5309-web1001"
    error_message = "Compute naming convention with random_suffix = true failed to match the expected pattern"
  }

  assert {
    condition     = length(random_string.suffix) == 0
    error_message = "Compute naming must not create a random_string resource"
  }
}

#----------------------------------------------------------------------------------------------------
#
# Negative test cases for naming conventions
#
#----------------------------------------------------------------------------------------------------

run "compute_resource_naming_with_descriptor" {
  command = plan

  variables {
    type       = "vm"
    role       = "web"
    instance   = "01"
    descriptor = "common"
  }

  expect_failures = [
    var.descriptor
  ]
}

run "standard_naming_invalid_descriptor" {
  command = plan

  variables {
    type       = "sg"
    descriptor = "commonresource"
  }

  expect_failures = [
    var.descriptor
  ]
}

run "standard_naming_invalid_type" {
  command = plan

  variables {
    type       = "cfdistribution"
    descriptor = "common"
  }

  expect_failures = [
    var.type
  ]
}

run "standard_naming_invalid_type_characters" {
  command = plan

  variables {
    type = "s_g"
  }

  expect_failures = [
    var.type
  ]
}

run "compute_resource_naming_invalid_role" {
  command = plan

  variables {
    type     = "vm"
    role     = "web server"
    instance = "01"
  }

  expect_failures = [
    var.role
  ]
}

run "compute_resource_naming_invalid_instance" {
  command = plan

  variables {
    type     = "vm"
    role     = "web"
    instance = "00"
  }

  expect_failures = [
    var.instance
  ]
}

run "compute_resource_naming_without_instance" {
  command = plan

  variables {
    type = "vm"
    role = "web"
  }

  expect_failures = [
    var.role
  ]
}

run "compute_resource_naming_without_role" {
  command = plan

  variables {
    type     = "vm"
    instance = "01"
  }

  expect_failures = [
    var.role
  ]
}
