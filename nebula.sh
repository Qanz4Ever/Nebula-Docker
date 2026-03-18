#!/bin/bash

# Nebula Docker - Premium Docker Container Management
# Created By © Mfsavana 2026
# Version 1.0

# Premium Colors
RESET='\033[0m'
BOLD='\033[1m'
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.nebula"
WEB_DIR="$CONFIG_DIR/web"
PUBLIC_DIR="$WEB_DIR/public"
LOG_FILE="$CONFIG_DIR/nebula.log"
CONFIG_FILE="$CONFIG_DIR/config.json"

# GitHub raw links (ganti dengan link raw kamu nanti)
GITHUB_RAW="https://raw.githubusercontent.com/mfsavana/nebula/main"
SERVER_JS_URL="$GITHUB_RAW/server.js"
PACKAGE_JSON_URL="$GITHUB_RAW/package.json"
INDEX_HTML_URL="$GITHUB_RAW/index.html"
STYLE_CSS_URL="$GITHUB_RAW/style.css"
APP_JS_URL="$GITHUB_RAW/app.js"

# Create necessary directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$WEB_DIR"
mkdir -p "$PUBLIC_DIR"

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}╔════════════════════════════════════╗${RESET}"
        echo -e "${RED}║     Docker Not Installed!         ║${RESET}"
        echo -e "${RED}╚════════════════════════════════════╝${RESET}"
        echo -e "${YELLOW}Installing Docker automatically...${RESET}"
        
        # Detect OS and install Docker
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            OS=$ID
            if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
                sudo apt-get update
                sudo apt-get install -y docker.io
                sudo systemctl start docker
                sudo systemctl enable docker
            elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
                sudo yum install -y docker
                sudo systemctl start docker
                sudo systemctl enable docker
            else
                echo -e "${RED}Unsupported OS. Please install Docker manually.${RESET}"
                exit 1
            fi
        fi
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        echo -e "${RED}Docker daemon is not running. Starting Docker...${RESET}"
        sudo systemctl start docker
        sleep 2
    fi
}

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Clear screen with animation
clear_screen() {
    echo -e "\033[2J\033[0;0H"
    sleep 0.1
}

# Show premium banner
show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo '╔══════════════════════════════════════════════════════════╗'
    echo '║     ███╗   ██╗███████╗██████╗ ██╗   ██╗██╗      █████╗  ║'
    echo '║     ████╗  ██║██╔════╝██╔══██╗██║   ██║██║     ██╔══██╗ ║'
    echo '║     ██╔██╗ ██║█████╗  ██████╔╝██║   ██║██║     ███████║ ║'
    echo '║     ██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║ ║'
    echo '║     ██║ ╚████║███████╗██████╔╝╚██████╔╝███████╗██║  ██║ ║'
    echo '║     ╚═╝  ╚═══╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ║'
    echo '║                    DOCKER MANAGEMENT v1.0                ║'
    echo '║                   Created By © Mfsavana 2026             ║'
    echo '╚══════════════════════════════════════════════════════════╝'
    echo -e "${RESET}"
}

# Validate container name
validate_name() {
    local name=$1
    if [[ ! $name =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]+$ ]]; then
        echo -e "${RED}✗ Invalid container name!${RESET}"
        echo -e "${YELLOW}Use only letters, numbers, dots, hyphens, and underscores${RESET}"
        echo -e "${YELLOW}Must start with letter or number${RESET}"
        return 1
    fi
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$name$"; then
        echo -e "${RED}✗ Container '$name' already exists!${RESET}"
        return 1
    fi
    return 0
}

# Container exists check
container_exists() {
    local name=$1
    if ! docker ps -a --format '{{.Names}}' | grep -q "^$name$"; then
        echo -e "${RED}✗ Container '$name' not found!${RESET}"
        return 1
    fi
    return 0
}

