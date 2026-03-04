# Contributing to bbq

Thanks for your interest in contributing to bbq!

## How to contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Make your changes
4. Run the tests: `./test.sh`
5. Commit your changes
6. Push to your fork and open a Pull Request

## Development

bbq is a single shell script with no build step. Just edit `bbq` and test.

```bash
# Run tests
chmod +x test.sh
./test.sh
```

## Guidelines

- Keep it simple — bbq is a shell script and should stay that way
- All changes must pass `./test.sh`
- New blocked commands/flags should include corresponding test cases
- Follow existing code style (2-space indent, `case` statements for flag parsing)

## Reporting issues

- **Bug reports**: Include the exact command you ran and the output
- **Feature requests**: Describe the use case and why it matters

## Adding new blocked commands or flags

1. Add the command/flag to the appropriate list in `bbq`
2. Add test cases in `test.sh` (both `assert_blocked` and `assert_allowed` as needed)
3. Update `README.md` if the allowed/blocked tables change
