# 👶 bbq (BaBigQuery)

[![Test](https://github.com/tim-watcha/bbq/actions/workflows/test.yml/badge.svg)](https://github.com/tim-watcha/bbq/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Too young to do anything dangerous.**

Give your AI agent access to BigQuery — without the fear.
`bbq` wraps the `bq` CLI and blocks every irreversible operation. Drop, delete, insert, overwrite? Nope. Query, list, export? Go ahead.

## Quick start

### 1. Install

```bash
brew install tim-watcha/bbq/bbq
```

or

```bash
curl -fsSL https://raw.githubusercontent.com/tim-watcha/bbq/main/install.sh | bash
```

### 2. Give it to your AI agent

In Claude Code (or any AI coding agent), run `!bbq` with no arguments:

```
> !bbq
```

The usage guide is printed directly into the conversation — **the agent reads it and learns what it can and can't do.** No manual prompting needed. The tool teaches itself to the agent.

Now just talk to your agent about BigQuery — it knows what to do.

## What happens when it blocks

```
$ bbq rm my_dataset.my_table
👶 bbq blocked: 'rm' can cause irreversible changes.

$ bbq query 'DROP TABLE my_dataset.my_table'
👶 bbq blocked: 'DROP' is not allowed. Only SELECT/WITH queries are permitted.

$ bbq query --destination_table=my_dataset.copy 'SELECT * FROM source'
👶 bbq blocked: '--destination_table=...' is a write-related flag.
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

**Subcommands**: `rm`, `truncate`, `undelete`, `update`, `insert`, `load`, `cp`, `cancel`, `partition`, `add/remove/set-iam-policy-binding`, `shell`

**SQL**: Only `SELECT` and `WITH` are allowed as the first keyword. Semicolons are forbidden entirely.

**Query flags**: `--destination_table`, `--replace`, `--append_table`, `--schedule`, `--target_dataset`, `--destination_kms_key`, `--time_partitioning_*`, `--clustering_fields`

## How it works

bbq is a single shell script. No dependencies beyond `bq` and a POSIX shell.

1. Parse the subcommand → check against whitelist
2. For `query` → validate SQL starts with `SELECT`/`WITH`, no semicolons, no write flags
3. If safe → pass everything through to the real `bq`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Uninstall

```bash
brew uninstall bbq        # if installed via brew
sudo rm /usr/local/bin/bbq  # if installed via curl
```

## License

[MIT](LICENSE)
