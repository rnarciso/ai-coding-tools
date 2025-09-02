#!/bin/sh

# Configuration directory inside the container.
CONFIG_DIR="/home/coder"
# A "flag" file to indicate that the initial setup has been completed.
SETUP_FLAG_FILE="$CONFIG_DIR/.setup_complete"

# Check if the setup flag file does NOT exist.
if [ ! -f "$SETUP_FLAG_FILE" ]; then
  echo "--- First run detected ---"
  echo "Setting up MCP providers (Claude, Qwen, Gemini)..."

  # The $GITHUB_PAT variable will be available via the 'env_file' in docker-compose.yml.
  claude mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer $GITHUB_PAT"
  claude mcp add --transport http archon http://host.docker.internal:8051/mcp
  qwen mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer $GITHUB_PAT"
  qwen mcp add --transport http archon http://host.docker.internal:8051/mcp
  gemini mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer $GITHUB_PAT"
  gemini mcp add --transport http archon http://host.docker.internal:8051/mcp

  # Check if the previous command succeeded (exit code 0).
  if [ $? -eq 0 ]; then
    echo "Providers configured successfully."
    # Create the flag file to prevent this block from running again.
    touch "$SETUP_FLAG_FILE"
  else
    echo "ERROR: Failed to configure MCP providers. The container might not work as expected."
  fi
else
  echo "Setup has already been completed. Skipping..."
fi

# Finally, execute the main command passed from the docker-compose 'command' directive.
echo "Starting main service..."
exec "$@"
