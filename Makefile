# Makefile for LiteLLM Ansible Deployment

# Variables
INVENTORY_DIR ?= inventories/production
HOSTS_FILE = $(INVENTORY_DIR)/hosts.yml
PLAYBOOK_DIR = playbooks
SITE_PLAYBOOK = $(PLAYBOOK_DIR)/site.yml
UPDATE_PLAYBOOK = $(PLAYBOOK_DIR)/update_config.yml

# Default target
.PHONY: all
all: help

# ==============================================================================
# Installation & Deployment
# ==============================================================================

.PHONY: install
install: ## Install Ansible collections from requirements.yml
	@echo "Installing Ansible collections..."
	ansible-galaxy install -r requirements.yml

.PHONY: deploy
deploy: ## Run the full deployment playbook (site.yml)
	@echo "Running full deployment..."
	ansible-playbook -i $(HOSTS_FILE) $(SITE_PLAYBOOK) --ask-vault-pass

.PHONY: update
update: ## Apply configuration updates (update_config.yml)
	@echo "Applying configuration updates..."
	ansible-playbook -i $(HOSTS_FILE) $(UPDATE_PLAYBOOK) --vault-password-file .vault_pass

.PHONY: ssl
ssl: ## Setup or renew SSL certificates
	@echo "Running SSL setup..."
	ansible-playbook -i $(HOSTS_FILE) $(SITE_PLAYBOOK) --tags "ssl" --ask-vault-pass

# ==============================================================================
# Management & Troubleshooting
# ==============================================================================

.PHONY: ping
ping: ## Check connectivity to the servers
	@echo "Pinging servers..."
	ansible -i $(HOSTS_FILE) all -m ping --vault-password-file .vault_pass

.PHONY: status
status: ## Check the status of litellm-proxy service on the server
	@echo "Checking service status on remote server..."
	ansible -i $(HOSTS_FILE) all -m shell -a "sudo systemctl status litellm-proxy" --become --vault-password-file .vault_pass

.PHONY: logs
logs: ## Tail the logs for the litellm-proxy docker container
	@echo "Tailing LiteLLM container logs..."
	ansible -i $(HOSTS_FILE) all -m shell -a "docker logs -n 200 litellm-proxy_app" --become --vault-password-file .vault_pass

.PHONY: restart
restart: ## Restart the litellm-proxy service
	@echo "Restarting LiteLLM service..."
	ansible -i $(HOSTS_FILE) all -m service -a "name=litellm-proxy state=restarted" --become --vault-password-file .vault_pass

# ==============================================================================
# Vault Management
# ==============================================================================

.PHONY: encrypt
encrypt: ## Encrypt a file. Usage: make encrypt FILE=path/to/file.yml
	@echo "Encrypting file: $(FILE)"
	ansible-vault encrypt $(FILE)

.PHONY: decrypt
decrypt: ## Decrypt a file. Usage: make decrypt FILE=path/to/file.yml
	@echo "Decrypting file: $(FILE)"
	ansible-vault decrypt $(FILE)

.PHONY: edit-vault
edit-vault: ## Edit an encrypted file. Usage: make edit-vault FILE=path/to/file.yml
	@echo "Editing vault file: $(FILE)"
	ansible-vault edit $(FILE)

.PHONY: rekey-vault
rekey-vault: ## Change the password for an encrypted file. Usage: make rekey-vault FILE=path/to/file.yml
	@echo "Rekeying vault file: $(FILE)"
	ansible-vault rekey $(FILE)

# ==============================================================================
# Help
# ==============================================================================

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
