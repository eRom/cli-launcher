#!/usr/bin/env bash
#
# CLI Launcher - Next.js Boilerplate Generator
# Version: 2.0.0
# Description: Script professionnel pour créer un projet Next.js avec configuration optimale
# Author: CLI Launcher Team
#
# Usage: ./ia-cli-launcher.sh [OPTIONS] [PROJECT_DIR]
#   --help          Show help message
#   --version       Show version
#   --dry-run       Simulate without executing
#   --verbose       Enable verbose output
#   --quiet         Suppress non-error output
#   --skip-install  Skip npm install steps
#   --project-dir   Specify project directory

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

readonly SCRIPT_NAME="ia-cli-launcher.sh"
readonly VERSION="2.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Template directory (can be overridden by environment variable)
readonly TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/dev/cli-launcher/templates}"

# Global flags
DRY_RUN=false
VERBOSE=false
QUIET=false
SKIP_INSTALL=false
PROJECT_DIR=""

# Colors (using tput for cross-platform compatibility)
if [[ -t 1 ]]; then
  readonly RED=$(tput setaf 1 2>/dev/null || echo "")
  readonly GREEN=$(tput setaf 2 2>/dev/null || echo "")
  readonly YELLOW=$(tput setaf 3 2>/dev/null || echo "")
  readonly BLUE=$(tput setaf 4 2>/dev/null || echo "")
  readonly MAGENTA=$(tput setaf 5 2>/dev/null || echo "")
  readonly CYAN=$(tput setaf 6 2>/dev/null || echo "")
  readonly RESET=$(tput sgr0 2>/dev/null || echo "")
  readonly BOLD=$(tput bold 2>/dev/null || echo "")
else
  readonly RED=""
  readonly GREEN=""
  readonly YELLOW=""
  readonly BLUE=""
  readonly MAGENTA=""
  readonly CYAN=""
  readonly RESET=""
  readonly BOLD=""
fi

# ============================================================================
# Logging Functions
# ============================================================================

log_info() {
  [[ "$QUIET" == false ]] && echo -e "${BLUE}ℹ${RESET} $*" >&2
}

log_success() {
  [[ "$QUIET" == false ]] && echo -e "${GREEN}✓${RESET} $*" >&2
}

log_warning() {
  [[ "$QUIET" == false ]] && echo -e "${YELLOW}⚠${RESET} $*" >&2
}

log_error() {
  echo -e "${RED}✗${RESET} $*" >&2
}

log_debug() {
  [[ "$VERBOSE" == true ]] && echo -e "${CYAN}[DEBUG]${RESET} $*" >&2
}

log_step() {
  [[ "$QUIET" == false ]] && echo -e "\n${BOLD}${MAGENTA}▶${RESET} ${BOLD}$*${RESET}" >&2
}

# ============================================================================
# Error Handling
# ============================================================================

cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    log_error "Script failed with exit code $exit_code"
    log_info "Check the logs above for details"
  fi
  exit $exit_code
}

trap cleanup EXIT INT TERM

# ============================================================================
# Help and Version
# ============================================================================

show_version() {
  echo "$SCRIPT_NAME version $VERSION"
}

show_help() {
  cat << EOF
${BOLD}CLI Launcher - Next.js Boilerplate Generator${RESET}

${BOLD}Usage:${RESET}
  $SCRIPT_NAME [OPTIONS] [PROJECT_DIR]

${BOLD}Description:${RESET}
  Creates a new Next.js 15 project with optimized configuration including:
  - Shadcn/ui components
  - Tailwind CSS v4
  - Prettier configuration
  - ESLint with accessibility rules
  - PWA support
  - Performance tools (Lighthouse, Axe)
  - Cursor IDE configuration

${BOLD}Options:${RESET}
  -h, --help          Show this help message and exit
  -v, --version       Show version and exit
  -d, --dry-run       Show what would be done without executing
  --verbose           Enable verbose output with debug information
  --quiet             Suppress non-error output
  --skip-install      Skip npm install steps (useful for testing)
  --project-dir DIR   Specify project directory (default: current directory)

${BOLD}Environment Variables:${RESET}
  TEMPLATE_DIR        Override template directory path
                      (default: \$HOME/dev/cli-launcher/templates)

${BOLD}Examples:${RESET}
  # Create project in current directory
  $SCRIPT_NAME

  # Create project in specific directory
  $SCRIPT_NAME --project-dir my-project

  # Dry run to see what would happen
  $SCRIPT_NAME --dry-run

  # Verbose mode for debugging
  $SCRIPT_NAME --verbose

  # Skip installations (for testing)
  $SCRIPT_NAME --skip-install

${BOLD}Exit Codes:${RESET}
  0    Success
  1    General error
  2    Missing prerequisites
  3    Invalid arguments
  4    Template directory not found

EOF
}

