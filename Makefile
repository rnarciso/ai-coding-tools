# Makefile

# --- Configuration ---
# Include the .env file to make its variables available to this Makefile
# Use '-include' to prevent errors if the file doesn't exist yet
-include .env
# Export the variables to be available in shell commands run by make
export

# --- Configuration ---
COMPOSE_CMD=docker compose
OWNER=1001:1001
ALIASES_FILE=$(HOME)/.ai_toolkit_aliases

# --- Main Targets ---
all: up

up: prepare
	@echo "Starting services in detached mode..."
	$(COMPOSE_CMD) up -d --build
	@echo ""
	@echo "---------------------------------------------------------"
	@echo "✅ AI Toolkit is now running in the background."
	@echo ""
	@echo "To activate the shell commands (gemini, claude, etc.):"
	@echo "  1) Run 'source ~/.bashrc' in your current terminal."
	@echo "  2) Or, run 'make reload' to start a new pre-configured shell."
	@echo "  3) Or, simply open a new terminal window."
	@echo "---------------------------------------------------------"

down:
	@echo "Stopping and removing services..."
	$(COMPOSE_CMD) down

reload:
	@echo "Starting a new shell with AI Toolkit aliases loaded..."
	@echo ">>> Type 'exit' to return to your original shell."
	@bash

# --- Helper Targets ---
prepare: install-aliases setup-bashrc
	@echo "Host environment is ready."
	@if [ ! -d "./config/.claude-code-router" ]; then mkdir -p ./config/.claude-code-router; fi
	@if [ ! -f "./config/.claude-code-router/config.json" ]; then cp ./config.json ./config/.claude-code-router/; fi
	@owner=$$(stat -c "%u:%g" ./config); \
	if [ "$$owner" != "$(OWNER)" ]; then \
		echo "Adjusting ownership of ./config to $(OWNER)..."; \
		sudo chown -R $(OWNER) ./config; \
	fi

install-aliases:
	@( \
		if [ ! -f ./ai_toolkit_aliases.template ]; then \
			echo "Error: ai_toolkit_aliases.template not found." >&2; \
			exit 1; \
		fi; \
		if [ ! -f "$(ALIASES_FILE)" ]; then \
			echo "Installing AI Toolkit shell functions to $(ALIASES_FILE)..."; \
			sed -e "s|%%PROJECT_DIR%%|$(shell pwd)|g" \
			    -e "s|%%CONTAINER_NAME%%|$(CONTAINER_NAME)|g" \
			    ai_toolkit_aliases.template > "$(ALIASES_FILE)"; \
		fi \
	)

setup-bashrc:
	@chmod +x setup_shell.sh
	@./setup_shell.sh

.PHONY: all up down reload prepare install-aliases setup-bashrc
