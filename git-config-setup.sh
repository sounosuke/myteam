#!/bin/bash

# =============================================================================
# Git Configuration Setup Script for AI Multi-Agent Parallel Execution System
# =============================================================================

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# Default Git configuration
DEFAULT_USER_NAME="AI Team System"
DEFAULT_USER_EMAIL="ai-team@myteam.local"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

check_git_repository() {
    if [ ! -d "$PROJECT_ROOT/.git" ]; then
        warn "Not a Git repository. Initializing..."
        cd "$PROJECT_ROOT"
        git init
        log "Git repository initialized"
    fi
}

check_dependencies() {
    info "Checking dependencies..."
    
    if ! command -v git &> /dev/null; then
        error "Git is not installed. Please install Git and try again."
    fi
    
    if ! command -v bash &> /dev/null; then
        error "Bash is not available. This script requires Bash."
    fi
    
    log "All dependencies are available"
}

# =============================================================================
# GIT BASIC CONFIGURATION
# =============================================================================

configure_git_basics() {
    log "Configuring Git basic settings..."
    
    # Set user name and email if not already set
    if [ -z "$(git config user.name 2>/dev/null || true)" ]; then
        read -p "Enter your name (default: $DEFAULT_USER_NAME): " user_name
        user_name=${user_name:-$DEFAULT_USER_NAME}
        git config user.name "$user_name"
        log "Set user.name to '$user_name'"
    fi
    
    if [ -z "$(git config user.email 2>/dev/null || true)" ]; then
        read -p "Enter your email (default: $DEFAULT_USER_EMAIL): " user_email
        user_email=${user_email:-$DEFAULT_USER_EMAIL}
        git config user.email "$user_email"
        log "Set user.email to '$user_email'"
    fi
    
    # Configure core settings
    git config core.autocrlf input
    git config core.filemode true
    git config core.ignorecase false
    
    # Configure push settings
    git config push.default current
    git config push.autoSetupRemote true
    
    # Configure pull settings
    git config pull.rebase true
    
    # Configure merge settings
    git config merge.conflictstyle diff3
    
    # Configure branch settings
    git config branch.autosetupmerge always
    git config branch.autosetuprebase always
    
    log "Git basic configuration completed"
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

configure_security() {
    log "Configuring Git security settings..."
    
    # Configure safe directory (for security)
    git config --global --add safe.directory "$PROJECT_ROOT"
    
    # Configure credential helper timeout
    git config credential.helper cache
    git config credential.cacheTimeout 3600
    
    # Configure signing (optional)
    read -p "Do you want to configure GPG signing? (y/N): " enable_signing
    if [[ $enable_signing =~ ^[Yy]$ ]]; then
        read -p "Enter your GPG key ID: " gpg_key_id
        if [ -n "$gpg_key_id" ]; then
            git config user.signingkey "$gpg_key_id"
            git config commit.gpgsign true
            git config tag.gpgsign true
            log "GPG signing configured with key: $gpg_key_id"
        fi
    fi
    
    log "Security configuration completed"
}

# =============================================================================
# PERFORMANCE OPTIMIZATION
# =============================================================================

configure_performance() {
    log "Configuring Git performance optimizations..."
    
    # Configure garbage collection
    git config gc.auto 6700
    git config gc.autodetach true
    
    # Configure pack settings
    git config pack.window 250
    git config pack.depth 50
    git config pack.windowMemory 100m
    git config pack.packSizeLimit 2g
    
    # Configure diff settings
    git config diff.algorithm histogram
    git config diff.renames true
    git config diff.mnemonicPrefix true
    
    # Configure status settings
    git config status.showUntrackedFiles all
    git config status.submoduleSummary true
    
    # Configure log settings
    git config log.date iso8601
    git config log.decorate short
    
    # Configure filesystem monitoring (if available)
    if command -v watchman &> /dev/null; then
        git config core.fsmonitor watchman
        log "Watchman filesystem monitoring enabled"
    fi
    
    log "Performance optimization completed"
}

# =============================================================================
# CUSTOM FILTERS SETUP
# =============================================================================

setup_custom_filters() {
    log "Setting up custom Git filters..."
    
    # Filter for sanitizing logs
    git config filter.sanitize-logs.clean 'sed "s/\(api[_-]*key\|token\|secret\|password\)[[:space:]]*[=:][[:space:]]*[^[:space:]]*/\1=***REDACTED***/gi"'
    git config filter.sanitize-logs.smudge cat
    
    # Filter for sanitizing config files
    git config filter.sanitize-config.clean 'sed "s/\(api[_-]*key\|token\|secret\|password\)[[:space:]]*[=:][[:space:]]*[^[:space:]]*/\1=***REDACTED***/gi"'
    git config filter.sanitize-config.smudge cat
    
    # Filter for removing secrets
    git config filter.remove-secrets.clean 'echo "***SENSITIVE FILE REMOVED***"'
    git config filter.remove-secrets.smudge 'echo "***SENSITIVE FILE - RESTORE FROM SECURE BACKUP***"'
    
    log "Custom filters configured"
}

# =============================================================================
# GIT HOOKS SETUP
# =============================================================================

setup_git_hooks() {
    log "Setting up Git hooks..."
    
    # Create hooks directory if it doesn't exist
    mkdir -p "$GIT_HOOKS_DIR"
    
    # Pre-commit hook
    cat > "$GIT_HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash

# AI Team System Pre-commit Hook
# Checks for sensitive data and enforces code quality

set -e

echo "🔍 Running pre-commit checks..."

# Check for sensitive files
if git diff --cached --name-only | grep -E '\.(key|pem|p12|pfx)$'; then
    echo "❌ Error: Attempting to commit sensitive files!"
    echo "Please remove these files from the staging area:"
    git diff --cached --name-only | grep -E '\.(key|pem|p12|pfx)$'
    exit 1
fi

# Check for potential secrets in content
if git diff --cached | grep -i -E '(api[_-]*key|secret|password|token).*[=:]\s*[a-zA-Z0-9]+'; then
    echo "❌ Error: Potential secrets detected in staged changes!"
    echo "Please review and remove any sensitive data."
    exit 1
fi

# Check for large files
large_files=$(git diff --cached --name-only | xargs -I {} sh -c 'if [ -f "{}" ] && [ $(stat -f%z "{}" 2>/dev/null || stat -c%s "{}" 2>/dev/null || echo 0) -gt 10485760 ]; then echo "{}"; fi')
if [ -n "$large_files" ]; then
    echo "⚠️  Warning: Large files detected (>10MB):"
    echo "$large_files"
    echo "Consider using Git LFS for large files."
fi

# Check shell scripts syntax
for file in $(git diff --cached --name-only | grep '\.sh$'); do
    if [ -f "$file" ]; then
        if ! bash -n "$file"; then
            echo "❌ Error: Shell script syntax error in $file"
            exit 1
        fi
    fi
done

# Check for executable permissions on shell scripts
for file in $(git diff --cached --name-only | grep '\.sh$'); do
    if [ -f "$file" ] && [ ! -x "$file" ]; then
        echo "⚠️  Warning: $file is not executable. Making it executable..."
        chmod +x "$file"
        git add "$file"
    fi
done

echo "✅ Pre-commit checks passed!"
EOF

    # Pre-push hook
    cat > "$GIT_HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash

# AI Team System Pre-push Hook
# Additional checks before pushing to remote

set -e

echo "🚀 Running pre-push checks..."

# Check if we're pushing to main/master branch
protected_branch="main"
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ "$current_branch" = "$protected_branch" ]; then
    echo "⚠️  Warning: Pushing directly to $protected_branch branch!"
    read -p "Are you sure you want to continue? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "❌ Push cancelled."
        exit 1
    fi
fi

# Check for communication.log size
if [ -f "logs/communication.log" ]; then
    log_size=$(stat -f%z "logs/communication.log" 2>/dev/null || stat -c%s "logs/communication.log" 2>/dev/null || echo 0)
    if [ "$log_size" -gt 1048576 ]; then  # 1MB
        echo "⚠️  Warning: communication.log is large (>1MB). Consider archiving old logs."
    fi
fi

echo "✅ Pre-push checks passed!"
EOF

    # Post-commit hook
    cat > "$GIT_HOOKS_DIR/post-commit" << 'EOF'
#!/bin/bash

# AI Team System Post-commit Hook
# Cleanup and notifications after commit

echo "📝 Post-commit actions..."

# Log the commit to our system log
commit_hash=$(git rev-parse HEAD)
commit_message=$(git log -1 --pretty=%B)
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Commit: $commit_hash - $commit_message" >> logs/git-commits.log

# Cleanup temporary files
find . -name "*.tmp" -type f -delete 2>/dev/null || true
find . -name "*~" -type f -delete 2>/dev/null || true

echo "✅ Post-commit actions completed!"
EOF

    # Make hooks executable
    chmod +x "$GIT_HOOKS_DIR/pre-commit"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    chmod +x "$GIT_HOOKS_DIR/post-commit"
    
    log "Git hooks installed and configured"
}

