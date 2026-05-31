#!/bin/bash

################################################################################
# Setup Environment Script
# Installs: Ansible, Terraform, Helm, Git, Java, Node.js, Docker, Docker Compose
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_VERSION="1.5.0"
HELM_VERSION="3.12.0"
NODE_VERSION="20.x"
JAVA_VERSION="11"

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_command() {
    if command -v $1 &> /dev/null; then
        log_success "$1 is already installed"
        return 0
    else
        return 1
    fi
}

################################################################################
# System Update
################################################################################

update_system() {
    log_info "Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y
    log_success "System packages updated"
}

################################################################################
# Git Installation
################################################################################

install_git() {
    log_info "Installing Git..."
    if check_command git; then
        GIT_VERSION=$(git --version)
        log_info "$GIT_VERSION"
        return 0
    fi
    
    sudo apt-get install -y git
    log_success "Git installed: $(git --version)"
}

################################################################################
# Java Installation
################################################################################

install_java() {
    log_info "Installing Java ${JAVA_VERSION}..."
    if check_command java; then
        JAVA_VERSION_OUT=$(java -version 2>&1 | head -n 1)
        log_info "$JAVA_VERSION_OUT"
        return 0
    fi
    
    sudo apt-get install -y openjdk-${JAVA_VERSION}-jdk
    log_success "Java installed: $(java -version 2>&1 | head -n 1)"
}

################################################################################
# Node.js Installation
################################################################################

install_nodejs() {
    log_info "Installing Node.js ${NODE_VERSION}..."
    if check_command node; then
        NODE_VER=$(node --version)
        NPM_VER=$(npm --version)
        log_info "Node $NODE_VER, npm $NPM_VER"
        return 0
    fi
    
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | sudo -E bash -
    sudo apt-get install -y nodejs
    log_success "Node.js installed: $(node --version)"
    log_success "npm installed: $(npm --version)"
}

################################################################################
# Docker Installation
################################################################################

install_docker() {
    log_info "Installing Docker..."
    if check_command docker; then
        DOCKER_VER=$(docker --version)
        log_info "$DOCKER_VER"
        return 0
    fi
    
    # Add Docker repository
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    log_warning "Please log out and log back in for docker group permissions to take effect"
    
    log_success "Docker installed: $(docker --version)"
}

################################################################################
# Docker Compose Installation
################################################################################

install_docker_compose() {
    log_info "Installing Docker Compose..."
    if check_command docker-compose; then
        DC_VER=$(docker-compose --version)
        log_info "$DC_VER"
        return 0
    fi
    
    # Check if docker compose v2 plugin is available
    if docker compose version &> /dev/null; then
        log_info "Docker Compose (plugin v2) is already available"
        return 0
    fi
    
    # Fallback: install docker-compose standalone
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    log_success "Docker Compose installed: $(docker-compose --version)"
}

################################################################################
# Terraform Installation
################################################################################

install_terraform() {
    log_info "Installing Terraform ${TERRAFORM_VERSION}..."
    if check_command terraform; then
        TF_VER=$(terraform version -json | grep terraform_version | cut -d'"' -f4)
        log_info "Terraform $TF_VER"
        return 0
    fi
    
    cd /tmp
    curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
    unzip -o terraform.zip
    sudo mv terraform /usr/local/bin/
    rm terraform.zip
    cd -
    
    log_success "Terraform installed: $(terraform version -json | grep terraform_version | cut -d'"' -f4)"
}

################################################################################
# Helm Installation
################################################################################

install_helm() {
    log_info "Installing Helm ${HELM_VERSION}..."
    if check_command helm; then
        HELM_VER=$(helm version --short)
        log_info "$HELM_VER"
        return 0
    fi
    
    cd /tmp
    curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xz
    sudo mv linux-amd64/helm /usr/local/bin/
    rm -rf linux-amd64
    cd -
    
    log_success "Helm installed: $(helm version --short)"
}

