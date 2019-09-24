module "test" {
  source = "../../modules/example"

  # GENERAL
  project      = var.project
  environment  = var.environment
  component    = var.component
  default_tags = local.default_tags

  # SPECIFIC
  # ...
}
