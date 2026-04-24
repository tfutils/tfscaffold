# 003. Variable File Precedence and Layering

**Status:** Accepted

**Date:** 2026-04-24

## Context

tfscaffold supports multiple layers of variable files that are passed to
Terraform in a specific order. Understanding this precedence is critical
because Terraform uses the last definition of a variable as the effective
value.

The layers, in order of increasing precedence, are:
1. `etc/global.tfvars` — project-wide defaults
2. `etc/{region}.tfvars` — region-specific values
3. `etc/group_{group}.tfvars` — group-level values (optional, multiple)
4. `etc/env_{region}_{environment}.tfvars` — environment-specific values
5. `etc/versions_{region}_{environment}.tfvars` — frequently-changing versions
6. Remote S3 tfvars files (`*.tfvars`, `*.tfvars.json`) — dynamic values
7. `-var region=` — the `-r` flag always wins for region

This layering enables a single Terraform component to be deployed across
many environments with minimal per-environment configuration. However, it
also means that defining the same variable in multiple files leads to
silent override behaviour that can be confusing.

## Decision

tfscaffold will maintain the current variable file precedence order. A
runtime warning is emitted when duplicate variable names are detected across
tfvars files. The `-r`/`--region` flag is always authoritative via a `-var`
override that takes highest precedence.

The separation between env and versions files is purely logical — it
provides a convention for separating stable infrastructure configuration
from frequently-changing deployment artefact versions, but Terraform treats
them identically.

## Consequences

### Positive

- Single component definition works across all environments
- Environment-specific values cleanly override global defaults
- Region flag is never silently overridden by tfvars files
- Duplicate variable warning catches common mistakes

### Negative

- The override order is implicit and must be documented
- New users may not understand why a variable value differs from what
  they set in a tfvars file
- Duplicate detection uses simple name matching and may produce false
  positives for intentional overrides

## Alternatives Considered

### Alternative 1: Strict No-Duplicate Policy

Reject runs with duplicate variables across files. Rejected because
intentional overrides (e.g. environment overriding a global default) are
a core feature of the layering system.

### Alternative 2: Explicit Merge Configuration

Add a configuration file defining merge strategy per variable. Rejected
as over-engineered — the current warning-based approach is sufficient for
the project's scale.