# ============================================================================
# Prerequisites Check
# ============================================================================

check_prerequisites() {
  log_step "Checking prerequisites..."

  local missing=()
  local errors=()

  # Check Node.js
  if ! command -v node &>/dev/null; then
    missing+=("node")
    errors+=("Node.js is required but not installed")
  else
    local node_version
    node_version=$(node --version 2>/dev/null || echo "unknown")
    log_debug "Node.js version: $node_version"
  fi

  # Check npm
  if ! command -v npm &>/dev/null; then
    missing+=("npm")
    errors+=("npm is required but not installed")
  else
    local npm_version
    npm_version=$(npm --version 2>/dev/null || echo "unknown")
    log_debug "npm version: $npm_version"
  fi

  # Check npx
  if ! command -v npx &>/dev/null; then
    missing+=("npx")
    errors+=("npx is required but not installed")
  else
    log_debug "npx is available"
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    log_error "Missing prerequisites: ${missing[*]}"
    for error in "${errors[@]}"; do
      log_error "  - $error"
    done
    log_info "Please install the missing prerequisites and try again"
    exit 2
  fi

  log_success "All prerequisites are available"
}

# ============================================================================
# Validation Functions
# ============================================================================

validate_template_dir() {
  if [[ ! -d "$TEMPLATE_DIR" ]]; then
    log_error "Template directory not found: $TEMPLATE_DIR"
    log_info "Set TEMPLATE_DIR environment variable to override"
    exit 4
  fi
  log_debug "Template directory: $TEMPLATE_DIR"
}

validate_project_dir() {
  if [[ -n "$PROJECT_DIR" ]]; then
    if [[ ! -d "$PROJECT_DIR" ]]; then
      log_warning "Project directory does not exist, creating: $PROJECT_DIR"
      if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$PROJECT_DIR"
      fi
    fi
    if [[ "$DRY_RUN" == false ]]; then
      cd "$PROJECT_DIR" || exit 1
    fi
    log_debug "Project directory: $PROJECT_DIR"
  else
    log_debug "Using current directory as project directory"
  fi
}

# ============================================================================
# Argument Parsing
# ============================================================================

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      -v|--version)
        show_version
        exit 0
        ;;
      -d|--dry-run)
        DRY_RUN=true
        log_info "Dry-run mode enabled (no changes will be made)"
        shift
        ;;
      --verbose)
        VERBOSE=true
        log_debug "Verbose mode enabled"
        shift
        ;;
      --quiet)
        QUIET=true
        shift
        ;;
      --skip-install)
        SKIP_INSTALL=true
        log_info "Skipping npm install steps"
        shift
        ;;
      --project-dir)
        if [[ -z "${2:-}" ]]; then
          log_error "--project-dir requires a directory path"
          exit 3
        fi
        PROJECT_DIR="$2"
        shift 2
        ;;
      -*)
        log_error "Unknown option: $1"
        log_info "Use --help for usage information"
        exit 3
        ;;
      *)
        if [[ -z "$PROJECT_DIR" ]]; then
          PROJECT_DIR="$1"
        else
          log_error "Unexpected argument: $1"
          log_info "Use --help for usage information"
          exit 3
        fi
        shift
        ;;
    esac
  done
}

# ============================================================================
# File Operations
# ============================================================================

safe_copy() {
  local source="$1"
  local dest="$2"
  local description="${3:-$(basename "$source")}"

  if [[ ! -f "$source" ]]; then
    log_warning "$description not found: $source"
    return 1
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would copy: $source -> $dest"
    return 0
  fi

  # Create destination directory if needed
  local dest_dir
  dest_dir=$(dirname "$dest")
  if [[ ! -d "$dest_dir" ]]; then
    mkdir -p "$dest_dir"
    log_debug "Created directory: $dest_dir"
  fi

  cp "$source" "$dest"
  log_success "$description copied"
  return 0
}