# =============================================================================
# ALIASES SETUP
# =============================================================================

setup_git_aliases() {
    log "Setting up useful Git aliases..."
    
    # Status and info aliases
    git config alias.st status
    git config alias.br branch
    git config alias.co checkout
    git config alias.ci commit
    
    # Log aliases
    git config alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config alias.ll "log --oneline --graph --decorate --all"
    git config alias.ls "log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"
    
    # Diff aliases
    git config alias.df diff
    git config alias.dc "diff --cached"
    git config alias.dw "diff --word-diff"
    
    # Branch aliases
    git config alias.ba "branch -a"
    git config alias.bd "branch -d"
    git config alias.bD "branch -D"
    
    # Stash aliases
    git config alias.sl "stash list"
    git config alias.sa "stash apply"
    git config alias.ss "stash save"
    
    # Reset aliases
    git config alias.unstage "reset HEAD --"
    git config alias.uncommit "reset --soft HEAD~1"
    git config alias.filelog "log -u"
    
    # Advanced aliases
    git config alias.mt mergetool
    git config alias.patch "add --patch"
    git config alias.who "shortlog -s --"
    git config alias.whois "!sh -c 'git log -i --grep=\"\$1\" --pretty=\"format:%h %cd %an %s\" --date=short' -"
    
    log "Git aliases configured"
}

