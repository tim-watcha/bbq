# bbq (BaBigQuery)

A safe wrapper around the `bq` CLI that blocks irreversible operations.

## Project structure

```
bbq                              # Main shell script
install.sh                       # curl | bash installer
test.sh                          # Automated test suite
README.md                        # Documentation
CONTRIBUTING.md                  # Contribution guide
CHANGELOG.md                     # Version history
LICENSE                          # MIT license
.github/workflows/test.yml       # CI workflow
.github/ISSUE_TEMPLATE/          # Bug report & feature request templates
```

## Key design decisions

- **Whitelist approach**: Only explicitly allowed subcommands pass through. Unknown commands are blocked by default.
- **SQL whitelist**: For `bq query`, only `SELECT` and `WITH` as the first keyword are allowed. This is safer than blacklisting dangerous keywords.
- **Semicolon ban**: Semicolons are entirely forbidden to prevent multi-statement attacks.
- **Write-flag blocking**: Query flags that imply writes (`--destination_table`, `--replace`, `--schedule`, etc.) are blocked.
- **Flag parsing**: Global flags and query flags are parsed to correctly extract the subcommand and SQL string. Boolean flags (e.g. `--nouse_legacy_sql`) must not consume the next argument.

## Allowed bq subcommands

`query` (SELECT/WITH only), `ls`, `show`, `head`, `mk`, `mkdef`, `extract`, `get-iam-policy`, `version`, `help`, `info`, `wait`, `init`

## Blocked bq subcommands

`rm`, `truncate`, `undelete`, `update`, `insert`, `load`, `cp`, `cancel`, `partition`, `add-iam-policy-binding`, `remove-iam-policy-binding`, `set-iam-policy`, `shell`

## Testing

Run `./test.sh`. When adding new blocked commands/flags, always add corresponding test cases.

**Never let blocked commands reach the real `bq`**. Only use harmless queries like `SELECT 1` for allowed-command tests. For blocked-command tests, verify the error message output only.