################################################################################
# Ansible Installation
################################################################################

install_ansible() {
    log_info "Installing Ansible..."
    if check_command ansible; then
        ANSIBLE_VER=$(ansible --version | head -n 1)
        log_info "$ANSIBLE_VER"
        return 0
    fi
    
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible
    
    log_success "Ansible installed: $(ansible --version | head -n 1)"
}

################################################################################
# Verification
################################################################################

verify_installations() {
    log_info "Verifying all installations..."
    echo ""
    
    TOOLS=("git" "java" "node" "npm" "docker" "terraform" "helm" "ansible")
    
    for tool in "${TOOLS[@]}"; do
        if check_command $tool; then
            case $tool in
                java)
                    echo -e "${GREEN}✓${NC} Java: $(java -version 2>&1 | grep version | cut -d'"' -f2)"
                    ;;
                node)
                    echo -e "${GREEN}✓${NC} Node.js: $(node --version)"
                    ;;
                npm)
                    echo -e "${GREEN}✓${NC} npm: $(npm --version)"
                    ;;
                docker)
                    echo -e "${GREEN}✓${NC} Docker: $(docker --version)"
                    ;;
                terraform)
                    TF_VER=$(terraform version -json 2>/dev/null | grep terraform_version | cut -d'"' -f4)
                    echo -e "${GREEN}✓${NC} Terraform: $TF_VER"
                    ;;
                helm)
                    echo -e "${GREEN}✓${NC} Helm: $(helm version --short)"
                    ;;
                ansible)
                    echo -e "${GREEN}✓${NC} Ansible: $(ansible --version | head -n 1 | cut -d' ' -f2)"
                    ;;
                *)
                    echo -e "${GREEN}✓${NC} $tool is installed"
                    ;;
            esac
        else
            echo -e "${RED}✗${NC} $tool is NOT installed"
        fi
    done
    
    echo ""
    if docker ps &>/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker daemon is running"
    else
        log_warning "Docker daemon is not running. Start it with: sudo service docker start"
    fi
}

################################################################################
# Main Installation Flow
################################################################################

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                     DEVELOPMENT ENVIRONMENT SETUP                           ║
║                                                                              ║
║  This script will install the following tools:                              ║
║  • Ansible                                                                   ║
║  • Terraform (v1.5.0)                                                        ║
║  • Helm (v3.12.0)                                                            ║
║  • Git                                                                       ║
║  • Java (OpenJDK 11)                                                         ║
║  • Node.js (LTS)                                                             ║
║  • Docker                                                                    ║
║  • Docker Compose                                                            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Ask for confirmation
    read -p "Do you want to proceed? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Setup cancelled"
        exit 1
    fi
    
    echo ""
    log_info "Starting installation process..."
    echo ""
    
    # Check if running with sudo privileges
    if [[ $EUID -ne 0 ]]; then
        log_info "This script requires sudo permissions for some operations"
    fi
    
    # Installation sequence
    update_system
    echo ""
    
    install_git
    echo ""
    
    install_java
    echo ""
    
    install_nodejs
    echo ""
    
    install_docker
    echo ""
    
    install_docker_compose
    echo ""
    
    install_terraform
    echo ""
    
    install_helm
    echo ""
    
    install_ansible
    echo ""
    
    # Verification
    verify_installations
    echo ""
    
    log_success "Installation complete!"
    log_warning "Please log out and log back in to apply docker group permissions"
    
    cat << "EOF"

Next steps:
1. Log out and log back in for docker group changes to take effect
2. Verify Docker is running: docker ps
3. Test Terraform: terraform -v
4. Test Kubernetes tools: helm version, kubectl version

For more information:
- Terraform: https://www.terraform.io/docs
- Helm: https://helm.sh/docs/
- Ansible: https://docs.ansible.com/
- Docker: https://docs.docker.com/

EOF
}

# Run main function
main "$@"