# Get available OS images
get_os_images() {
    echo -e "${CYAN}Available Docker Images:${RESET}"
    echo -e "${WHITE}1) Ubuntu 22.04 LTS${RESET}"
    echo -e "${WHITE}2) Ubuntu 20.04 LTS${RESET}"
    echo -e "${WHITE}3) Debian 12${RESET}"
    echo -e "${WHITE}4) Debian 11${RESET}"
    echo -e "${WHITE}5) CentOS 9 Stream${RESET}"
    echo -e "${WHITE}6) Alpine Linux 3.19${RESET}"
    echo -e "${WHITE}7) Fedora 39${RESET}"
    echo -e "${WHITE}8) Arch Linux${RESET}"
    echo -e "${WHITE}9) Python 3.12-slim${RESET}"
    echo -e "${WHITE}10) Node.js 20-slim${RESET}"
    echo -e "${WHITE}11) Nginx Alpine${RESET}"
    echo -e "${WHITE}12) MySQL 8.0${RESET}"
    echo -e "${WHITE}13) PostgreSQL 16${RESET}"
    echo -e "${WHITE}14) Redis 7-alpine${RESET}"
    echo -e "${WHITE}15) Custom Image${RESET}"
}

# Get OS image name
get_os_image() {
    local choice=$1
    case $choice in
        1) echo "ubuntu:22.04" ;;
        2) echo "ubuntu:20.04" ;;
        3) echo "debian:12" ;;
        4) echo "debian:11" ;;
        5) echo "centos:stream9" ;;
        6) echo "alpine:3.19" ;;
        7) echo "fedora:39" ;;
        8) echo "archlinux:latest" ;;
        9) echo "python:3.12-slim" ;;
        10) echo "node:20-slim" ;;
        11) echo "nginx:alpine" ;;
        12) echo "mysql:8.0" ;;
        13) echo "postgres:16" ;;
        14) echo "redis:7-alpine" ;;
        15) 
            read -p "Enter custom image name: " custom
            echo "$custom"
            ;;
        *) echo "ubuntu:22.04" ;;
    esac
}

# Install OS-specific tools
install_os_tools() {
    local container=$1
    local os_type=$2
    
    echo -e "${YELLOW}Installing basic tools in container...${RESET}"
    
    if [[ $os_type == *"ubuntu"* ]] || [[ $os_type == *"debian"* ]]; then
        docker exec "$container" bash -c "apt-get update && apt-get install -y curl wget vim nano htop net-tools iputils-ping" &> /dev/null
    elif [[ $os_type == *"centos"* ]] || [[ $os_type == *"fedora"* ]]; then
        docker exec "$container" bash -c "yum install -y curl wget vim nano htop net-tools iputils" &> /dev/null
    elif [[ $os_type == *"alpine"* ]]; then
        docker exec "$container" sh -c "apk update && apk add curl wget vim nano htop net-tools" &> /dev/null
    elif [[ $os_type == *"arch"* ]]; then
        docker exec "$container" bash -c "pacman -Sy --noconfirm curl wget vim nano htop net-tools" &> /dev/null
    fi
    
    echo -e "${GREEN}✓ Tools installed successfully!${RESET}"
}

