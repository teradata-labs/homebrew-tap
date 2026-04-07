# Loom - LLM Agent Framework

LLM agent framework with natural language agent creation and multi-agent orchestration.

## Overview

Loom is a Go framework for autonomous LLM threads, with natural-language agent creation, pattern-guided learning, and multi-agent orchestration.

**Features:**

- Natural language agent creation
- Multi-agent orchestration with 6 workflow patterns
- 90+ reusable patterns across 16 domains
- 8 LLM provider integrations (Anthropic, Bedrock, OpenAI, etc.)
- Multi-modal support (vision, document parsing)
- Built-in judge evaluation system with DSPy integration
- Self-improving agents with pattern proposal capabilities
- Real-time streaming and complete observability

## Installation

### Install via Homebrew

```bash
# Add tap (if not already added)
brew tap teradata-labs/tap

# Install both client and server
brew install loom loom-server

# Or install individually
brew install loom         # TUI client only
brew install loom-server  # Server only
```

### Install from Source

```bash
git clone https://github.com/teradata-labs/loom.git
cd loom
buf generate
go build -tags fts5 -o ./bin/looms ./cmd/looms
go build -tags fts5 -o ./bin/loom ./cmd/loom
```

## Quick Start

### 1. Configure LLM Provider

```bash
looms config set llm.provider anthropic
looms config set-key anthropic_api_key
```

**Supported providers:**

- Anthropic Claude
- AWS Bedrock
- OpenAI
- Azure OpenAI
- Ollama (local)
- Mistral
- Google Gemini
- HuggingFace

### 2. Start Server

```bash
# Start directly
looms serve

# Or use Homebrew services
brew services start loom-server
```

The server runs on:

- **gRPC**: `localhost:60051`
- **HTTP**: `http://localhost:5006`
- **Swagger UI**: `http://localhost:5006/swagger-ui`

### 3. Create Your First Agent

In another terminal:

```bash
loom --thread weaver
```

Then type:

```text
"Create a code review assistant that checks for security issues"
```

The weaver meta-agent will create a specialized agent for you in ~30 seconds.

## Components

### Loom (TUI Client)

Terminal UI client for connecting to Loom agents.

**Usage:**

```bash
# Connect to weaver (agent creator)
loom --thread weaver

# Connect to specific agent
loom --thread <agent-name>

# List available agents
looms agent list
```

**Features:**

- Interactive TUI with real-time streaming
- Message history and context
- Tool execution visualization
- Multi-modal support (images, documents)

### Loom Server (looms)

Multi-agent server with gRPC/HTTP APIs.

**Usage:**

```bash
# Start server
looms serve

# Configuration commands
looms config set <key> <value>
looms config get <key>
looms config list
looms config set-key <provider>_api_key

# Agent management
looms agent list
looms agent create <name> --pattern <pattern>
looms agent delete <name>

# Pattern management
looms pattern list
looms pattern show <name>
```

**Features:**

- gRPC and HTTP/JSON APIs
- Session management with persistence
- Pattern library (90+ patterns installed automatically)
- Real-time streaming
- Complete observability (traces, metrics)
- Swagger UI for API exploration

## Configuration

### Data Directory

Loom stores patterns, configuration, and database at:

```text
~/.loom/
├── patterns/       # 90+ YAML patterns
├── looms.yaml      # Server configuration
└── loom.db         # SQLite database
```

### Server Configuration

Edit `~/.loom/looms.yaml`:

```yaml
# Server settings
server:
  host: "0.0.0.0"
  port: 60051

# Database
database:
  path: "~/.loom/loom.db"

# LLM provider
llm:
  provider: anthropic
  api_key: "sk-..."

# Observability (optional - requires Hawk)
observability:
  enabled: false
  hawk:
    endpoint: "http://localhost:8080"

# MCP servers (optional)
mcp:
  servers:
    filesystem:
      command: "npx"
      args: ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/directory"]
```

### Environment Variables

```bash
# LLM provider configuration
export ANTHROPIC_API_KEY="sk-..."
export OPENAI_API_KEY="sk-..."
export BEDROCK_REGION="us-east-1"

# Data directory
export LOOM_DATA_DIR="~/.loom"

# Server configuration
export LOOM_HOST="0.0.0.0"
export LOOM_PORT="60051"
```

## Patterns

Loom includes 90+ reusable patterns across 16 domains:

- **Code Generation**: Generate, review, refactor code
- **Data Analysis**: SQL queries, data transformation
- **DevOps**: CI/CD, infrastructure, monitoring
- **Security**: Vulnerability scanning, code review
- **Testing**: Test generation, coverage analysis
- **Documentation**: API docs, user guides
- **Research**: Literature review, summarization
- **And more...**

### Using Patterns

```bash
# List available patterns
looms pattern list

# View pattern details
looms pattern show code-reviewer

# Create agent from pattern
looms agent create my-reviewer --pattern code-reviewer

# Connect to agent
loom --thread my-reviewer
```

### Creating Custom Patterns

Create a YAML file in `~/.loom/patterns/`:

