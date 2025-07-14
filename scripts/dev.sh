#!/bin/bash
# Modern Python Development Environment - Easy CLI
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="modern-python-base:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_usage() {
    echo "🐍 Modern Python Development Environment CLI"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start [name]     - Start development environment (interactive)"
    echo "  run [name]       - Start development environment (background)"
    echo "  connect <name>   - Connect to running environment"
    echo "  stop <name>      - Stop development environment"
    echo "  list             - List running development environments"
    echo "  clean            - Clean up stopped containers"
    echo "  shell            - Quick shell (auto-cleanup)"
    echo "  create <name> <template> - Create new project from template"
    echo "  web [port]       - Start with web development ports"
    echo "  help             - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 shell                    # Quick development shell"
    echo "  $0 start myapp              # Start named environment"
    echo "  $0 run myapp                # Start in background"
    echo "  $0 connect myapp            # Connect to myapp"
    echo "  $0 web 8000                 # Web dev with port 8000"
    echo "  $0 create myapp webapp      # Create webapp project"
}

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

# Get project name from current directory
get_project_name() {
    local name="${1:-$(basename "$(pwd)")}"
    echo "dev-${name}"
}

# Check if container exists
container_exists() {
    docker ps -a --format "table {{.Names}}" | grep -q "^$1$"
}

# Check if container is running
container_running() {
    docker ps --format "table {{.Names}}" | grep -q "^$1$"
}

# Start development environment (interactive)
start_env() {
    local container_name=$(get_project_name "$1")
    
    if container_running "$container_name"; then
        print_warning "Environment '$container_name' is already running"
        print_info "Connecting to existing environment..."
        docker exec -it "$container_name" bash
        return 0
    fi
    
    if container_exists "$container_name"; then
        print_info "Starting existing environment '$container_name'..."
        docker start "$container_name"
        docker exec -it "$container_name" bash
    else
        print_info "Creating new environment '$container_name'..."
        docker run -it --rm \
            --name "$container_name" \
            -v "$(pwd):/workspace" \
            -v "${container_name}-cache:/home/dev/.cache" \
            -v "${container_name}-uv:/home/dev/.local/share/uv" \
            "$IMAGE_NAME"
    fi
    
    print_success "Environment '$container_name' started"
}

# Run development environment (background)
run_env() {
    local container_name=$(get_project_name "$1")
    
    if container_running "$container_name"; then
        print_warning "Environment '$container_name' is already running"
        return 0
    fi
    
    if container_exists "$container_name"; then
        print_info "Starting existing environment '$container_name'..."
        docker start "$container_name"
    else
        print_info "Creating new environment '$container_name'..."
        docker run -d \
            --name "$container_name" \
            -v "$(pwd):/workspace" \
            -v "${container_name}-cache:/home/dev/.cache" \
            -v "${container_name}-uv:/home/dev/.local/share/uv" \
            "$IMAGE_NAME" \
            tail -f /dev/null
    fi
    
    print_success "Environment '$container_name' is running in background"
    print_info "Connect with: $0 connect $1"
}

# Connect to running environment
connect_env() {
    local container_name=$(get_project_name "$1")
    
    if ! container_running "$container_name"; then
        print_error "Environment '$container_name' is not running"
        print_info "Start it with: $0 run $1"
        return 1
    fi
    
    print_info "Connecting to '$container_name'..."
    docker exec -it "$container_name" bash
}

# Stop development environment
stop_env() {
    local container_name=$(get_project_name "$1")
    
    if ! container_exists "$container_name"; then
        print_error "Environment '$container_name' does not exist"
        return 1
    fi
    
    print_info "Stopping environment '$container_name'..."
    docker stop "$container_name" >/dev/null 2>&1 || true
    docker rm "$container_name" >/dev/null 2>&1 || true
    
    print_success "Environment '$container_name' stopped and removed"
}

