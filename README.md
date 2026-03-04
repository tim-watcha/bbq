# bbq (BaBigQuery)

Too young to do anything dangerous.

A safe wrapper around Google Cloud's `bq` CLI that blocks irreversible operations. You can query, create, and export freely — but destructive actions like drop, delete, insert, and overwrite are blocked.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/tim-watcha/bbq/main/install.sh | bash
```

## Usage

Use `bbq` wherever you'd use `bq`. All flags are passed through as-is.

```bash
# These work fine
bbq query --nouse_legacy_sql 'SELECT * FROM dataset.table LIMIT 10'
bbq ls
bbq show dataset.table
bbq head -n 5 dataset.table

# These are blocked
bbq rm dataset.table
# error: 'rm' is blocked by bbq. This command can cause irreversible changes.

bbq query 'DROP TABLE dataset.table'
# error: 'DROP' statements are not allowed. Only SELECT/WITH queries are permitted.
```

## Allowed commands

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

## Blocked commands

`rm`, `truncate`, `undelete`, `update`, `insert`, `load`, `cp`, `cancel`, `partition`, `add-iam-policy-binding`, `remove-iam-policy-binding`, `set-iam-policy`, `shell`

## Blocked SQL statements

`INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `MERGE`, `CREATE`, `CALL`, `GRANT`, `REVOKE`

## Uninstall

```bash
sudo rm /usr/local/bin/bbq
```
