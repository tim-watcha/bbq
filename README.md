# bbq (BaBigQuery)

[![Test](https://github.com/tim-watcha/bbq/actions/workflows/test.yml/badge.svg)](https://github.com/tim-watcha/bbq/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Too young to do anything dangerous.

A safe wrapper around Google Cloud's `bq` CLI that blocks irreversible operations. You can query, create, and export freely — but destructive actions like drop, delete, insert, and overwrite are blocked.

## Demo

```
$ bbq query --nouse_legacy_sql 'SELECT 1 AS hello'
+-------+
| hello |
+-------+
|     1 |
+-------+

$ bbq rm my_dataset.my_table
error: 'rm' is blocked by bbq. This command can cause irreversible changes.

$ bbq query 'DROP TABLE my_dataset.my_table'
error: 'DROP' is not allowed. Only SELECT/WITH queries are permitted.

$ bbq query --destination_table=my_dataset.copy 'SELECT * FROM source'
error: '--destination_table=my_dataset.copy' is blocked in safe query mode.
```

## Install

### Homebrew

```bash
brew install tim-watcha/bbq/bbq
```

### curl

```bash
curl -fsSL https://raw.githubusercontent.com/tim-watcha/bbq/main/install.sh | bash
```

### Manual

```bash
curl -fsSL https://raw.githubusercontent.com/tim-watcha/bbq/main/bbq -o /usr/local/bin/bbq
chmod +x /usr/local/bin/bbq
```

## Usage

Use `bbq` wherever you'd use `bq`. All flags are passed through as-is.

```bash
bbq query --nouse_legacy_sql 'SELECT * FROM dataset.table LIMIT 10'
bbq ls
bbq show dataset.table
bbq head -n 5 dataset.table
```

## What's allowed

| Command | Description |
|---|---|
| `query` | SELECT/WITH queries only |
| `ls` | List datasets and tables |
| `show` | View resource metadata |
| `head` | Preview table rows |
| `mk`, `mkdef` | Create datasets/tables/definitions |
| `extract` | Export to GCS |
| `get-iam-policy` | View IAM policies |
| `version`, `help`, `info`, `wait`, `init` | Utilities |

## What's blocked

### Subcommands

`rm`, `truncate`, `undelete`, `update`, `insert`, `load`, `cp`, `cancel`, `partition`, `add-iam-policy-binding`, `remove-iam-policy-binding`, `set-iam-policy`, `shell`

### SQL statements

Only `SELECT` and `WITH` are allowed as the first keyword. Everything else is blocked, including `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `MERGE`, `CREATE`, `EXECUTE`, `CALL`, `GRANT`, `REVOKE`.

Semicolons are entirely forbidden to prevent multi-statement attacks like `SELECT 1; DROP TABLE x`.

### Write-related query flags

`--destination_table`, `--replace`, `--append_table`, `--schedule`, `--target_dataset`, `--destination_kms_key`, `--time_partitioning_*`, `--clustering_fields`

## How it works

bbq is a single shell script that:

1. Parses the `bq` subcommand from arguments
2. Checks it against a whitelist of allowed commands
3. For `query`, validates that the SQL starts with `SELECT` or `WITH`
4. Blocks write-related flags like `--destination_table`
5. If everything is safe, passes all arguments through to the real `bq`

No dependencies beyond `bq` itself and a POSIX shell.

## Testing

```bash
./test.sh
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Uninstall

```bash
sudo rm /usr/local/bin/bbq
```

## License

[MIT](LICENSE)
