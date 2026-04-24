# 002. Generated Backend Configuration

**Status:** Accepted

**Date:** 2026-04-24

## Context

Terraform's S3 backend configuration does not support variable interpolation.
This means the bucket name, key path, region, and other backend parameters
cannot be dynamically set within Terraform's HCL configuration. For a tool
that manages multiple projects, environments, regions, and AWS accounts, this
is a fundamental limitation.

tfscaffold solves this by generating a `backend_tfscaffold.tf` file at runtime
with the correct backend configuration, then cleaning it up on exit via a
`trap` statement.

This approach looks hacky — generating Terraform files at runtime is unusual
and the `trap` cleanup has caused confusion. However, it is the only viable
approach given Terraform's backend limitation.

## Decision

tfscaffold will continue to generate `backend_tfscaffold.tf` at runtime with
the correct S3 backend configuration. The file is:

1. Written before `terraform init`
2. Cleaned up on exit via `trap "rm -f ..." EXIT`
3. Listed in `.gitignore` to prevent accidental commits

This is **intentional** and must NOT be refactored into a static configuration.
Any attempt to remove this pattern would break the core multi-environment
multi-account capability of tfscaffold.

## Consequences

### Positive

- Supports arbitrary project/environment/region/account combinations
- No manual backend configuration required per component
- State file paths are deterministic and predictable

### Negative

- Runtime file generation looks unfamiliar to new contributors
- The `trap` cleanup mechanism can be confusing
- Race conditions are theoretically possible if multiple tfscaffold
  invocations target the same component directory simultaneously

## Alternatives Considered

### Alternative 1: Terraform Backend Partial Configuration

Use `terraform init -backend-config=...` to pass parameters. Rejected because
it requires the backend block to exist statically and does not support the
full flexibility needed (bucket name derived from account ID, etc.).

### Alternative 2: Terragrunt

Use Terragrunt for backend configuration generation. Rejected because
tfscaffold deliberately avoids additional tool dependencies, and Terragrunt
would replace rather than complement tfscaffold's purpose.