# Docker start function
docker_start() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Start Container            ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    stopped_containers=$(docker ps -f "status=exited" -f "status=created" --format '{{.Names}}')
    if [ -z "$stopped_containers" ]; then
        echo -e "${YELLOW}No stopped containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "Stopped containers:"
    echo "$stopped_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name to start: " name
    
    if container_exists "$name"; then
        if docker start "$name" &> /dev/null; then
            echo -e "${GREEN}✓ Container '$name' started successfully${RESET}"
            log "Started container: $name"
        else
            echo -e "${RED}✗ Failed to start container '$name'${RESET}"
        fi
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Docker stop function
docker_stop() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Stop Container             ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    running_containers=$(docker ps --format '{{.Names}}')
    if [ -z "$running_containers" ]; then
        echo -e "${YELLOW}No running containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "Running containers:"
    echo "$running_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name to stop: " name
    
    if container_exists "$name"; then
        if docker stop "$name" &> /dev/null; then
            echo -e "${GREEN}✓ Container '$name' stopped successfully${RESET}"
            log "Stopped container: $name"
        else
            echo -e "${RED}✗ Failed to stop container '$name'${RESET}"
        fi
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Docker restart function
docker_restart() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Restart Container          ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    all_containers=$(docker ps -a --format '{{.Names}}')
    if [ -z "$all_containers" ]; then
        echo -e "${YELLOW}No containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "All containers:"
    echo "$all_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name to restart: " name
    
    if container_exists "$name"; then
        if docker restart "$name" &> /dev/null; then
            echo -e "${GREEN}✓ Container '$name' restarted successfully${RESET}"
            log "Restarted container: $name"
        else
            echo -e "${RED}✗ Failed to restart container '$name'${RESET}"
        fi
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Docker rename function
docker_rename() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Rename Container           ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    all_containers=$(docker ps -a --format '{{.Names}}')
    if [ -z "$all_containers" ]; then
        echo -e "${YELLOW}No containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "Available containers:"
    echo "$all_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter current container name: " old_name
    
    if container_exists "$old_name"; then
        while true; do
            read -p "Enter new container name: " new_name
            if validate_name "$new_name"; then
                break
            fi
        done
        
        if docker rename "$old_name" "$new_name" &> /dev/null; then
            echo -e "${GREEN}✓ Container renamed from '$old_name' to '$new_name' successfully${RESET}"
            log "Renamed container: $old_name -> $new_name"
        else
            echo -e "${RED}✗ Failed to rename container${RESET}"
        fi
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Docker delete function
docker_delete() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Delete Container           ║${RESET}"
    echo -e "${RED}${BOLD}║        WARNING: IRREVERSIBLE!      ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    all_containers=$(docker ps -a --format '{{.Names}}')
    if [ -z "$all_containers" ]; then
        echo -e "${YELLOW}No containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "Available containers:"
    echo "$all_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name to delete: " name
    
    if container_exists "$name"; then
        echo -e "${RED}Are you sure you want to delete container '$name'?${RESET}"
        read -p "Type DELETE to confirm: " confirmation
        
        if [ "$confirmation" = "DELETE" ]; then
            echo -e "${YELLOW}Stopping container...${RESET}"
            docker stop "$name" &> /dev/null
            
            echo -e "${YELLOW}Removing container...${RESET}"
            if docker rm "$name" &> /dev/null; then
                echo -e "${GREEN}✓ Container '$name' deleted successfully${RESET}"
                log "Deleted container: $name"
            else
                echo -e "${RED}✗ Failed to delete container${RESET}"
            fi
        else
            echo -e "${YELLOW}Deletion cancelled${RESET}"
        fi
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Create container
create_container() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Create New Container       ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    # Get container name
    while true; do
        read -p "Enter container name: " name
        if validate_name "$name"; then
            break
        fi
    done
    
    # Get hostname
    read -p "Enter hostname (default: $name): " hostname
    if [ -z "$hostname" ]; then
        hostname=$name
    fi
    
    # Select OS
    echo ""
    get_os_images
    echo ""
    read -p "Select image [1-15] (default: 1): " os_choice
    os_choice=${os_choice:-1}
    image=$(get_os_image "$os_choice")
    
    # Select resources
    echo ""
    echo -e "${CYAN}Resource Allocation:${RESET}"
    read -p "CPU cores (default: 1): " cpu
    cpu=${cpu:-1}
    read -p "Memory in MB (default: 512): " memory
    memory=${memory:-512}
    
    # Port mapping
    echo ""
    echo -e "${CYAN}Port Mapping (optional):${RESET}"
    echo "Format: 8080:80 or 8080:80,8081:443 for multiple"
    read -p "Map ports (leave empty to skip): " ports
    
    # Volume mounting
    echo ""
    echo -e "${CYAN}Volume Mounting (optional):${RESET}"
    echo "Format: /host/path:/container/path"
    read -p "Mount volumes (leave empty to skip): " volumes
    
    # Environment variables
    echo ""
    echo -e "${CYAN}Environment Variables (optional):${RESET}"
    echo "Format: KEY=VALUE or KEY1=VALUE1,KEY2=VALUE2"
    read -p "Set env vars (leave empty to skip): " env_vars
    
    # Create container with specified resources
    echo -e "${YELLOW}Creating container '$name' with $image...${RESET}"
    
    # Build docker run command
    cmd="docker run -dit"
    cmd+=" --name $name"
    cmd+=" --hostname $hostname"
    cmd+=" --restart unless-stopped"
    
    # Add resource limits
    if [ ! -z "$cpu" ]; then
        cmd+=" --cpus $cpu"
    fi
    
    if [ ! -z "$memory" ]; then
        cmd+=" --memory ${memory}M"
    fi
    
    # Add port mapping
    if [ ! -z "$ports" ]; then
        IFS=',' read -ra PORT_ARRAY <<< "$ports"
        for port in "${PORT_ARRAY[@]}"; do
            cmd+=" -p $port"
        done
    fi
    
    # Add volume mounting
    if [ ! -z "$volumes" ]; then
        IFS=',' read -ra VOL_ARRAY <<< "$volumes"
        for vol in "${VOL_ARRAY[@]}"; do
            cmd+=" -v $vol"
        done
    fi
    
    # Add environment variables
    if [ ! -z "$env_vars" ]; then
        IFS=',' read -ra ENV_ARRAY <<< "$env_vars"
        for env in "${ENV_ARRAY[@]}"; do
            cmd+=" -e $env"
        done
    fi
    
    cmd+=" $image"
    
    # Special handling for different image types
    if [[ $image == *"mysql"* ]]; then
        cmd+=" --mysql-native-password=ON"
    elif [[ $image == *"postgres"* ]]; then
        cmd+=" postgres"
    elif [[ $image == *"nginx"* ]]; then
        cmd+=" nginx -g 'daemon off;'"
    elif [[ $image == *"redis"* ]]; then
        cmd+=" redis-server"
    else
        cmd+=" bash"
    fi
    
    if eval $cmd; then
        echo -e "${GREEN}✓ Container created successfully!${RESET}"
        container_id=$(docker ps -aqf "name=$name")
        echo -e "Container ID: ${YELLOW}$container_id${RESET}"
        
        # Install basic tools for OS images
        if [[ $image != *"mysql"* ]] && [[ $image != *"postgres"* ]] && [[ $image != *"nginx"* ]] && [[ $image != *"redis"* ]]; then
            install_os_tools "$name" "$image"
        fi
        
        log "Created container: $name ($image) with CPU: $cpu, RAM: ${memory}MB"
    else
        echo -e "${RED}✗ Failed to create container!${RESET}"
        log "Failed to create container: $name"
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Enter container
enter_container() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Enter Container            ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    running_containers=$(docker ps --format '{{.Names}}')
    if [ -z "$running_containers" ]; then
        echo -e "${YELLOW}No running containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo -e "${CYAN}Running Containers:${RESET}"
    echo "$running_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name to access: " name
    
    if container_exists "$name"; then
        echo -e "${GREEN}Accessing container '$name'...${RESET}"
        echo -e "${YELLOW}Type 'exit' to return to menu${RESET}"
        sleep 1
        
        clear
        # Try bash first, then sh
        docker exec -it "$name" bash 2>/dev/null || docker exec -it "$name" sh
        
        clear_screen
        show_banner
        log "Accessed container: $name"
    fi
}

