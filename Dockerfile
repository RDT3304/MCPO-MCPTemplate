# Start with the specified Python base image for mcpo
FROM python:3.12-slim-bookworm

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive

# Install uv (from official binary)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install base dependencies (git, curl, ca-certificates)
# These are commonly needed for cloning repositories or fetching other dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- Dependencies for your specific MCP server (e.g., Node.js, Go, Rust toolchains) ---
# Uncomment and modify these lines based on the programming language/framework
# of your MCP server. This is where you install its runtime or build tools.
#
# Example for a Node.js-based MCP server:
# RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
#     && apt-get install -y nodejs \
#     && rm -rf /var/lib/apt/lists/*
#
# Example for a Go-based MCP server (installs Go compiler):
# RUN apt-get update && apt-get install -y golang-go && rm -rf /var/lib/apt/lists/*
#
# Example for a Rust-based MCP server (installs rustup and sets PATH):
# RUN apt-get update && apt-get install -y curl build-essential && rm -rf /var/lib/apt/lists/*
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# ENV PATH="/root/.cargo/bin:$PATH"

# --- MCPO Python Virtual Environment Setup ---
# This section sets up the Python environment where mcpo will be installed.
WORKDIR /app
ENV VIRTUAL_ENV=/app/.venv
RUN uv venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH" # Add venv to PATH so mcpo can be found
RUN uv pip install mcpo && rm -rf ~/.cache

# --- Your Specific MCP Server Source Code & Build Steps ---
# This section is for getting your MCP server's code and building it if necessary.
#
# If your MCP server is in a separate GitHub repository, clone it:
# WORKDIR /
# RUN git clone https://github.com/your-org/your-mcp-server.git /mcp_server_src
# WORKDIR /mcp_server_src # Change to its directory for build steps

# Add build commands for your MCP server here.
# These commands depend entirely on your MCP server's language/framework.
# Examples:
# For Node.js (if it needs to be installed from source or compiled):
# RUN npm install --production && npm run build
# For Python (if source code is copied and needs to be installed):
# COPY ./your_mcp_server_src /mcp_server_src # If copying locally
# WORKDIR /mcp_server_src
# RUN uv pip install .
# For Go:
# RUN go mod tidy && go build -o ./mcp-server-executable .
# For Rust:
# RUN cargo build --release
#
# If your MCP server is installed via a package manager (like context7-mcp via npx),
# you might not need separate cloning or build steps here.

# --- Final Configuration ---
# Set the primary working directory back to /app for mcpo execution
WORKDIR /app

# Expose the port mcpo will listen on (default 8000).
# Ensure your deployment environment (e.g., Coolify) exposes this port.
EXPOSE 8000

# Set a default API key and port for mcpo.
# IMPORTANT: Change "your-secret-mcpo-api-key" to a strong, unique key.
# This should ideally be managed as a secret or environment variable
# in your deployment platform (e.g., Coolify, Kubernetes secrets, .env file)
# and NOT committed directly to a public repository.
ENV MCPO_API_KEY="your-secret-mcpo-api-key"
ENV MCPO_PORT=8000

# Command to run mcpo, passing the specific MCP server's stdio command.
# This is the crucial part that launches your MCP server and connects it to mcpo.
# Replace `<YOUR_MCP_SERVER_STDIO_COMMAND>` with the actual command your MCP server needs
# to run in stdio mode.
#
# Examples:
# CMD mcpo --port ${MCPO_PORT} --api-key ${MCPO_API_KEY} -- node dist/index.js --stdio
# CMD mcpo --port ${MCPO_PORT} --api-key ${MCPO_API_KEY} -- python -m my_mcp_tool --transport stdio
# CMD mcpo --port ${MCPO_PORT} --api-key ${MCPO_API_KEY} -- /mcp_server_src/mcp-server-executable --stdio
CMD mcpo --port ${MCPO_PORT} --api-key ${MCPO_API_KEY} -- <YOUR_MCP_SERVER_STDIO_COMMAND>
