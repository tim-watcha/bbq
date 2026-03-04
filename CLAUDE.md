# bbq (BaBigQuery)

A safe wrapper around the `bq` CLI that blocks irreversible operations.

## Project structure

```
bbq          # Main shell script
install.sh   # curl | bash installer
README.md    # Documentation
```

## Key design decisions

- **Whitelist approach**: Only explicitly allowed subcommands pass through. Unknown commands are blocked by default.
- **SQL validation**: For `bq query`, only `SELECT` and `WITH` as the first keyword are allowed. All DML/DDL statements are blocked.
- **Flag parsing**: Global flags and query flags are parsed to correctly extract the subcommand and SQL string. Boolean flags (e.g. `--nouse_legacy_sql`) must not consume the next argument.

## Allowed bq subcommands

`query` (SELECT/WITH only), `ls`, `show`, `head`, `mk`, `mkdef`, `extract`, `get-iam-policy`, `version`, `help`, `info`, `wait`, `init`

## Blocked bq subcommands

`rm`, `truncate`, `undelete`, `update`, `insert`, `load`, `cp`, `cancel`, `partition`, `add-iam-policy-binding`, `remove-iam-policy-binding`, `set-iam-policy`, `shell`

## Blocked SQL keywords

`INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `MERGE`, `CREATE`, `CALL`, `GRANT`, `REVOKE`

## Testing

When testing, **never let blocked commands reach the real `bq`**. Only use harmless queries like `SELECT 1` for allowed-command tests. For blocked-command tests, verify the error message output only.