```yaml
name: my-pattern
description: Custom pattern for my use case
version: 1.0.0

prompts:
  system: |
    You are a specialized agent for...

  user: |
    {{.Input}}

tools:
  - name: bash
    enabled: true
  - name: file_operations
    enabled: true

parameters:
  temperature: 0.7
  max_tokens: 2000
```

## Multi-Agent Orchestration

Loom supports 6 orchestration patterns:

### 1. Pipeline (Sequential)

```yaml
workflow:
  type: pipeline
  agents:
    - researcher    # Step 1: Research
    - writer        # Step 2: Write
    - reviewer      # Step 3: Review
```

### 2. Parallel (Concurrent)

```yaml
workflow:
  type: parallel
  agents:
    - security-scan
    - performance-test
    - code-review
```

### 3. Fork-Join

```yaml
workflow:
  type: fork-join
  fork:
    - frontend-agent
    - backend-agent
  join: integration-agent
```

### 4. Debate (Multi-Judge)

```yaml
workflow:
  type: debate
  agents:
    - optimist
    - pessimist
    - pragmatist
  rounds: 3
  aggregation: majority
```

### 5. Conditional (Branching)

```yaml
workflow:
  type: conditional
  condition: "{{.RequiresApproval}}"
  if_true: approval-agent
  if_false: auto-deploy-agent
```

### 6. Swarm (Dynamic)

```yaml
workflow:
  type: swarm
  coordinator: orchestrator
  workers:
    - specialist-a
    - specialist-b
    - specialist-c
  max_concurrent: 3
```

## API Usage

### gRPC API

```go
import (
    "context"

    loomv1 "github.com/teradata-labs/loom/gen/go/loom/v1"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

conn, _ := grpc.NewClient("localhost:60051", grpc.WithTransportCredentials(insecure.NewCredentials()))
client := loomv1.NewLoomServiceClient(conn)

stream, _ := client.Chat(context.Background())
stream.Send(&loomv1.ChatRequest{
    Thread: "weaver",
    Message: "Create a code review assistant",
})
```

In production code, check errors from `NewClient`, `Chat`, and `Send`; call `conn.Close()` when done.

### HTTP API

```bash
# Create agent
curl -X POST http://localhost:5006/v1/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-agent",
    "pattern": "code-reviewer"
  }'

# Send message
curl -X POST http://localhost:5006/v1/chat \
  -H "Content-Type: application/json" \
  -d '{
    "thread": "my-agent",
    "message": "Review this code..."
  }'

# List agents
curl http://localhost:5006/v1/agents
```

### Swagger UI

Explore the full API at: <http://localhost:5006/swagger-ui>

## Homebrew Services

### Start Server

```bash
# Start and enable at login
brew services start loom-server

# Start without auto-launch
brew services run loom-server

# Stop server
brew services stop loom-server

# Restart server
brew services restart loom-server

# Check status
brew services list
```

### View Logs

```bash
# Homebrew service logs
tail -f $(brew --prefix)/var/log/loom.log
tail -f $(brew --prefix)/var/log/loom.error.log

# Or direct server logs
looms serve --log-level debug
```

## Troubleshooting

### Server Won't Start

```bash
# Check if port is already in use
lsof -i :60051

# Try different port
looms serve --port 60052

# Check logs
looms serve --log-level debug
```

### Pattern Not Found

```bash
# Verify patterns are installed
ls ~/.loom/patterns

# Re-download patterns
rm -rf ~/.loom/patterns
brew reinstall loom-server
```

### LLM Provider Issues

```bash
# Verify API key is set
looms config get llm.api_key

# Test connection
looms config test-connection

# Check provider logs
looms serve --log-level debug | grep llm
```

### Database Issues

```bash
# Reset database (WARNING: deletes all data)
rm ~/.loom/loom.db
looms serve  # Will recreate database
```

## Updating

```bash
# Update tap
brew update

# Upgrade to latest version
brew upgrade loom loom-server

# Check versions
loom --version
looms --version
```

## Uninstalling

```bash
# Stop services
brew services stop loom-server

# Uninstall packages
brew uninstall loom loom-server

# Remove data directory (optional)
rm -rf ~/.loom
```

## Documentation

- **GitHub Repository**: <https://github.com/teradata-labs/loom>
- **Full Documentation**: <https://github.com/teradata-labs/loom/tree/main/docs>
- **Quick Start Guide**: <https://github.com/teradata-labs/loom#quick-start>
- **API Documentation**: <http://localhost:5006/swagger-ui> (when server running)
- **Issues**: <https://github.com/teradata-labs/loom/issues>

## Examples

### Code Review Assistant

```bash
loom --thread weaver
> "Create a code review assistant that checks for:
   - Security vulnerabilities
   - Performance issues
   - Best practices
   - Test coverage"
```

### Data Analysis Agent

```bash
loom --thread weaver
> "Create a data analyst that can query PostgreSQL databases
   and generate visualizations"
```

### DevOps Orchestrator

```bash
loom --thread weaver
> "Create a DevOps agent that can deploy applications,
   monitor health, and rollback on failures"
```

## Contributing

Issues and contributions are welcome at <https://github.com/teradata-labs/loom>

## License

Apache-2.0 - See <https://github.com/teradata-labs/loom/blob/main/LICENSE>
