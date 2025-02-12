locals {
  # Compound Scope Identifier
  csi = replace(
    format("%s-%s-%s-%s", var.project, var.environment, var.component, var.name),
    "_",
    "",
  )

  default_tags = merge(
    var.default_tags,
    {
      Module = var.module
      Name   = local.csi
    },
  )
}
