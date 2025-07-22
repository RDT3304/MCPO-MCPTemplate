# Build Your Own MCPO-MCP Server Docker Image

This repository provides a template and guide for creating Docker images that host any [MCP (MetaTooling Protocol)](https://github.com/metatool-ai/mcp) server and expose its functionality via an OpenAPI/HTTP interface using the [MCPO (MCP OpenAPI Proxy)](https://github.com/open-webui/mcpo) proxy.

MCPO acts as a bridge, allowing any MCP server that communicates over standard I/O (stdio) to be accessed as a standard web API. This is ideal for deploying diverse MCP tools in containerized environments like Coolify, Kubernetes, or Docker.

## Core Concept

The Docker image you'll build will include two main components:
1.  **MCPO**: The Python-based proxy that handles the HTTP/OpenAPI interface and communicates with your MCP server over stdio.
2.  **Your MCP Server**: The actual tool or agent that implements the MCP specification and communicates over stdio.

The final `CMD` in your Dockerfile orchestrates this by telling `mcpo` to launch and manage your MCP server as a child process:

```bash
CMD mcpo --port ${MCPO_PORT} --api-key ${MCPO_API_KEY} -- <YOUR_MCP_SERVER_STDIO_COMMAND>
