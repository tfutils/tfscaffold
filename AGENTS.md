# Agent Guidelines for tfutils/tfscaffold

Master context document for AI coding agents contributing to this repository.
Every agent MUST read this file before starting work.

---

## Project Overview

tfscaffold is a Terraform wrapper framework for controlling multi-environment,
multi-component, multi-account AWS infrastructure. It handles remote state
management, variable file layering, bootstrap bucket creation, and component
execution orchestration.

- **Language:** Bash (main script: `bin/terraform.sh`, ~960 LOC)
- **Default branch:** `master`
- **Current release:** v2.3.3 (April 2026)
- **Maintainer:** Mike Peachey / Jaz (@Zordrak)
- **Minimal dependencies:** bash, AWS CLI, terraform, curl, GNU getopt
- **License:** MIT

## Repository Structure

```
bin/
  terraform.sh        The tfscaffold script — the core of the project
  docs.sh             Recursive terraform-docs generation helper
bootstrap/            Bootstrap Terraform code for creating the S3 state bucket
                      and DynamoDB lock table
components/           Terraform "components" — root modules run directly
  example/            Example component demonstrating conventions
etc/                  Environment-specific terraform variable files:
                      env_{region}_{environment}.tfvars
                      versions_{region}_{environment}.tfvars
                      global.tfvars, {region}.tfvars, group_{group}.tfvars
lib/                  Optional libraries (e.g. Jenkins pipeline groovy)
modules/
  generic/            Reusable Terraform modules (cognito, iam-role, kms,
                      lambda, s3bucket, sftp, sns, subnets, vpc)
  project/            Project-specific modules (empty by default)
plugin-cache/         Default directory for caching Terraform provider plugins
.github/              CI workflows, agent definitions, issue templates
  agents/             Agent definition files (.agent.md)
  instructions/       Auto-loaded coding standards
  ISSUE_TEMPLATE/     Structured issue forms
docs/
  adr/                Architecture Decision Records
```

---

## Core Principles

### 1. Generated Backend Configuration

tfscaffold generates `backend_tfscaffold.tf` at runtime with the correct S3
backend configuration because Terraform does not support variable interpolation
in backend blocks. This file is cleaned up on exit via `trap`. This is
**intentional** — do NOT attempt to replace it with static configuration.
See [ADR-0002](docs/adr/0002-generated-backend-configuration.md).

### 2. Variable File Layering

Variable files are loaded in a specific precedence order: global → region →
group(s) → environment → versions → remote S3 → `-var` overrides. The `-r`
flag always wins for region. Duplicate variables across files trigger a
warning but are not an error (intentional overrides are a core feature).
See [ADR-0003](docs/adr/0003-variable-file-precedence.md).

### 3. Worktree-First

ALL code changes MUST happen in a git worktree under `.worktrees/`. The main
working tree is shared by all agents and the human — modifying it directly
risks conflicts. `.worktrees/` is gitignored.

```bash
# Create a worktree for your work
git worktree add .worktrees/fix-123 -b fix/123-description master

# Do all work inside the worktree
cd .worktrees/fix-123

# Clean up when done (after PR is created)
cd /path/to/main/tree
git worktree remove .worktrees/fix-123
```

**Exception:** Read-only operations (searching, reading files) may use the
main working tree.

### 4. Quality Over Speed

- Read the diff before pushing
- Check your own work before calling it done
- Fix problems when you find them — do not defer

### 5. Minimal Dependencies

The project deliberately has minimal dependencies: bash, AWS CLI, terraform,
and GNU getopt. Do NOT add new external tools or packages without explicit
approval from the maintainer.

### 6. Auto-Approve is Automatic

tfscaffold **automatically** adds `-auto-approve=true` to all `apply` actions
and `-auto-approve` to `destroy` actions (with legacy `-force` fallback for
Terraform < 0.15). Do NOT pass `-auto-approve` manually — it causes "unknown
option" errors. If custom terraform arguments are needed, use `--` to end
tfscaffold argument parsing first.

---

## Branch and PR Workflow

