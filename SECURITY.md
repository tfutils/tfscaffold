# Security Policy

## Supported Versions

Only the latest release is actively supported with security fixes.

| Version | Supported |
| ------- | --------- |
| 2.3.x   | Yes       |
| < 2.3   | No        |

## Reporting a Vulnerability

**Do not open a public issue for security vulnerabilities.**

Please report security vulnerabilities via
[GitHub Security Advisories](https://github.com/tfutils/tfscaffold/security/advisories/new).

You can expect:

- **Acknowledgement** within 48 hours
- **Status update** within 7 days
- **Fix or mitigation plan** within 30 days for confirmed vulnerabilities

If you do not receive a response within 48 hours, please email the maintainer
directly at mike.peachey@bjss.com.

## Scope

tfscaffold is a wrapper around Terraform that manages remote state, variable
files, and component execution. Security concerns relevant to this project
include:

- S3 backend configuration injection or manipulation
- Variable injection through crafted tfvars files or environment variables
- Hook script (`pre.sh`/`post.sh`) sourcing vulnerabilities
- Secret decryption and handling in the KMS/S3 secrets mechanism
- Path traversal via component or project names
- State file exposure or unintended state bucket access
- Bootstrap destroy safety bypass

## Security Practices

tfscaffold follows these security practices:

- **S3 state encryption** — `encrypt = true` always set in backend config
- **DynamoDB locking** — optional state locking to prevent concurrent writes
- **Bootstrap destroy protection** — interactive confirmation required
- **No direct pushes to `master`** — all changes via PR with required review
- **Minimal dependencies** — bash, curl, AWS CLI, terraform only
- **Strict bash mode** — `set -uo pipefail` prevents silent failures

See [AGENTS.md](AGENTS.md) for the full development quality bar.
