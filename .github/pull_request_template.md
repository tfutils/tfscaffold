## Description

<!-- What does this PR do? Why is it needed? -->

## Issue Link

<!-- Closes #NNN -->

## Testing

- [ ] Ran `bash -n bin/terraform.sh` (syntax check passes)
- [ ] Tested manually with at least one component (note which below)
- [ ] Terraform modules validated with `terraform validate` (if applicable)

**Platform tested:** <!-- e.g. Ubuntu 22.04, macOS 14 -->

## Quality Checklist

- [ ] Shell quoting verified — all variables use `${braces}` and are double-quoted
- [ ] Cross-platform considered — BSD vs GNU tool differences
- [ ] No unintended changes to other components or modules
- [ ] `set -uo pipefail` compatibility verified — no unbound variables
- [ ] README.md updated (if user-facing change)
- [ ] CHANGELOG.md updated (if notable change)

## Related Issues

<!-- Links to related PRs, issues, or discoveries made during implementation. -->
<!-- Use "Also closes: #NNN" for bugs resolved atomically by this PR. -->
