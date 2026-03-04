# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-03-05

### Added

- Initial release of bbq (BaBigQuery)
- Whitelist-based subcommand filtering (query, ls, show, head, mk, mkdef, extract, etc.)
- SQL validation: only SELECT/WITH queries allowed
- Semicolon ban to prevent multi-statement attacks
- Write-flag blocking for query (--destination_table, --replace, --schedule, etc.)
- One-line installer via curl
- Automated test suite
- GitHub Actions CI