1. **Never commit directly to `master`.** Always use a feature branch.
2. **Branch naming:** `fix/<short-description>` for bugs,
   `feat/<short-description>` for features, `chore/<short-description>`
   for maintenance. Reference the issue number where applicable
   (e.g. `fix/42-unquoted-variable`).
3. **One logical change per branch/PR.** Do not bundle unrelated fixes.
4. **PRs target `master`.** There is no develop or staging branch.
5. **Merge strategy:** The repo uses merge commits (not squash).
   Do not force-push or rebase shared branches.

## Commit Messages

Freeform — no conventional commits standard is enforced. Be descriptive.
Reference issue numbers where applicable (e.g. `Fix #42: ...`).

Historical examples from CHANGELOG:
- `feat: add multi-group support to terraform.sh`
- `fix: region flag not being authoritative over tfvars files`
- `chore: remove deprecated expected_bucket_owner from s3bucket module`

---

## Claim Protocol

Before starting work on any issue, an agent MUST claim it:

1. Add the `agent:in-progress` label to the issue
2. Post a comment: `Claimed by <agent-name>. Working on this.`
3. If the label is already present, the issue is claimed — do NOT work on it

This acts as a distributed lock preventing duplicate effort when multiple
agents run concurrently.

When work is complete (PR created), remove `agent:in-progress` and add
`agent:review-requested`.

---

## GitHub CLI Strategy

The `gh` CLI is the **primary and load-bearing** interface to GitHub for all
agents. Use `gh api repos/tfutils/tfscaffold/...` for operations not covered
by high-level `gh` commands.

The GitHub MCP server may supplement `gh` where proven reliable, but must
never be on the critical path.

---

## Work Type Ownership

Each work type is owned by a specific agent. If you receive a request that
belongs to a different agent, say so and stop.

| Work Type | Owning Agent | Description |
| --------- | ------------ | ----------- |
| Autonomous delivery orchestration | `developer` | Assess board, dispatch specialists |
| Bug hunting and auditing | `bug-finder` | Find defects, file structured issues |
| Bug fixing | `bug-fixer` | Implement fixes with tests |
| Feature design and specification | `feature-designer` | Write detailed specs as issues |
| Feature implementation | `feature-implementer` | Build from specs with tests |
| Code review | `reviewer` | First-pass structured PR review |
| Architecture and design decisions | `architect` | ADRs, decomposition, trade-off analysis |
| Documentation quality | `documenter` | Cross-doc consistency, link integrity |
| Delivery metrics and reporting | `evaluator` | Compute metrics from `gh` data |
| Board management and triage | `pm` | Organise backlog, recommend priorities |
| Release management | `releaser` | CHANGELOG, tags, GitHub releases |

---

## Testing

### No Formal Test Suite

tfscaffold does not currently have an automated test suite. The primary script
(`bin/terraform.sh`) requires live AWS credentials and a real Terraform
installation to exercise. Verification is manual.

### How to Verify Changes

```bash
# Syntax check — catches most bash errors
bash -n bin/terraform.sh

# Dry-run with a real project (requires AWS credentials)
bin/terraform.sh \
  -a plan \
  -p myproject \
  -c example \
  -e dev \
  -r eu-west-2

# Check version output
bin/terraform.sh --version

# Check help output
bin/terraform.sh --help
```

### Terraform Module Validation

Individual modules can be validated in isolation:

```bash
cd modules/generic/lambda
terraform init -backend=false
terraform validate
```

---

## Release Process

Releases are manual. The `releaser` agent handles the judgement-intensive
parts but always requires human confirmation.

1. Accumulate changes on `master`
2. Update `CHANGELOG.md` with a new version section using the format:
   ```
   ## X.Y.Z (DD/MM/YYYY)

   BREAKING CHANGES:
    * Description

   FEATURES:
    * Description

   BUG FIXES:
    * Description

   CHORES:
    * Description
   ```
3. Update `script_ver` in `bin/terraform.sh` to match
4. Create an annotated tag: `git tag -a vX.Y.Z -m "tfscaffold vX.Y.Z"`
5. Push the tag: `git push origin vX.Y.Z`
6. Create a GitHub Release from the tag

