class Loom < Formula
  desc "LLM agent framework with natural language agent creation"
  homepage "https://github.com/teradata-labs/loom"
  version "1.3.0"
  license "Apache-2.0"

  resource "loom-patterns" do
    url "https://github.com/teradata-labs/loom/archive/refs/tags/v1.3.0.tar.gz"
    sha256 "d03bcac965ca866b68cffdd96910a9eda98ec4e153d87e1599d4740a5a65ead1"
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/teradata-labs/loom/releases/download/v1.3.0/loom-darwin-arm64.tar.gz"
      sha256 "03b3b0d5f39caedc9b23573c7e135c5d92e2c861dc1710f78f931eda1915f76e"
    else
      url "https://github.com/teradata-labs/loom/releases/download/v1.3.0/loom-darwin-amd64.tar.gz"
      sha256 "4b67dc7f6f2a2045df843591c021705cb4c88cd51f8123300113bd503e4ba649"
    end
  end

  def install
    # Install binary
    bin.install "loom-darwin-arm64" => "loom" if Hardware::CPU.arm?
    bin.install "loom-darwin-amd64" => "loom" if Hardware::CPU.intel?

    # Create Loom data directory
    loom_dir = "#{Dir.home}/.loom"
    patterns_dir = "#{loom_dir}/patterns"

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

    ohai "Loom TUI client installed successfully!"
    ohai "To use Loom, you also need to install the server:"
    ohai "  brew install loom-server"
    ohai ""
    ohai "Or start the server manually:"
    ohai "  looms serve"
  end

  def caveats
    <<~EOS
      Loom TUI client has been installed.

      Next steps:
        1. Install the Loom server:
           brew install loom-server

        2. Configure an LLM provider:
           export ANTHROPIC_API_KEY="your-key"
           # or configure Bedrock, OpenAI, etc.

        3. Start the server (in another terminal):
           looms serve

        4. Create your first agent:
           loom --thread weaver

        Then type: "Create a code review assistant"

      Documentation: https://github.com/teradata-labs/loom
      Patterns installed to: #{Dir.home}/.loom/patterns
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/loom --help")
  end
end
