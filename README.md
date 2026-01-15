# Teradata Labs Homebrew Tap

Official Homebrew tap for Teradata Labs developer tools and CLI utilities.

## Installation

### Add the Tap

```bash
brew tap teradata-labs/tap
```

### Install Loom

**Option 1: Install both client and server**

```bash
brew install loom loom-server
```

**Option 2: Install individually**

```bash
# TUI client only
brew install loom

# Server only
brew install loom-server
```

## Available Formulae

### Loom

LLM agent framework with natural language agent creation and multi-agent orchestration.

**Features:**
- Natural language agent creation
- Multi-agent orchestration with 6 workflow patterns
- 90+ reusable patterns across 16 domains
- 8 LLM provider integrations (Anthropic, Bedrock, OpenAI, etc.)
- Multi-modal support (vision, document parsing)
- Built-in judge evaluation system

**Usage:**

```bash
# Install
brew install loom

# Connect to a running server
loom --thread weaver
```

### Loom Server

Multi-agent server with gRPC/HTTP APIs and complete observability.

**Features:**
- gRPC and HTTP APIs
- Session management with persistence
- Pattern library (90+ patterns installed automatically)
- Real-time streaming
- Swagger UI at http://localhost:5006/swagger-ui

**Usage:**

```bash
# Install
brew install loom-server

# Configure LLM provider
looms config set llm.provider anthropic
looms config set-key anthropic_api_key

# Start server
looms serve

# Or use Homebrew services
brew services start loom-server
```

## Quick Start

```bash
# 1. Add tap and install
brew tap teradata-labs/tap
brew install loom loom-server

# 2. Configure
looms config set llm.provider anthropic
looms config set-key anthropic_api_key

# 3. Start server (in one terminal)
looms serve

# 4. Create your first agent (in another terminal)
loom --thread weaver
```

Then type: "Create a code review assistant"

## Documentation

- **GitHub Repository**: https://github.com/teradata-labs/loom
- **Documentation**: https://github.com/teradata-labs/loom/tree/main/docs
- **Quick Start Guide**: https://github.com/teradata-labs/loom#quick-start
- **Issues**: https://github.com/teradata-labs/loom/issues

## Configuration

### Data Directory

Loom stores patterns, configuration, and database at:
```
~/.loom/
├── patterns/       # 90+ YAML patterns
├── looms.yaml      # Server configuration
└── loom.db         # SQLite database
```

### LLM Providers

Supported providers:
- Anthropic Claude
- AWS Bedrock
- OpenAI
- Azure OpenAI
- Ollama (local)
- Mistral
- Google Gemini
- HuggingFace

Configure with:
```bash
looms config set llm.provider <provider>
looms config set-key <provider>_api_key
```

## Updating

```bash
# Update tap
brew update

# Upgrade formulae
brew upgrade loom loom-server
```

## Uninstalling

```bash
# Uninstall packages
brew uninstall loom loom-server

# Remove tap (optional)
brew untap teradata-labs/tap

# Remove data directory (optional)
rm -rf ~/.loom
```

## Contributing

Issues and contributions are welcome at https://github.com/teradata-labs/loom

## License

Apache-2.0 - See https://github.com/teradata-labs/loom/blob/main/LICENSE
