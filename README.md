# Teradata Labs Homebrew Tap

Official Homebrew tap for Teradata Labs open source software.

## Installation

### Add the Tap

```bash
brew tap teradata-labs/tap
```

### Install Tools

```bash
# Install Loom (LLM agent framework)
brew install loom loom-server

# Or install individually
brew install loom         # TUI client only
brew install loom-server  # Server only
```

## Available Formulae

### Loom

LLM agent framework with natural language agent creation and multi-agent orchestration.

**Install:**

```bash
brew install loom loom-server
```

**Documentation:** See [docs/loom.md](docs/loom.md) for complete installation, configuration, and usage guidelines.

**Repository:** <https://github.com/teradata-labs/loom>

---

*More tools coming soon...*

## Updating

```bash
# Update tap
brew update

# Upgrade all installed formulae
brew upgrade

# Or upgrade specific formula
brew upgrade loom
```

## Uninstalling

```bash
# Uninstall specific formula
brew uninstall loom

# Remove tap (optional)
brew untap teradata-labs/tap
```

## Contributing

Issues and contributions are welcome at the respective tool repositories:

- Loom: <https://github.com/teradata-labs/loom/issues>

## License

All formulae in this tap are licensed under Apache-2.0 unless otherwise specified.
