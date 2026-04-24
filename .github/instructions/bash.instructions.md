---
applyTo: '**/*.sh'
---
# Bash Coding Standards — tfscaffold

These standards apply to ALL bash scripts in the tfscaffold repository. Read
this entire document BEFORE writing or modifying any bash code.

## Mandatory Pre-Write Verification

Before writing ANY bash code, verify you understand these rules. Violations
caught after writing waste time — get it right first.

## Shell Setup

```bash
#!/usr/bin/env bash
set -uo pipefail;
```

- Shebang: `#!/usr/bin/env bash` (exact format)
- Strict mode: `set -uo pipefail;` — NEVER use `set -e`

## Indentation and Formatting

- 2-space indentation throughout (no tabs)
- Terminate ALL statements with a semicolon (`;`) where syntactically correct
- Include vim modeline at end of new scripts:
  `# vim:set et ts=2 sw=2:`

## Variables

- ALL variable references use braces: `${variable}` (never `$variable`)
- Script-local variables use lowercase: `${version}`, `${region}`
- Environment variables use UPPERCASE: `${AWS_DEFAULT_REGION}`, `${TF_VAR_region}`
- Always quote variable expansions: `"${variable}"`
- Quote entire strings containing variables: `"${dir}/file"` NOT `"${dir}"/file`
- Use `${var:-default}` for optional variables (scripts run with `set -u`)

## Quoting

- Single-quote strings unless variable expansion is needed
- Double-quote strings that contain variable expansion
- NEVER use unescaped `!` inside double-quoted strings (bash history expansion)

## Command Substitution

- Use `$(...)` NOT backticks

## Error Handling

- NEVER use `set -e` — handle errors explicitly
- Use the project's existing error patterns:
  - `error_and_die` for fatal errors with optional exit code:
    ```bash
    error_and_die "Something went wrong";
    error_and_die "Bad input" 2;
    ```
  - Inline `||` pattern for simple cases:
    ```bash
    some_command || error_and_die "Failed to do thing";
    ```

## Functions

- Define as: `function name() { ... };`
- Use `local` for variables inside functions

## Cross-Platform Considerations

- macOS uses BSD `sed`/`grep`/`readlink` — GNU extensions may not be available
- tfscaffold requires GNU getopt (`brew install gnu-getopt` on macOS)
- Scripts should work with bash 3.2+ (macOS default) where possible

## Common Pitfalls

1. **Shell operator precedence:** `cmd1 || cmd2 | cmd3` means
   `cmd1 || (cmd2 | cmd3)`, not `(cmd1 || cmd2) | cmd3`
2. **Unquoted variables:** Always quote `"${var}"` — unquoted variables cause
   word-splitting
3. **Double-quoted traps:** `trap "rm ${var}" EXIT` expands at definition time.
   Use functions or single quotes.
4. **`$@` in for-loops:** Always quote: `for arg in "$@"`
5. **Regex anchoring:** `^1.1` matches `1.10.x` because `.` is a regex
   wildcard. Use `^1\.1\.` for exact prefix matching.

## Pre-Submission Checklist

- [ ] `#!/usr/bin/env bash` shebang
- [ ] `set -uo pipefail;` (not `set -e`)
- [ ] 2-space indentation, no tabs
- [ ] All variables use `${braces}`
- [ ] All variable expansions double-quoted
- [ ] All statements terminated with `;`
- [ ] No unescaped `!` in double-quoted strings
- [ ] `$(...)` for command substitution (no backticks)
- [ ] `local` used inside functions
- [ ] Cross-platform compatibility considered
- [ ] vim modeline at end of file