# =============================================================================
# REPOSITORY SPECIFIC CONFIGURATION
# =============================================================================

configure_repository_specific() {
    log "Configuring repository-specific settings..."
    
    # Configure .gitignore if it doesn't exist or is empty
    if [ ! -f "$PROJECT_ROOT/.gitignore" ] || [ ! -s "$PROJECT_ROOT/.gitignore" ]; then
        warn ".gitignore not found or empty. This should be created separately."
    fi
    
    # Configure .gitattributes if it doesn't exist
    if [ ! -f "$PROJECT_ROOT/.gitattributes" ] || [ ! -s "$PROJECT_ROOT/.gitattributes" ]; then
        warn ".gitattributes not found or empty. This should be created separately."
    fi
    
    # Create logs directory if it doesn't exist
    mkdir -p "$PROJECT_ROOT/logs"
    
    # Create git-commits.log for tracking
    touch "$PROJECT_ROOT/logs/git-commits.log"
    
    # Set up git log rotation for communication.log
    if [ -f "$PROJECT_ROOT/logs/communication.log" ]; then
        log_size=$(stat -f%z "$PROJECT_ROOT/logs/communication.log" 2>/dev/null || stat -c%s "$PROJECT_ROOT/logs/communication.log" 2>/dev/null || echo 0)
        if [ "$log_size" -gt 10485760 ]; then  # 10MB
            warn "communication.log is large (>10MB). Consider rotating logs."
        fi
    fi
    
    log "Repository-specific configuration completed"
}

# =============================================================================
# VALIDATION AND TESTING
# =============================================================================

validate_configuration() {
    log "Validating Git configuration..."
    
    # Test basic Git operations
    info "Testing Git configuration..."
    
    # Check if Git is properly configured
    if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
        error "Git user.name or user.email not configured properly"
    fi
    
    # Test Git hooks
    if [ -x "$GIT_HOOKS_DIR/pre-commit" ]; then
        log "✅ Pre-commit hook is executable"
    else
        warn "Pre-commit hook is not executable"
    fi
    
    # Test custom filters
    if git config filter.sanitize-logs.clean &>/dev/null; then
        log "✅ Custom filters are configured"
    else
        warn "Custom filters may not be configured properly"
    fi
    
    # Display final configuration
    info "Current Git configuration summary:"
    echo "  User: $(git config user.name) <$(git config user.email)>"
    echo "  Default branch: $(git config init.defaultBranch || echo 'master')"
    echo "  Push default: $(git config push.default)"
    echo "  Pull rebase: $(git config pull.rebase)"
    
    log "Git configuration validation completed"
}

# =============================================================================
# CLEANUP FUNCTIONS
# =============================================================================

cleanup() {
    log "Performing cleanup..."
    
    # Remove any temporary files created during setup
    find "$PROJECT_ROOT" -name "git-setup-*.tmp" -type f -delete 2>/dev/null || true
    
    log "Cleanup completed"
}

# =============================================================================
# BACKUP FUNCTIONS
# =============================================================================

backup_existing_config() {
    log "Creating backup of existing Git configuration..."
    
    local backup_file="$PROJECT_ROOT/git-config-backup-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "# Git Configuration Backup - $(date)"
        echo "# Repository: $PROJECT_ROOT"
        echo
        git config --list --local
    } > "$backup_file"
    
    log "Configuration backed up to: $backup_file"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo "======================================================================"
    echo "      AI Multi-Agent Parallel Execution System - Git Setup"
    echo "======================================================================"
    echo
    
    log "Starting Git configuration setup..."
    
    # Change to project directory
    cd "$PROJECT_ROOT"
    
    # Run setup functions
    check_dependencies
    check_git_repository
    backup_existing_config
    configure_git_basics
    configure_security
    configure_performance
    setup_custom_filters
    setup_git_hooks
    setup_git_aliases
    configure_repository_specific
    validate_configuration
    cleanup
    
    echo
    log "🎉 Git configuration setup completed successfully!"
    echo
    info "Next steps:"
    echo "  1. Review the configuration: git config --list --local"
    echo "  2. Test the hooks: Try making a commit"
    echo "  3. Configure remote repository: git remote add origin <url>"
    echo "  4. Make your first commit: git add . && git commit -m 'Initial commit'"
    echo
    warn "Remember to keep your credentials secure and never commit sensitive data!"
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Git Configuration Setup Script for AI Multi-Agent System"
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --validate     Only validate existing configuration"
        echo "  --backup       Only create backup of current configuration"
        echo
        echo "This script will configure Git with optimal settings for the"
        echo "AI Multi-Agent Parallel Execution System project."
        exit 0
        ;;
    --validate)
        validate_configuration
        exit 0
        ;;
    --backup)
        backup_existing_config
        exit 0
        ;;
    "")
        # No arguments, run main setup
        main
        ;;
    *)
        error "Unknown option: $1. Use --help for usage information."
        ;;
esac