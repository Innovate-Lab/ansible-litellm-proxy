# 🚀 LiteLLM Ansible Deployment Guide

This Ansible playbook provides a streamlined way to deploy and manage a production-ready LiteLLM proxy server. It includes roles for system hardening, Docker setup, Nginx reverse proxy, and SSL certificate management with Let's Encrypt.

## 📋 Project Structure

```
ansible-litellm/
├── ansible.cfg                    # Ansible configuration
├── Makefile                      # Automation shortcuts
├── requirements.yml              # Ansible dependencies (roles)
├── inventories/
│   ├── production/
│   │   ├── hosts.yml            # Production server inventory
│   │   └── group_vars/
│   │       └── all.yml          # Production variables (can be vaulted)
│   └── staging/                  # (Example for a staging environment)
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── roles/
│   ├── common/                  # Base system setup and security
│   ├── geerlingguy.docker/      # Docker installation role
│   ├── geerlingguy.nginx/       # Nginx installation role
│   ├── litellm/                 # LiteLLM application deployment
│   └── ssl/                     # SSL certificate management
├── playbooks/
│   ├── site.yml                 # Main playbook for full deployment
│   └── update_config.yml        # Playbook to update configurations
└── files/
    ├── config.yaml              # Your LiteLLM configuration (can be vaulted)
    └── .env                     # Your environment variables (can be vaulted)
```

## 🛠️ Prerequisites

### 1. Local Machine

- **Ansible**: Ensure Ansible is installed.
  ```bash
  # Ubuntu/Debian
  sudo apt update && sudo apt install ansible
  # macOS
  brew install ansible
  ```
- **Ansible Collections**: Install the required roles from Ansible Galaxy.
  ```bash
  make install
  ```

### 2. Remote Server

- **OS**: Ubuntu 20.04+ or Debian 11+
- **Resources**: Minimum 2GB RAM, 2 CPU cores
- **Access**: SSH access with a user that has `sudo` privileges.
- **Domain**: A registered domain name pointing to your server's public IP address.

### 3. Configuration Files

Create a `files` directory and place your LiteLLM configuration there.

```bash
mkdir -p files/

# Create your configuration files
vim files/config.yaml
vim files/.env
```

**For sensitive information, it is strongly recommended to encrypt your configuration files using Ansible Vault.** See the [Security](#-security) section for details.

## ⚙️ Configuration

### 1. Inventory

Define your server details in `inventories/production/hosts.yml`:

```yaml
---
all:
  children:
    litellm_servers:
      hosts:
        litellm-prod-01:
          ansible_host: "YOUR_SERVER_IP"
          ansible_user: ubuntu # or your remote user
          ansible_ssh_private_key_file: ~/.ssh/your-key.pem
```

### 2. Variables

Adjust the deployment variables in `inventories/production/group_vars/all.yml`:

```yaml
---
# General Settings
domain_name: your-domain.com
ssl_email: your-email@example.com # For Let's Encrypt notifications
app_environment: production
```
This file can also be encrypted if it contains sensitive data.

## 🚀 Deployment

The deployment process is automated with the `Makefile`.

### Full Deployment

This command runs the entire deployment process. You will be prompted for your vault password if any of your configuration files are encrypted.

```bash
make deploy
```

### Deploying Specific Parts

You can use Ansible tags to run specific parts of the deployment.

```bash
# Deploy only the application configuration
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml --tags "litellm" --ask-vault-pass

# Setup or renew SSL certificate
make ssl
```

## 📊 Management Commands

Use the `Makefile` for common management tasks.

| Command | Description |
|---|---|
| `make install` | Install Ansible dependencies. |
| `make deploy` | Run the full deployment. |
| `make update` | Apply changes from `files/config.yaml` and `files/.env`. |
| `make ssl` | Set up or renew SSL certificates. |
| `make ping` | Check SSH connectivity to the server. |
| `make status` | Check the status of `litellm` and `nginx` services. |
| `make logs` | View the logs from the LiteLLM Docker container. |
| `make restart` | Restart the LiteLLM application. |
| `make help` | Show all available commands. |

## 🔐 Security & Vault Management

It is best practice to encrypt any file containing sensitive data (like API keys or credentials) using Ansible Vault.

### Encrypting a File

To encrypt a file for the first time:

```bash
make encrypt FILE=files/.env
```
You will be prompted to create and confirm a new vault password.

### Editing an Encrypted File

To securely edit an already encrypted file:

```bash
make edit-vault FILE=files/.env
```
This will decrypt the file for editing in your default editor and automatically re-encrypt it upon saving.

### Other Vault Commands

| Command | Description |
|---|---|
| `make encrypt FILE=<path>` | Encrypt a file. |
| `make decrypt FILE=<path>` | Decrypt a file. |
| `make edit-vault FILE=<path>` | Edit an encrypted file. |
| `make rekey-vault FILE=<path>` | Change the password for an encrypted file. |

When you run playbooks (`make deploy`, `make update`), Ansible will automatically prompt for the vault password if it detects encrypted files.

## 🔄 Workflow: Updating Configuration

1.  **Edit Files**:
    - For unencrypted files, edit them directly.
    - For encrypted files, use `make edit-vault FILE=path/to/your/file.yml`.
2.  **Apply Changes**: Run the update command.
    ```bash
    make update
    ```
    This playbook will copy the new files and restart the LiteLLM service.

## 🎯 Quick Start

1.  **Clone the repository.**
2.  **Install dependencies:** `make install`
3.  **Create configuration:**
    - `mkdir files`
    - Create `files/config.yaml` and `files/.env`.
4.  **Encrypt sensitive files:**
    - `make encrypt FILE=files/.env`
    - `make encrypt FILE=files/config.yaml`
5.  **Configure inventory:**
    - Edit `inventories/production/hosts.yml`.
    - Edit `inventories/production/group_vars/all.yml`.
6.  **Deploy:** `make deploy`

After deployment, your LiteLLM proxy will be available at `https://your-domain.com`.