safe_mkdir() {
  local dir="$1"
  local description="${2:-Directory}"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would create directory: $dir"
    return 0
  fi

  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    log_debug "$description created: $dir"
  fi
}

# ============================================================================
# Template File Copying
# ============================================================================

copy_template_files() {
  log_step "Copying template files..."

  # Copy logo.png to public directory (not root)
  if [[ -f "$TEMPLATE_DIR/public/logo.png" ]]; then
    safe_copy "$TEMPLATE_DIR/public/logo.png" "./public/logo.png" "logo.png"
  fi

  # Copy documentation files
  safe_copy "$TEMPLATE_DIR/PROJECT_IDEA.md" "./PROJECT_IDEA.md" "PROJECT_IDEA.md"
  safe_copy "$TEMPLATE_DIR/AGENT.md" "./AGENT.md" "AGENT.md"
  safe_copy "$TEMPLATE_DIR/LIGHTHOUSE.md" "./LIGHTHOUSE.md" "LIGHTHOUSE.md"

  # Copy configuration files
  safe_copy "$TEMPLATE_DIR/components.json" "./components.json" "components.json"
  safe_copy "$TEMPLATE_DIR/.prettierrc.json" "./.prettierrc.json" ".prettierrc.json"
  safe_copy "$TEMPLATE_DIR/.prettierignore" "./.prettierignore" ".prettierignore"
  safe_copy "$TEMPLATE_DIR/eslint.config.mjs" "./.eslintrc.mjs" "eslint.config.mjs"
  safe_copy "$TEMPLATE_DIR/next.config.ts" "./next.config.ts" "next.config.ts"

  # Copy source files
  safe_mkdir "src/lib"
  safe_copy "$TEMPLATE_DIR/src/lib/utils.ts" "src/lib/utils.ts" "utils.ts"

  safe_mkdir "src/app"
  safe_copy "$TEMPLATE_DIR/src/app/layout.tsx" "src/app/layout.tsx" "layout.tsx"

  # Copy public files
  safe_mkdir "public"
  safe_copy "$TEMPLATE_DIR/public/manifest.json" "public/manifest.json" "manifest.json"
  safe_copy "$TEMPLATE_DIR/public/og.png" "public/og.png" "og.png"
  safe_copy "$TEMPLATE_DIR/public/unregister-sw.html" "public/unregister-sw.html" "unregister-sw.html"

  log_success "Template files copied"
}

# ============================================================================
# Scripts Copying
# ============================================================================

