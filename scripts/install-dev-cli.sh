#!/bin/bash
# Install Dev Container CLI and setup development tools
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Dev Container CLI
install_devcontainer_cli() {
    print_info "Installing Dev Container CLI..."
    
    if command_exists devcontainer; then
        print_warning "Dev Container CLI is already installed"
        devcontainer --version
        return 0
    fi
    
    if ! command_exists npm; then
        print_error "npm is required but not installed"
        print_info "Please install Node.js first: https://nodejs.org/"
        return 1
    fi
    
    npm install -g @devcontainers/cli
    
    if command_exists devcontainer; then
        print_success "Dev Container CLI installed successfully"
        devcontainer --version
    else
        print_error "Failed to install Dev Container CLI"
        return 1
    fi
}

# Setup aliases for easy development
setup_aliases() {
    print_info "Setting up development aliases..."
    
    local shell_rc=""
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        shell_rc="$HOME/.bashrc"
    else
        print_warning "Unknown shell, skipping alias setup"
        return 0
    fi
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local aliases="
# Modern Python Development Environment Aliases
alias pydev='${script_dir}/dev.sh'
alias pydev-shell='${script_dir}/dev.sh shell'
alias pydev-web='${script_dir}/dev.sh web'
alias pydev-list='${script_dir}/dev.sh list'
alias pydev-clean='${script_dir}/dev.sh clean'
"
    
    # Check if aliases already exist
    if grep -q "Modern Python Development Environment Aliases" "$shell_rc" 2>/dev/null; then
        print_warning "Aliases already exist in $shell_rc"
    else
        echo "$aliases" >> "$shell_rc"
        print_success "Aliases added to $shell_rc"
        print_info "Run 'source $shell_rc' or restart your terminal to use aliases"
    fi
}

# Create desktop shortcut (optional)
create_desktop_shortcut() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local desktop_file="$HOME/Desktop/PyDev.desktop"
    
    print_info "Creating desktop shortcut..."
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Python Dev Environment
Comment=Modern Python Development Environment
Exec=gnome-terminal -- ${script_dir}/dev.sh shell
Icon=utilities-terminal
Terminal=false
Categories=Development;
EOF
    
    chmod +x "$desktop_file"
    print_success "Desktop shortcut created at $desktop_file"
}

# Main installation function
main() {
    echo "🚀 Installing Modern Python Development Environment CLI Tools"
    echo ""
    
    # Install Dev Container CLI
    install_devcontainer_cli
    echo ""
    
    # Setup aliases
    setup_aliases
    echo ""
    
    # Create desktop shortcut (Linux only)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        read -p "Create desktop shortcut? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_desktop_shortcut
            echo ""
        fi
    fi
    
    print_success "Installation completed!"
    echo ""
    echo "🎯 Quick Start:"
    echo "  ./scripts/dev.sh shell           # Quick development shell"
    echo "  ./scripts/dev.sh start myapp     # Start named environment"
    echo "  ./scripts/dev.sh web 8000        # Web development with port 8000"
    echo ""
    echo "📖 For more information, see:"
    echo "  docs/EASY_USAGE.md"
    echo ""
    echo "🔧 Available aliases (after restarting terminal):"
    echo "  pydev shell                      # Quick development shell"
    echo "  pydev start myapp                # Start named environment"
    echo "  pydev-web 8000                   # Web development"
    echo "  pydev-list                       # List environments"
    echo "  pydev-clean                      # Clean up"
}

# Run main function
main "$@"