# List containers with detailed info
list_containers() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Container List             ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    total=$(docker ps -a -q | wc -l)
    running=$(docker ps -q | wc -l)
    
    echo -e "${CYAN}Total Containers: $total | Running: $running | Stopped: $((total - running))${RESET}"
    echo ""
    
    # Table header
    printf "${WHITE}${BOLD}%-25s %-15s %-25s %-15s %-20s %s${RESET}\n" "NAME" "STATUS" "CREATED" "CPU" "MEMORY" "IMAGE"
    echo "────────────────────────────────────────────────────────────────────────────────────────────────────"
    
    docker ps -a --format '{{.Names}}' | while read name; do
        if [ -z "$name" ]; then continue; fi
        
        status=$(docker ps -a --filter "name=$name" --format '{{.Status}}')
        created=$(docker inspect --format='{{.Created}}' "$name" 2>/dev/null | cut -d'T' -f1)
        image=$(docker inspect --format='{{.Config.Image}}' "$name" 2>/dev/null)
        
        # Get stats for running containers
        if docker ps --filter "name=$name" --format '{{.Names}}' | grep -q "^$name$"; then
            cpu=$(docker stats --no-stream --format "{{.CPUPerc}}" "$name" 2>/dev/null || echo "0%")
            mem=$(docker stats --no-stream --format "{{.MemUsage}}" "$name" 2>/dev/null | cut -d'/' -f1 || echo "0B")
            status_color="${GREEN}"
        else
            cpu="0%"
            mem="0B"
            status_color="${RED}"
        fi
        
        printf "${status_color}%-25s %-15s %-25s %-15s %-20s %s${RESET}\n" \
            "$name" \
            "$(echo $status | cut -d' ' -f1)" \
            "$created" \
            "$cpu" \
            "$mem" \
            "$image"
    done
    
    echo ""
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Show container stats
show_stats() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║        Container Stats            ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    if [ -z "$(docker ps -q)" ]; then
        echo -e "${YELLOW}No running containers to show stats${RESET}"
    else
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# View container logs
view_logs() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║          View Logs                ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    all_containers=$(docker ps -a --format '{{.Names}}')
    if [ -z "$all_containers" ]; then
        echo -e "${YELLOW}No containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "Available containers:"
    echo "$all_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name to view logs: " name
    
    if container_exists "$name"; then
        read -p "Number of lines to show (default: 50): " lines
        lines=${lines:-50}
        
        echo -e "${YELLOW}Showing last $lines lines of logs...${RESET}"
        echo "────────────────────────────────────"
        docker logs --tail "$lines" "$name"
        echo "────────────────────────────────────"
        
        read -p "Press Enter to continue..."
    fi
    
    clear_screen
    show_banner
}