**Agents must not create releases or tags without explicit instruction
from the maintainer.**

---

## Label Taxonomy

Issues use a namespaced label system:

| Namespace | Labels | Purpose |
| --------- | ------ | ------- |
| `type:` | `bug`, `feature`, `chore`, `question` | What kind of work |
| `severity:` | `critical`, `high`, `medium`, `low` | Impact of bugs |
| `priority:` | `critical`, `high`, `medium`, `low` | When to address |
| `complexity:` | `trivial`, `small`, `medium`, `large` | Effort estimate |
| `confidence:` | `confirmed`, `probable`, `speculative` | Bug certainty |
| `category:` | `scaffold-core`, `bootstrap`, `components`, `modules`, `state-management`, `variables`, `hooks`, `platform`, `documentation` | Affected area |
| `agent:` | `in-progress`, `review-requested` | Agent workflow state |

---

## Things Agents Must Not Do

- **Do not run `git push` to `master` or any remote branch** without
  explicit approval from Jaz
- **Do not create GitHub releases or tags** without explicit instruction
- **Do not close or lock issues** — only the maintainer triages
- **Do not refactor the generated backend configuration** pattern — it is
  a deliberate architectural choice
  (see [ADR-0002](docs/adr/0002-generated-backend-configuration.md))
- **Do not change the variable file precedence order** without discussion
  (see [ADR-0003](docs/adr/0003-variable-file-precedence.md))
- **Do not add new dependencies** without discussion
- **Do not modify `.github/workflows/`** without explicit approval —
  CI changes affect all platforms and have outsized blast radius
- **Do not merge PRs** — create them and leave for human review
- **Do not modify Terraform structure** (directory layout, component
  organisation, module structure) without explicit approval from Jaz —
  content changes are fine, structural changes are not
- **Do not write to `/tmp` or `/dev/null`** — use `.tmp/` in the workspace
  root for temporary files
- **Do not pass `-auto-approve` to tfscaffold** — it adds this automatically

---

## Common Pitfalls in This Codebase

These are the most frequent sources of bugs. Check for them in every change:

1. **Shell operator precedence:** `cmd1 || cmd2 | cmd3` means
   `cmd1 || (cmd2 | cmd3)`, not `(cmd1 || cmd2) | cmd3`.
2. **Unquoted variables:** Always quote `"${var}"` in arguments,
   conditions, and assignments. Unquoted variables cause word-splitting.
3. **Double-quoted traps:** `trap "rm ${var}" EXIT` expands at definition
   time and is vulnerable to word-splitting. Use functions or single quotes.
4. **`$@` in for-loops:** Always quote: `for arg in "$@"`.
5. **Regex anchoring:** `^1.1` matches `1.10.x` because `.` is a regex
   wildcard. Use `^1\.1\.` for exact prefix matching.
6. **Cross-platform differences:** macOS uses BSD `sed`/`grep`/`readlink`.
   GNU extensions may not be available. tfscaffold requires GNU getopt
   (`brew install gnu-getopt` on macOS).
7. **`set -uo pipefail`:** All scripts run with strict mode. Undefined
   variables cause immediate crashes. Use `${var:-default}` for optional
   variables.
8. **Generated backend file:** `backend_tfscaffold.tf` is written at
   runtime and cleaned up by `trap`. Do not add it to version control or
   treat it as a static file.
9. **Auto-approve injection:** tfscaffold adds `-auto-approve` itself.
   Passing it manually via `--` causes Terraform to receive it twice and
   error with "unknown option".
10. **Bootstrap destroy safety:** The bootstrap destroy requires an exact
    interactive confirmation string. Do not try to automate or bypass this.

---

## Satellite Documentation

| Document | Purpose |
| -------- | ------- |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) | Copilot configuration, auto-loading |
| [.github/instructions/bash.instructions.md](.github/instructions/bash.instructions.md) | Bash coding standards (auto-loaded for `**/*.sh`) |
| [SECURITY.md](SECURITY.md) | Vulnerability reporting policy |
| [docs/adr/](docs/adr/) | Architecture Decision Records |
| [CHANGELOG.md](CHANGELOG.md) | Release history |