# List running environments
list_envs() {
    print_info "Development environments:"
    echo ""
    
    local running_containers=$(docker ps --filter "name=dev-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}")
    local stopped_containers=$(docker ps -a --filter "name=dev-" --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}")
    
    if [[ -n "$running_containers" ]] && [[ "$running_containers" != "NAMES	STATUS	PORTS" ]]; then
        echo -e "${GREEN}🟢 Running:${NC}"
        echo "$running_containers"
        echo ""
    fi
    
    if [[ -n "$stopped_containers" ]] && [[ "$stopped_containers" != "NAMES	STATUS	PORTS" ]]; then
        echo -e "${YELLOW}🟡 Stopped:${NC}"
        echo "$stopped_containers"
        echo ""
    fi
    
    if [[ -z "$running_containers$stopped_containers" ]] || 
       [[ "$running_containers$stopped_containers" == "NAMES	STATUS	PORTS"* ]]; then
        print_info "No development environments found"
    fi
}

# Clean up stopped containers
clean_envs() {
    print_info "Cleaning up stopped development environments..."
    
    local stopped_containers=$(docker ps -a --filter "name=dev-" --filter "status=exited" --format "{{.Names}}")
    
    if [[ -z "$stopped_containers" ]]; then
        print_info "No stopped containers to clean up"
        return 0
    fi
    
    echo "$stopped_containers" | while read container; do
        docker rm "$container" >/dev/null 2>&1
        print_success "Removed '$container'"
    done
    
    print_success "Cleanup completed"
}

# Quick shell (auto-cleanup)
quick_shell() {
    local temp_name="dev-temp-$(date +%s)"
    
    print_info "Starting temporary development shell..."
    docker run -it --rm \
        --name "$temp_name" \
        -v "$(pwd):/workspace" \
        "$IMAGE_NAME"
}

# Create new project from template
create_project() {
    local project_name="$1"
    local template="${2:-minimal}"
    
    if [[ -z "$project_name" ]]; then
        print_error "Project name is required"
        print_info "Usage: $0 create <project-name> [template]"
        return 1
    fi
    
    print_info "Creating project '$project_name' from template '$template'..."
    "$PROJECT_ROOT/scripts/create-project.sh" "$project_name" "$template"
    
    if [[ $? -eq 0 ]]; then
        print_success "Project '$project_name' created successfully"
        print_info "Navigate to the project: cd $project_name"
        print_info "Start development: $0 start"
    else
        print_error "Failed to create project '$project_name'"
        return 1
    fi
}

# Start web development environment
start_web() {
    local port="${1:-8000}"
    local container_name=$(get_project_name "web")
    
    print_info "Starting web development environment on port $port..."
    
    if container_running "$container_name"; then
        print_warning "Web environment is already running"
        print_info "Connecting to existing environment..."
        docker exec -it "$container_name" bash
        return 0
    fi
    
    docker run -it --rm \
        --name "$container_name" \
        -p "$port:$port" \
        -p "3000:3000" \
        -v "$(pwd):/workspace" \
        -v "${container_name}-cache:/home/dev/.cache" \
        -v "${container_name}-uv:/home/dev/.local/share/uv" \
        "$IMAGE_NAME"
}

# Main command dispatcher
main() {
    if [[ $# -eq 0 ]]; then
        print_usage
        return 0
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        "start")
            start_env "$@"
            ;;
        "run")
            run_env "$@"
            ;;
        "connect")
            if [[ $# -eq 0 ]]; then
                print_error "Container name is required for connect command"
                return 1
            fi
            connect_env "$@"
            ;;
        "stop")
            if [[ $# -eq 0 ]]; then
                print_error "Container name is required for stop command"
                return 1
            fi
            stop_env "$@"
            ;;
        "list"|"ls")
            list_envs
            ;;
        "clean")
            clean_envs
            ;;
        "shell")
            quick_shell
            ;;
        "create")
            create_project "$@"
            ;;
        "web")
            start_web "$@"
            ;;
        "help"|"-h"|"--help")
            print_usage
            ;;
        *)
            print_error "Unknown command: $command"
            print_usage
            return 1
            ;;
    esac
}

# Run main function
main "$@"