copy_scripts() {
  log_step "Copying scripts..."

  local scripts_dir="$TEMPLATE_DIR/scripts"
  local dest_dir="./scripts"

  if [[ ! -d "$scripts_dir" ]]; then
    log_warning "Scripts directory not found: $scripts_dir"
    return 0
  fi

  safe_mkdir "$dest_dir" "Scripts directory"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would copy scripts from: $scripts_dir"
    return 0
  fi

  # Copy all files from scripts directory
  if [[ -n "$(find "$scripts_dir" -maxdepth 1 -type f 2>/dev/null)" ]]; then
    cp -r "$scripts_dir"/* "$dest_dir/" 2>/dev/null || true
    local count
    count=$(find "$dest_dir" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
    log_success "Copied $count script file(s)"
  else
    log_info "No scripts found in template directory"
  fi
}

# ============================================================================
# Cursor Configuration
# ============================================================================

copy_cursor_config() {
  log_step "Copying Cursor configuration..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would copy Cursor commands and rules"
    return 0
  fi

  # Copy commands
  safe_mkdir ".cursor/commands"
  if [[ -d "$TEMPLATE_DIR/commands" ]] && [[ -n "$(find "$TEMPLATE_DIR/commands" -maxdepth 1 -name "*.md" 2>/dev/null)" ]]; then
    cp "$TEMPLATE_DIR/commands"/*.md ".cursor/commands/" 2>/dev/null || true
    log_success "Cursor commands copied"
  fi

  # Copy rules
  safe_mkdir ".cursor/rules"
  if [[ -d "$TEMPLATE_DIR/rules" ]] && [[ -n "$(find "$TEMPLATE_DIR/rules" -maxdepth 1 -name "*.mdc" 2>/dev/null)" ]]; then
    cp "$TEMPLATE_DIR/rules"/*.mdc ".cursor/rules/" 2>/dev/null || true
    log_success "Cursor rules copied"
  fi
}

# ============================================================================
# Next.js Project Creation
# ============================================================================

create_nextjs_project() {
  log_step "Creating Next.js project..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would run: npx create-next-app@latest . --yes"
    return 0
  fi

  if ! npx create-next-app@latest . --yes; then
    log_error "Failed to create Next.js project"
    exit 1
  fi

  log_success "Next.js project created"
}

# ============================================================================
# Shadcn Setup
# ============================================================================

setup_shadcn() {
  log_step "Setting up Shadcn/ui..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would install Shadcn components: button card sonner"
    return 0
  fi

  if ! npx shadcn@latest add button card sonner --yes; then
    log_error "Failed to install Shadcn components"
    exit 1
  fi

  log_success "Shadcn components installed"
}

# ============================================================================
# Dependencies Installation
# ============================================================================

install_dependencies() {
  if [[ "$SKIP_INSTALL" == true ]]; then
    log_info "Skipping dependency installation (--skip-install flag)"
    return 0
  fi

  log_step "Installing dependencies..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would install all npm dependencies"
    return 0
  fi

  # Production dependencies
  log_info "Installing production dependencies..."
  npm install clsx tailwind-merge next-themes qrcode @types/qrcode class-variance-authority lucide-react canvas || {
    log_error "Failed to install production dependencies"
    exit 1
  }

  # Development dependencies
  log_info "Installing development dependencies..."
  npm install --save-dev prettier @types/node sharp imagemin imagemin-webp imagemin-avif puppeteer lighthouse chrome-launcher eslint-plugin-jsx-a11y@latest @axe-core/cli@latest || {
    log_error "Failed to install development dependencies"
    exit 1
  }

  log_success "All dependencies installed"
}

# ============================================================================
# NPM Scripts Setup
# ============================================================================

setup_npm_scripts() {
  log_step "Setting up npm scripts..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY-RUN] Would configure npm scripts"
    return 0
  fi

  # Create aria-reports directory
  safe_mkdir "aria-reports"

  # Set npm scripts
  npm pkg set scripts.kill="for port in {3000..3002}; do lsof -ti:\$port | xargs kill -9 2>/dev/null; done" || true
  npm pkg set scripts.dev="npm run kill && next dev --turbopack" || true
  npm pkg set scripts.format="prettier --write ." || true
  npm pkg set scripts.lint="prettier --check ." || true
  npm pkg set scripts["lint:audit"]="npx eslint . --ext .js,.jsx,.ts,.tsx --format=json > aria-reports/eslint-a11y-report.json" || true
  npm pkg set scripts["format:staged"]="prettier --write" || true
  npm pkg set scripts["axe"]="npx axe http://localhost:3000 --tags wcag2a,wcag2aa,wcag21aa --save ./aria-reports/axe.json --exit" || true

  log_success "NPM scripts configured"
}

# ============================================================================
# Main Function
# ============================================================================

main() {
  # Parse arguments
  parse_args "$@"

  # Show header
  if [[ "$QUIET" == false ]]; then
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║     CLI Launcher - Next.js Boilerplate Generator          ║"
    echo "║                    Version $VERSION                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
  fi

  # Validate prerequisites
  check_prerequisites

  # Validate template directory
  validate_template_dir

  # Validate project directory
  validate_project_dir

  # Create Next.js project
  create_nextjs_project

  # Copy template files
  copy_template_files

  # Copy scripts
  copy_scripts

  # Setup Shadcn
  setup_shadcn

  # Install dependencies
  install_dependencies

  # Setup npm scripts
  setup_npm_scripts

  # Copy Cursor configuration
  copy_cursor_config

  # Success message
  if [[ "$QUIET" == false ]]; then
    echo ""
    log_success "Project setup completed successfully!"
    echo ""
    if [[ "$DRY_RUN" == false ]]; then
      log_info "Next steps:"
      echo "  1. Review the project structure"
      echo "  2. Update PROJECT_IDEA.md with your project details"
      echo "  3. Run 'npm run dev' to start the development server"
      echo ""
      log_info "Opening project in Cursor..."
      cursor . 2>/dev/null || log_warning "Could not open Cursor (cursor command not found)"
    fi
  fi
}

# ============================================================================
# Script Entry Point
# ============================================================================

# Run main function with all arguments
main "$@"
