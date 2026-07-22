class LoomServer < Formula
  desc "Loom agent server with multi-agent orchestration and gRPC/HTTP APIs"
  homepage "https://github.com/teradata-labs/loom"
  version "1.3.0"
  license "Apache-2.0"

  resource "loom-patterns" do
    url "https://github.com/teradata-labs/loom/archive/refs/tags/v#{version}.tar.gz"
    sha256 "d03bcac965ca866b68cffdd96910a9eda98ec4e153d87e1599d4740a5a65ead1"
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/teradata-labs/loom/releases/download/v#{version}/looms-darwin-arm64.tar.gz"
      sha256 "678afbbd2568f2ba9ce03498b3fbdcfeabc4aa12547882ded8bca3ea23dce242"
    else
      url "https://github.com/teradata-labs/loom/releases/download/v#{version}/looms-darwin-amd64.tar.gz"
      sha256 "de8146f358a2097a064d0c0ce8b06494e6cb768ba190b15ede78000f84d5c0dc"
    end
  end

  def install
    # Install binary
    bin.install "looms-darwin-arm64" => "looms" if Hardware::CPU.arm?
    bin.install "looms-darwin-amd64" => "looms" if Hardware::CPU.intel?

    # Create Loom data directory
    loom_dir = "#{Dir.home}/.loom"
    patterns_dir = "#{loom_dir}/patterns"
    config_file = "#{loom_dir}/looms.yaml"

    system "mkdir", "-p", loom_dir
    system "mkdir", "-p", patterns_dir

    ohai "Installing patterns..."
    resource("loom-patterns").stage do
      loom_src = Pathname.glob("loom-*").find(&:directory?)
      odie "Could not find Loom source directory in patterns archive" unless loom_src&.directory?
      odie "Could not find patterns/ in Loom source (archive layout may have changed)" unless loom_src.join("patterns").directory?

      system "cp", "-R", "#{loom_src}/patterns/.", patterns_dir
      pattern_count = Dir.glob("#{patterns_dir}/**/*.yaml").length
      ohai "Installed #{pattern_count} pattern files to #{patterns_dir}"
    end

    # Create default config if it doesn't exist
    unless File.exist?(config_file)
      ohai "Creating default configuration..."
      File.write(config_file, <<~YAML)
        # Loom Server Configuration
        server:
          host: "0.0.0.0"
          port: 60051

        # Database stored in Loom data directory
        database:
          path: "#{loom_dir}/loom.db"

        # Communication system (shared memory, message queue)
        communication:
          store:
            backend: sqlite
            path: "#{loom_dir}/loom.db"

        # Observability (optional - requires Hawk)
        observability:
          enabled: false

        # MCP servers (add your own)
        mcp:
          servers: {}

        # No pre-configured agents - use the weaver to create threads on demand
        agents:
          agents: {}
      YAML
      ohai "Configuration created at #{config_file}"
    end
  end

  def post_install
    ohai "Loom server installed successfully!"
    ohai ""
    ohai "Next steps:"
    ohai "  1. Configure an LLM provider:"
    ohai "       looms config set llm.provider anthropic"
    ohai "       looms config set-key anthropic_api_key"
    ohai ""
    ohai "  2. Start the server:"
    ohai "       looms serve"
    ohai ""
    ohai "  3. Install the TUI client (if not already installed):"
    ohai "       brew install loom"
    ohai ""
    ohai "  4. Create your first agent (in another terminal):"
    ohai "       loom --thread weaver"
  end

  def caveats
    <<~EOS
      Loom server has been installed.

      Configuration file: #{Dir.home}/.loom/looms.yaml
      Patterns directory: #{Dir.home}/.loom/patterns

      To start the server:
        looms serve

      The server will run on:
        - gRPC: localhost:60051
        - HTTP: http://localhost:5006
        - Swagger UI: http://localhost:5006/swagger-ui

      To configure an LLM provider:
        looms config set llm.provider anthropic
        looms config set-key anthropic_api_key

      Documentation: https://github.com/teradata-labs/loom
    EOS
  end

  service do
    run [opt_bin/"looms", "serve"]
    keep_alive true
    log_path var/"log/loom.log"
    error_log_path var/"log/loom.error.log"
    working_dir HOMEBREW_PREFIX
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/looms --help")

    # Test config command
    system "#{bin}/looms", "config", "list"
  end
end
