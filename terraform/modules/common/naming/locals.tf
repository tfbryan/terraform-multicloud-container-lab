
locals {

  #----------------------------------------------------------------------------------------------------
  #
  # Determine which naming profile to render
  #
  #----------------------------------------------------------------------------------------------------

  profile = (
    var.role != null ? "compute" :
    var.compact == true ? "compact" :
    "standard"
  )

  #----------------------------------------------------------------------------------------------------
  #
  # Drop the region if global is true, otherwise use the region code
  #
  #----------------------------------------------------------------------------------------------------

  region = var.global == true ? null : var.name_context.region.code

  #----------------------------------------------------------------------------------------------------
  #
  # Generate the random suffix if the flag was true and the profile is not compute
  #
  #----------------------------------------------------------------------------------------------------

  random_suffix_enabled = var.random_suffix == true && local.profile != "compute"
  random_suffix         = local.random_suffix_enabled ? random_string.suffix[0].result : null

  #----------------------------------------------------------------------------------------------------
  #
  # Define the standard profile components, used for both standard and compact profiles
  #
  #----------------------------------------------------------------------------------------------------

  standard_components = compact([
    var.name_context.cloud.code,
    var.name_context.account.code,
    var.name_context.project.code,
    var.name_context.environment.code,
    local.region,
    var.type,
    var.descriptor,
    local.random_suffix
  ])

  #----------------------------------------------------------------------------------------------------
  #
  # Format each profile string representation. Examples show full possible components,
  # but several are optional and will be dropped if null. The compact profile drops the hyphens,
  # but otherwise is the same as standard.
  #
  # Standard: aw-5309-mc-lab-ue1-sg-common-e456
  # Compact: aw5309mclabue1sgcommone456
  # Compute: aw5309-web1101
  #
  #----------------------------------------------------------------------------------------------------

  standard_name = lower(
    join("-", local.standard_components)
  )

  compact_name = lower(
    join("", local.standard_components)
  )

  compute_name = (
    var.role == null ? null : lower(
      format("%s%s-%s%s%s%s",
        var.name_context.cloud.code,
        var.name_context.account.code,
        var.role,
        var.name_context.region.id,
        var.name_context.environment.id,
        var.instance
      )
    )
  )

  #----------------------------------------------------------------------------------------------------
  #
  # Assign the final name based on the determined profile
  #
  #----------------------------------------------------------------------------------------------------

  name = (
    local.profile == "compute" ? local.compute_name :
    local.profile == "compact" ? local.compact_name :
    local.standard_name
  )
}