# Execute command in container
exec_command() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║      Execute Command              ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    running_containers=$(docker ps --format '{{.Names}}')
    if [ -z "$running_containers" ]; then
        echo -e "${YELLOW}No running containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "Running containers:"
    echo "$running_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name: " name
    
    if container_exists "$name" && docker ps --format '{{.Names}}' | grep -q "^$name$"; then
        read -p "Enter command to execute: " command
        
        echo -e "${YELLOW}Executing: $command${RESET}"
        echo "────────────────────────────────────"
        docker exec "$name" bash -c "$command" 2>/dev/null || docker exec "$name" sh -c "$command"
        echo "────────────────────────────────────"
        
        log "Executed command in $name: $command"
    else
        echo -e "${RED}Container not running or doesn't exist${RESET}"
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Backup container
backup_container() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║         Backup Container          ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    all_containers=$(docker ps -a --format '{{.Names}}')
    if [ -z "$all_containers" ]; then
        echo -e "${YELLOW}No containers available${RESET}"
        read -p "Press Enter to continue..."
        clear_screen
        show_banner
        return
    fi
    
    echo "Available containers:"
    echo "$all_containers" | nl -w2 -s') '
    echo ""
    
    read -p "Enter container name to backup: " name
    
    if container_exists "$name"; then
        backup_dir="$CONFIG_DIR/backups"
        mkdir -p "$backup_dir"
        backup_file="$backup_dir/${name}_$(date +%Y%m%d_%H%M%S).tar"
        
        echo -e "${YELLOW}Creating backup...${RESET}"
        
        # Stop container if running
        was_running=false
        if docker ps --format '{{.Names}}' | grep -q "^$name$"; then
            was_running=true
            docker stop "$name" &> /dev/null
        fi
        
        # Create backup
        docker commit "$name" "${name}-backup" &> /dev/null
        docker save -o "$backup_file" "${name}-backup" &> /dev/null
        docker rmi "${name}-backup" &> /dev/null
        
        # Start container if it was running
        if [ "$was_running" = true ]; then
            docker start "$name" &> /dev/null
        fi
        
        if [ -f "$backup_file" ]; then
            echo -e "${GREEN}✓ Backup created: $backup_file${RESET}"
            log "Backed up container: $name"
        else
            echo -e "${RED}✗ Backup failed${RESET}"
        fi
    fi
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Download web panel files
download_web_files() {
    echo -e "${YELLOW}Downloading web panel files...${RESET}"
    
    # Download server.js
    if command -v curl &> /dev/null; then
        curl -s -o "$WEB_DIR/server.js" "$SERVER_JS_URL"
        curl -s -o "$WEB_DIR/package.json" "$PACKAGE_JSON_URL"
        curl -s -o "$PUBLIC_DIR/index.html" "$INDEX_HTML_URL"
        curl -s -o "$PUBLIC_DIR/style.css" "$STYLE_CSS_URL"
        curl -s -o "$PUBLIC_DIR/app.js" "$APP_JS_URL"
    elif command -v wget &> /dev/null; then
        wget -q -O "$WEB_DIR/server.js" "$SERVER_JS_URL"
        wget -q -O "$WEB_DIR/package.json" "$PACKAGE_JSON_URL"
        wget -q -O "$PUBLIC_DIR/index.html" "$INDEX_HTML_URL"
        wget -q -O "$PUBLIC_DIR/style.css" "$STYLE_CSS_URL"
        wget -q -O "$PUBLIC_DIR/app.js" "$APP_JS_URL"
    else
        echo -e "${RED}Neither curl nor wget found. Please install one.${RESET}"
        return 1
    fi
    
    # Check if files were downloaded
    if [ -f "$WEB_DIR/server.js" ] && [ -f "$PUBLIC_DIR/index.html" ]; then
        echo -e "${GREEN}✓ Web panel files downloaded successfully${RESET}"
        return 0
    else
        echo -e "${RED}✗ Failed to download web panel files${RESET}"
        return 1
    fi
}

