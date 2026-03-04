# 👶 bbq (BaBigQuery)

[![Test](https://github.com/tim-watcha/bbq/actions/workflows/test.yml/badge.svg)](https://github.com/tim-watcha/bbq/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Too young to do anything dangerous.**

`bbq` is an **AI-first BigQuery safety wrapper**.
It lets your AI agent use `bq` with guardrails: safe reads, blocked destructive actions.

Primary target is autonomous agents that you don't want with raw `bq` access.
Humans and scripts can use it too.

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

The usage guide is printed directly into the conversation, so the agent sees what is allowed and what is blocked without extra prompting.
This keeps agent behavior predictable in repeated workflows.

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

## Auditing blocked attempts

Blocked commands are printed to stderr. Keep an audit trail by redirecting:

```bash
bbq query 'SELECT 1' 2>> ~/.bbq/audit.log
```

## Limitations

`bbq` is a safety net, not a security boundary.

- String-based checks, not a full SQL parser.
- Designed to block common destructive patterns, not to replace IAM/organization controls.
- For production-grade safety, use least-privilege IAM/service accounts plus dataset/table-level access controls.

## How it works

bbq is a single shell script. No dependencies beyond `bq` and a POSIX shell.

1. Parse the subcommand → check against whitelist
2. For `query` → validate SQL starts with `SELECT`/`WITH`, no semicolons, no write flags
3. If safe → pass everything through to the real `bq`
4. Blocked operations return a clear error to stderr (agent can inspect and adapt)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Uninstall

```bash
brew uninstall bbq        # if installed via brew
sudo rm /usr/local/bin/bbq  # if installed via curl
```

## License

[MIT](LICENSE)
