#!/bin/bash

################################################################################
# System Cleanup Script for Ubuntu
# Description: Clean up unnecessary files to free up disk space
# Updated: 2026-01-05
# - Added UV cache cleanup
# - Added Minikube cache cleanup
# - Added Microsoft Edge cache cleanup
# - Added Trash cleanup
# - Added shader cache cleanup
# - Added zsh completion cache cleanup
# - Dynamic user detection
################################################################################

set -e

echo "================================"
echo "System Cleanup Script Started"
echo "================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print info messages
print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges. Please run with sudo."
    exit 1
fi

# Show initial disk usage
echo "Initial disk usage:"
df -h / | grep -E 'Filesystem|/dev'
echo ""

# Get all regular users (UID >= 1000)
REGULAR_USERS=$(awk -F: '$3 >= 1000 && $3 < 65534 {print $1":"$6}' /etc/passwd)

# 1. Clean APT package manager cache
print_info "Cleaning APT package manager cache..."
apt-get clean 2>/dev/null || true
apt-get autoclean 2>/dev/null || true
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/cache/apt/archives/partial/*
print_success "APT cache cleaned"
echo ""

# 2. Remove unused packages
print_info "Removing unused packages..."
apt-get autoremove -y 2>&1 | grep -E "freed|removed|Removing" || true
print_success "Unused packages removed"
echo ""

# 3. Clean old log files
print_info "Cleaning old rotated log files (older than 30 days)..."
find /var/log -type f \( -name "*.log.[0-9]*" -o -name "*.log-*" -o -name "*.gz" \) -mtime +30 -exec rm -f {} \; 2>/dev/null
print_success "Old rotated logs cleaned"
echo ""

# 4. Clean old btmp logs
print_info "Cleaning old btmp logs..."
rm -f /var/log/btmp-* 2>/dev/null
truncate -s 0 /var/log/btmp 2>/dev/null
print_success "btmp logs cleaned"
echo ""

# 5. Clean systemd journal logs (keep last 7 days)
print_info "Cleaning systemd journal logs (keeping last 7 days)..."
journalctl --vacuum-time=7d 2>&1 | grep -i "freed" || true
print_success "Journal logs cleaned"
echo ""

# 6. Clean /tmp directory (files older than 7 days)
print_info "Cleaning /tmp directory (files older than 7 days)..."
find /tmp -type f -mtime +7 -delete 2>/dev/null || true
find /tmp -type d -empty -delete 2>/dev/null || true
print_success "/tmp directory cleaned"
echo ""

# 7. Clean snap cache (if snap is installed)
if command -v snap &> /dev/null; then
    print_info "Cleaning snap old revisions..."
    snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
        snap remove "$snapname" --revision="$revision" 2>/dev/null || true
    done
    print_success "Snap old revisions cleaned"
    echo ""
fi

# 8. Clean npm cache (if npm is installed)
if command -v npm &> /dev/null; then
    print_info "Cleaning npm cache..."
    npm cache clean --force 2>&1 | grep -v "^$" || true
    print_success "npm cache cleaned"
    echo ""
fi

# 9. Clean user cache directories for all regular users
print_info "Cleaning user cache directories..."
echo "$REGULAR_USERS" | while IFS=: read username homedir; do
    if [ -d "$homedir" ]; then
        echo "  Processing user: $username"

        # UV cache (Python package manager)
        if [ -d "$homedir/.cache/uv" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.cache/uv" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.cache/uv"
            echo "    ✓ UV cache cleaned ($SIZE_BEFORE)"
        fi

        # Microsoft Edge cache
        if [ -d "$homedir/.cache/microsoft-edge" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.cache/microsoft-edge" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.cache/microsoft-edge"
            echo "    ✓ Microsoft Edge cache cleaned ($SIZE_BEFORE)"
        fi

        # Homebrew cache
        if [ -d "$homedir/.cache/Homebrew" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.cache/Homebrew" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.cache/Homebrew"
            echo "    ✓ Homebrew cache cleaned ($SIZE_BEFORE)"
        fi

        # pip cache
        if [ -d "$homedir/.cache/pip" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.cache/pip" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.cache/pip"
            echo "    ✓ pip cache cleaned ($SIZE_BEFORE)"
        fi

        # Helm cache
        if [ -d "$homedir/.cache/helm" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.cache/helm" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.cache/helm"
            echo "    ✓ helm cache cleaned ($SIZE_BEFORE)"
        fi

        # Minikube cache
        if [ -d "$homedir/.minikube/cache" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.minikube/cache" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.minikube/cache"
            echo "    ✓ Minikube cache cleaned ($SIZE_BEFORE)"
        fi

        # npm global cache
        if [ -d "$homedir/.npm" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.npm" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.npm"
            echo "    ✓ npm global cache cleaned ($SIZE_BEFORE)"
        fi

        # Thumbnail cache
        if [ -d "$homedir/.cache/thumbnails" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.cache/thumbnails" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.cache/thumbnails"
            echo "    ✓ Thumbnail cache cleaned ($SIZE_BEFORE)"
        fi

        # Mesa shader cache
        if [ -d "$homedir/.cache/mesa_shader_cache" ] || [ -d "$homedir/.cache/mesa_shader_cache_db" ]; then
            rm -rf "$homedir/.cache/mesa_shader_cache" "$homedir/.cache/mesa_shader_cache_db" 2>/dev/null
            echo "    ✓ Mesa shader cache cleaned"
        fi

        # Trash
        if [ -d "$homedir/.local/share/Trash" ]; then
            SIZE_BEFORE=$(du -sh "$homedir/.local/share/Trash" 2>/dev/null | cut -f1)
            rm -rf "$homedir/.local/share/Trash/"* 2>/dev/null || true
            echo "    ✓ Trash cleaned ($SIZE_BEFORE)"
        fi

        # zsh completion dumps
        if ls "$homedir/.zcompdump"* >/dev/null 2>&1; then
            rm -f "$homedir/.zcompdump"* 2>/dev/null
            echo "    ✓ zsh completion dumps cleaned"
        fi

        # Backup files in home directory
        if ls "$homedir/"*.backup >/dev/null 2>&1; then
            rm -f "$homedir/"*.backup 2>/dev/null
            echo "    ✓ Backup files cleaned"
        fi
    fi
done
print_success "User cache directories cleaned"
echo ""

# 10. Clean Docker resources (if Docker is installed)
if command -v docker &> /dev/null; then
    print_info "Cleaning Docker unused resources..."
    docker system prune -a -f 2>&1 | tail -5 || true
    print_success "Docker resources cleaned"
    echo ""
fi

# 11. Remove old kernels (keep current + one previous)
print_info "Checking for old kernels..."
CURRENT_KERNEL=$(uname -r)
dpkg --list | grep linux-image | awk '{print $2}' | grep -v "$CURRENT_KERNEL" | sort -V | head -n -1 | while read kernel; do
    apt-get purge -y "$kernel" 2>&1 | grep -E "Removing|Purging" || true
done
print_success "Old kernels checked and cleaned"
echo ""

# Show final disk usage
echo "================================"
echo "Final disk usage:"
df -h / | grep -E 'Filesystem|/dev'
echo ""

# Show space usage by major directories
echo "Space usage by major directories:"
du -sh /var /home /tmp /usr 2>/dev/null | sort -h
echo ""

# Show home directory sizes
echo "Home directory sizes:"
echo "$REGULAR_USERS" | while IFS=: read username homedir; do
    if [ -d "$homedir" ]; then
        SIZE=$(du -sh "$homedir" 2>/dev/null | cut -f1)
        echo "  $username: $SIZE"
    fi
done
echo ""

echo "================================"
print_success "System cleanup completed!"
echo "================================"