# Web panel management
setup_web_panel() {
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}${BOLD}║       Web Panel Management        ║${RESET}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${CYAN}1) Start Web Panel${RESET}"
    echo -e "${CYAN}2) Stop Web Panel${RESET}"
    echo -e "${CYAN}3) Restart Web Panel${RESET}"
    echo -e "${CYAN}4) Show Web Panel Status${RESET}"
    echo -e "${CYAN}5) Install/Update Web Panel Files${RESET}"
    echo -e "${CYAN}6) Back to Main Menu${RESET}"
    echo ""
    
    read -p "Choose option [1-6]: " web_choice
    
    case $web_choice in
        1)
            # Check if node is installed
            if ! command -v node &> /dev/null; then
                echo -e "${YELLOW}Node.js not found. Installing...${RESET}"
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt-get install -y nodejs
            fi
            
            # Download files if they don't exist
            if [ ! -f "$WEB_DIR/server.js" ] || [ ! -f "$PUBLIC_DIR/index.html" ]; then
                download_web_files
            fi
            
            # Install PM2 if not present
            if ! command -v pm2 &> /dev/null; then
                npm install -g pm2
            fi
            
            # Install dependencies
            cd "$WEB_DIR"
            npm install
            
            # Start with PM2
            pm2 start server.js --name "nebula-docker"
            pm2 save
            pm2 startup
            
            # Get IP address
            IP=$(hostname -I | awk '{print $1}')
            
            echo -e "${GREEN}✓ Web panel started successfully!${RESET}"
            echo -e "${YELLOW}Access at: http://$IP:3000${RESET}"
            echo -e "${YELLOW}Local access: http://localhost:3000${RESET}"
            ;;
        2)
            pm2 stop nebula-docker
            echo -e "${GREEN}✓ Web panel stopped${RESET}"
            ;;
        3)
            pm2 restart nebula-docker
            echo -e "${GREEN}✓ Web panel restarted${RESET}"
            ;;
        4)
            pm2 status nebula-docker
            ;;
        5)
            download_web_files
            ;;
        6)
            clear_screen
            show_banner
            return
            ;;
    esac
    
    read -p "Press Enter to continue..."
    clear_screen
    show_banner
}

# Show menu
show_menu() {
    echo -e "${BOLD}${WHITE}┌──────────────────────────────────────┐${RESET}"
    echo -e "${BOLD}${WHITE}│           MAIN MENU                   │${RESET}"
    echo -e "${BOLD}${WHITE}├──────────────────────────────────────┤${RESET}"
    echo -e "${WHITE}│  ${CYAN}1${WHITE}) Create Container                 │${RESET}"
    echo -e "${WHITE}│  ${CYAN}2${WHITE}) Enter Container                  │${RESET}"
    echo -e "${WHITE}│  ${CYAN}3${WHITE}) Start Container                  │${RESET}"
    echo -e "${WHITE}│  ${CYAN}4${WHITE}) Stop Container                   │${RESET}"
    echo -e "${WHITE}│  ${CYAN}5${WHITE}) Restart Container                │${RESET}"
    echo -e "${WHITE}│  ${CYAN}6${WHITE}) Rename Container                 │${RESET}"
    echo -e "${WHITE}│  ${CYAN}7${WHITE}) Delete Container                 │${RESET}"
    echo -e "${WHITE}│  ${CYAN}8${WHITE}) List Containers                  │${RESET}"
    echo -e "${WHITE}│  ${CYAN}9${WHITE}) Show Container Stats             │${RESET}"
    echo -e "${WHITE}│  ${CYAN}10${WHITE}) View Container Logs              │${RESET}"
    echo -e "${WHITE}│  ${CYAN}11${WHITE}) Execute Command                  │${RESET}"
    echo -e "${WHITE}│  ${CYAN}12${WHITE}) Backup Container                 │${RESET}"
    echo -e "${WHITE}│  ${CYAN}13${WHITE}) Web Panel Management             │${RESET}"
    echo -e "${WHITE}│  ${CYAN}14${WHITE}) Exit                             │${RESET}"
    echo -e "${BOLD}${WHITE}└──────────────────────────────────────┘${RESET}"
    echo ""
}

# Main function
main() {
    check_docker
    clear_screen
    show_banner
    
    while true; do
        show_menu
        read -p "Select option [1-14]: " choice
        
        case $choice in
            1) create_container ;;
            2) enter_container ;;
            3) docker_start ;;
            4) docker_stop ;;
            5) docker_restart ;;
            6) docker_rename ;;
            7) docker_delete ;;
            8) list_containers ;;
            9) show_stats ;;
            10) view_logs ;;
            11) exec_command ;;
            12) backup_container ;;
            13) setup_web_panel ;;
            14) 
                echo -e "${GREEN}Thank you for using Nebula Docker!${RESET}"
                echo -e "${CYAN}Created By © Mfsavana 2026${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please choose 1-14${RESET}"
                sleep 1
                clear_screen
                show_banner
                ;;
        esac
    done
}

# Run main function
main
