#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# cf-doctor.sh — Setup validation and auto-fix for claude-flow + ruvector
#
# Usage:
#   ./cf-doctor.sh          # Check-only mode
#   ./cf-doctor.sh --fix    # Auto-install missing packages, create dirs
#   ./cf-doctor.sh --json   # Machine-readable JSON output
#   ./cf-doctor.sh --fix --json  # Both
#
# Exit codes:
#   0 — All checks passed (GREEN or YELLOW only)
#   1 — One or more RED failures detected
###############################################################################

# ---------------------------------------------------------------------------
# Color codes and symbols
# ---------------------------------------------------------------------------
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

SYM_OK="✅"
SYM_WARN="⚠️"
SYM_FAIL="❌"

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------
FIX_MODE=false
JSON_MODE=false
RED_COUNT=0
YELLOW_COUNT=0
GREEN_COUNT=0

# Parallel arrays for summary table
declare -a SUMMARY_SYMBOLS=()
declare -a SUMMARY_LABELS=()
declare -a SUMMARY_COLORS=()

# JSON accumulator (parallel arrays for bash 3 compatibility)
JSON_CHECK_KEYS=()
JSON_CHECK_VALS=()

# Detected values for config generation
DB_DRIVER=""
CF_VERSION=""

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
for arg in "$@"; do
    case "$arg" in
        --fix)  FIX_MODE=true ;;
        --json) JSON_MODE=true ;;
        --help|-h)
            echo "Usage: $0 [--fix] [--json]"
            echo ""
            echo "  --fix   Auto-install missing packages and create directories"
            echo "  --json  Output machine-readable JSON instead of tables"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            echo "Usage: $0 [--fix] [--json]" >&2
            exit 2
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log_green() {
    if ! $JSON_MODE; then
        printf "  ${GREEN}${SYM_OK} %s${RESET}\n" "$1"
    fi
    SUMMARY_SYMBOLS+=("$SYM_OK")
    SUMMARY_LABELS+=("$1")
    SUMMARY_COLORS+=("GREEN")
    GREEN_COUNT=$((GREEN_COUNT + 1))
}

log_yellow() {
    if ! $JSON_MODE; then
        printf "  ${YELLOW}${SYM_WARN}  %s${RESET}\n" "$1"
    fi
    SUMMARY_SYMBOLS+=("$SYM_WARN")
    SUMMARY_LABELS+=("$1")
    SUMMARY_COLORS+=("YELLOW")
    YELLOW_COUNT=$((YELLOW_COUNT + 1))
}

log_red() {
    if ! $JSON_MODE; then
        printf "  ${RED}${SYM_FAIL} %s${RESET}\n" "$1"
    fi
    SUMMARY_SYMBOLS+=("$SYM_FAIL")
    SUMMARY_LABELS+=("$1")
    SUMMARY_COLORS+=("RED")
    RED_COUNT=$((RED_COUNT + 1))
}

section_header() {
    if ! $JSON_MODE; then
        printf "\n${BOLD}── %s ──${RESET}\n" "$1"
    fi
}

json_set() {
    # json_set <key> <status> <detail>
    JSON_CHECK_KEYS+=("$1")
    JSON_CHECK_VALS+=("{\"status\":\"$2\",\"detail\":$(json_escape_string "$3")}")
}

json_escape_string() {
    # Minimal JSON string escaping
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '"%s"' "$s"
}

# Compare semver: returns 0 if $1 >= $2
semver_gte() {
    local IFS='.'
    local -a v1=($1) v2=($2)
    for i in 0 1 2; do
        local a="${v1[$i]:-0}"
        local b="${v2[$i]:-0}"
        # Strip non-numeric suffixes (e.g., "20.11.0-rc1" -> "20")
        a="${a%%[!0-9]*}"
        b="${b%%[!0-9]*}"
        a="${a:-0}"
        b="${b:-0}"
        if (( a > b )); then return 0; fi
        if (( a < b )); then return 1; fi
    done
    return 0
}

# ---------------------------------------------------------------------------
# Section 1: Prerequisites
# ---------------------------------------------------------------------------
check_prerequisites() {
    section_header "Prerequisites"

    # --- Node.js ---
    if command -v node &>/dev/null; then
        local node_ver
        node_ver="$(node --version 2>/dev/null | sed 's/^v//')"
        if semver_gte "$node_ver" "20.0.0"; then
            log_green "Node.js ${node_ver}"
            json_set "nodejs" "green" "Node.js ${node_ver}"
        else
            log_yellow "Node.js ${node_ver} (< 20 — upgrade recommended)"
            json_set "nodejs" "yellow" "Node.js ${node_ver} — below minimum 20.x"
            if $FIX_MODE; then
                if ! $JSON_MODE; then
                    printf "    ${DIM}Hint: Use nvm or fnm to install Node 20+${RESET}\n"
                    printf "    ${DIM}  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash${RESET}\n"
                    printf "    ${DIM}  nvm install 20${RESET}\n"
                fi
            fi
        fi
    else
        log_red "Node.js not found"
        json_set "nodejs" "red" "Node.js not installed"
        if $FIX_MODE && ! $JSON_MODE; then
            printf "    ${DIM}Install Node.js 20+: https://nodejs.org/${RESET}\n"
        fi
    fi

    # --- pnpm ---
    if command -v pnpm &>/dev/null; then
        local pnpm_ver
        pnpm_ver="$(pnpm --version 2>/dev/null)"
        if semver_gte "$pnpm_ver" "8.0.0"; then
            log_green "pnpm ${pnpm_ver}"
            json_set "pnpm" "green" "pnpm ${pnpm_ver}"
        else
            log_yellow "pnpm ${pnpm_ver} (< 8 — upgrade recommended)"
            json_set "pnpm" "yellow" "pnpm ${pnpm_ver} — below minimum 8.x"
        fi
    else
        log_yellow "pnpm not installed (optional, recommend: npm i -g pnpm)"
        json_set "pnpm" "yellow" "pnpm not installed"
        if $FIX_MODE; then
            if ! $JSON_MODE; then
                printf "    ${DIM}Installing pnpm...${RESET}\n"
            fi
            if npm i -g pnpm &>/dev/null; then
                local new_pnpm_ver
                new_pnpm_ver="$(pnpm --version 2>/dev/null || echo 'unknown')"
                log_green "pnpm ${new_pnpm_ver} (auto-installed)"
                json_set "pnpm" "green" "pnpm ${new_pnpm_ver} auto-installed"
            else
                if ! $JSON_MODE; then
                    printf "    ${RED}Failed to install pnpm via npm${RESET}\n"
                fi
            fi
        fi
    fi

    # --- Rust toolchain ---
    if command -v rustc &>/dev/null; then
        local rust_ver
        rust_ver="$(rustc --version 2>/dev/null | awk '{print $2}')"
        log_green "Rust ${rust_ver}"
        json_set "rust" "green" "Rust ${rust_ver}"
    else
        log_yellow "Rust not installed (optional — needed only for ruvector source builds)"
        json_set "rust" "yellow" "Rust not installed (optional)"
    fi
}

# ---------------------------------------------------------------------------
# Section 2: Installation Validation
# ---------------------------------------------------------------------------
check_installation() {
    section_header "Installation Validation"

    # --- helper: portable timeout ---
    # macOS may lack coreutils timeout; fall back to perl or plain exec
    _run_with_timeout() {
        local secs="$1"; shift
        if command -v timeout &>/dev/null; then
            timeout "$secs" "$@" 2>/dev/null || true
        elif command -v perl &>/dev/null; then
            perl -e "alarm $secs; exec @ARGV" -- "$@" 2>/dev/null || true
        else
            "$@" 2>/dev/null || true
        fi
    }

    # --- @claude-flow/cli ---
    local cf_found=false

    # Try npx claude-flow --version first (may not be installed)
    CF_VERSION="$(_run_with_timeout 10 npx claude-flow --version)" || true
    if [[ -n "$CF_VERSION" ]]; then
        cf_found=true
        log_green "@claude-flow/cli ${CF_VERSION}"
        json_set "claude_flow_cli" "green" "@claude-flow/cli ${CF_VERSION}"
    fi

    # Fallback: check node_modules
    if ! $cf_found; then
        local pnpm_path=""
        pnpm_path="$(find . node_modules -maxdepth 5 -path '*/@claude-flow/cli/package.json' 2>/dev/null | head -1)" || true
        if [[ -n "$pnpm_path" ]]; then
            local pkg_ver
            pkg_ver="$(node -e "console.log(require('./${pnpm_path}').version)" 2>/dev/null)" || pkg_ver="unknown"
            cf_found=true
            CF_VERSION="$pkg_ver"
            log_green "@claude-flow/cli ${pkg_ver} (found in node_modules)"
            json_set "claude_flow_cli" "green" "@claude-flow/cli ${pkg_ver} found in node_modules"
        fi
    fi

    if ! $cf_found; then
        log_red "@claude-flow/cli not found"
        json_set "claude_flow_cli" "red" "Not installed"
        if $FIX_MODE; then
            if ! $JSON_MODE; then
                printf "    ${DIM}Installing @claude-flow/cli...${RESET}\n"
            fi
            local install_ok=false
            npm install -g @anthropic-ai/claude-flow &>/dev/null && install_ok=true
            if ! $install_ok; then
                npm install @claude-flow/cli &>/dev/null && install_ok=true
            fi
            if $install_ok; then
                CF_VERSION="$(_run_with_timeout 10 npx claude-flow --version)" || CF_VERSION="installed"
                log_green "@claude-flow/cli ${CF_VERSION} (auto-installed)"
                json_set "claude_flow_cli" "green" "Auto-installed ${CF_VERSION}"
            else
                if ! $JSON_MODE; then
                    printf "    ${RED}Auto-install failed. Try: npm install -g @claude-flow/cli${RESET}\n"
                fi
            fi
        fi
    fi

    # --- MCP handshake ---
    local mcp_request='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"doctor","version":"1.0"}}}'
    local mcp_response=""

    if command -v npx &>/dev/null; then
        mcp_response="$(echo "$mcp_request" | _run_with_timeout 8 npx claude-flow mcp)" || true
    fi

    if [[ "$mcp_response" == *'"result"'* ]]; then
        log_green "MCP handshake OK"
        json_set "mcp_handshake" "green" "MCP initialize response received"
    elif [[ -n "$mcp_response" ]]; then
        log_yellow "MCP responded but no 'result' field (partial handshake)"
        json_set "mcp_handshake" "yellow" "Partial response: ${mcp_response:0:120}"
    else
        log_red "MCP handshake failed (timeout or no response)"
        json_set "mcp_handshake" "red" "No response from claude-flow mcp"
    fi
}

# ---------------------------------------------------------------------------
# Section 3: @ruvector Package Detection
# ---------------------------------------------------------------------------
check_ruvector() {
    section_header "@ruvector Package Detection"

    local -a packages=(
        "@ruvector/core"
        "@ruvector/sona"
        "@ruvector/attention"
        "@ruvector/memory"
        "@ruvector/swarm"
        "@ruvector/neural"
        "@ruvector/embed"
        "@ruvector/vector"
    )
    local installed_count=0
    local total=${#packages[@]}
    local -a missing_packages=()

    for pkg in "${packages[@]}"; do
        # Try to resolve the package
        if node -e "require.resolve('${pkg}')" &>/dev/null; then
            installed_count=$((installed_count + 1))
            json_set "ruvector_${pkg##*/}" "green" "Installed"
        else
            missing_packages+=("$pkg")
            json_set "ruvector_${pkg##*/}" "yellow" "Not installed (mock fallback)"
        fi
    done

    if (( installed_count == total )); then
        log_green "${installed_count}/${total} @ruvector packages installed"
        json_set "ruvector_summary" "green" "All ${total} packages installed"
    elif (( installed_count > 0 )); then
        log_yellow "${installed_count}/${total} @ruvector packages (mocks for rest)"
        json_set "ruvector_summary" "yellow" "${installed_count}/${total} installed"
        if ! $JSON_MODE; then
            printf "    ${DIM}Missing: %s${RESET}\n" "${missing_packages[*]}"
        fi
    else
        log_yellow "0/${total} @ruvector packages (all using mock fallback)"
        json_set "ruvector_summary" "yellow" "0/${total} — all mocked"
    fi

    if $FIX_MODE && (( ${#missing_packages[@]} > 0 )); then
        if ! $JSON_MODE; then
            printf "    ${DIM}Attempting to install missing @ruvector packages...${RESET}\n"
        fi
        local fix_count=0
        for pkg in "${missing_packages[@]}"; do
            if npm install "$pkg" &>/dev/null; then
                fix_count=$((fix_count + 1))
            fi
        done
        if (( fix_count > 0 )); then
            installed_count=$((installed_count + fix_count))
            if ! $JSON_MODE; then
                printf "    ${GREEN}Installed ${fix_count} additional packages${RESET}\n"
            fi
        fi
    fi
}

# ---------------------------------------------------------------------------
# Section 4: Directory Auto-Creation
# ---------------------------------------------------------------------------
check_directories() {
    section_header "Directory Structure"

    local -a dirs=(
        ".claude-flow/agents"
        ".claude-flow/memory"
        ".claude-flow/sessions"
        ".claude-flow/learning"
    )
    local all_exist=true
    local created_count=0

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            json_set "dir_${dir//\//_}" "green" "Exists"
        else
            all_exist=false
            if $FIX_MODE || true; then
                # Always create missing directories (non-destructive)
                mkdir -p "$dir"
                created_count=$((created_count + 1))
                json_set "dir_${dir//\//_}" "green" "Created"
                if ! $JSON_MODE; then
                    printf "    ${DIM}Created: ${dir}${RESET}\n"
                fi
            fi
        fi
    done

    if $all_exist; then
        log_green "Directories OK"
        json_set "directories" "green" "All directories present"
    elif (( created_count > 0 )); then
        log_green "Directories OK (created ${created_count} missing)"
        json_set "directories" "green" "Created ${created_count} missing directories"
    else
        log_yellow "Some directories missing (run with --fix to create)"
        json_set "directories" "yellow" "Missing directories"
    fi
}

# ---------------------------------------------------------------------------
# Section 5: Database Layer
# ---------------------------------------------------------------------------
check_database() {
    section_header "Database Layer"

    local native_ok=false
    local wasm_ok=false

    # Check better-sqlite3
    if node -e "require('better-sqlite3')" &>/dev/null; then
        native_ok=true
        DB_DRIVER="better-sqlite3"
    fi

    # Check sql.js WASM fallback
    if node -e "require('sql.js')" &>/dev/null; then
        wasm_ok=true
        if [[ -z "$DB_DRIVER" ]]; then
            DB_DRIVER="sql.js"
        fi
    fi

    if $native_ok; then
        log_green "Database: better-sqlite3 (native)"
        json_set "database" "green" "better-sqlite3 native module"
    elif $wasm_ok; then
        log_yellow "Database: sql.js WASM (native better-sqlite3 unavailable)"
        json_set "database" "yellow" "sql.js WASM fallback only"
        if $FIX_MODE; then
            if ! $JSON_MODE; then
                printf "    ${DIM}Attempting to install better-sqlite3...${RESET}\n"
            fi
            if npm install better-sqlite3 &>/dev/null; then
                if node -e "require('better-sqlite3')" &>/dev/null; then
                    DB_DRIVER="better-sqlite3"
                    log_green "Database: better-sqlite3 (auto-installed)"
                    json_set "database" "green" "better-sqlite3 auto-installed"
                fi
            fi
        fi
    else
        log_red "No database driver found (neither better-sqlite3 nor sql.js)"
        json_set "database" "red" "No database driver available"
        if $FIX_MODE; then
            if ! $JSON_MODE; then
                printf "    ${DIM}Attempting to install sql.js...${RESET}\n"
            fi
            if npm install sql.js &>/dev/null; then
                if node -e "require('sql.js')" &>/dev/null; then
                    DB_DRIVER="sql.js"
                    log_green "Database: sql.js (auto-installed)"
                    json_set "database" "green" "sql.js auto-installed"
                fi
            else
                if ! $JSON_MODE; then
                    printf "    ${RED}Failed to install database drivers${RESET}\n"
                    printf "    ${DIM}Try manually: npm install better-sqlite3 || npm install sql.js${RESET}\n"
                fi
            fi
        fi
    fi
}

# ---------------------------------------------------------------------------
# Section 6: Config Generation
# ---------------------------------------------------------------------------
check_config() {
    section_header "Configuration"

    local config_path=".claude-flow/config.yaml"

    if [[ -f "$config_path" ]]; then
        log_green "Config exists (${config_path})"
        json_set "config" "green" "Config file present at ${config_path}"
    else
        # Determine which DB driver to configure
        local driver="${DB_DRIVER:-sql.js}"

        if $FIX_MODE || true; then
            # Config generation is non-destructive, always do it if missing
            mkdir -p "$(dirname "$config_path")"
            cat > "$config_path" <<CFEOF
version: 3
database:
  driver: ${driver}
  path: .claude-flow/memory/claude-flow.db
agents:
  maxConcurrent: 4
  defaultModel: claude-sonnet-4-20250514
memory:
  persistence: true
  learningDir: .claude-flow/learning
mcp:
  enabled: true
  transport: stdio
CFEOF
            log_green "Config generated (${config_path}, driver: ${driver})"
            json_set "config" "green" "Config generated with driver=${driver}"
        else
            log_yellow "Config missing (${config_path}) — run with --fix to generate"
            json_set "config" "yellow" "Config file missing"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Section 7: Summary
# ---------------------------------------------------------------------------
print_summary() {
    if $JSON_MODE; then
        print_json_summary
        return
    fi

    local total=$((GREEN_COUNT + YELLOW_COUNT + RED_COUNT))
    local result_label result_color

    if (( RED_COUNT > 0 )); then
        result_label="NOT READY (${RED_COUNT} error(s), ${YELLOW_COUNT} warning(s))"
        result_color="$RED"
    elif (( YELLOW_COUNT > 0 )); then
        result_label="READY (${YELLOW_COUNT} warning(s))"
        result_color="$YELLOW"
    else
        result_label="READY"
        result_color="$GREEN"
    fi

    # Determine box width — find the longest summary line
    local max_len=44  # minimum width
    for (( i=0; i<${#SUMMARY_LABELS[@]}; i++ )); do
        local label="${SUMMARY_LABELS[$i]}"
        # Account for symbol width (emoji + space = ~4 visible chars)
        local line_len=$(( ${#label} + 5 ))
        if (( line_len > max_len )); then
            max_len=$line_len
        fi
    done
    # Also check result line
    local result_line_len=$(( ${#result_label} + 10 ))
    if (( result_line_len > max_len )); then
        max_len=$result_line_len
    fi

    local box_width=$((max_len + 4))

    # Build horizontal rules
    local h_double h_single
    h_double=""
    h_single=""
    for (( j=0; j<box_width; j++ )); do
        h_double+="═"
        h_single+="═"
    done

    printf "\n"
    printf "${BOLD}╔%s╗${RESET}\n" "$h_double"
    printf "${BOLD}║  cf-doctor Summary%-*s║${RESET}\n" $((box_width - 20)) ""
    printf "${BOLD}╠%s╣${RESET}\n" "$h_single"

    for (( i=0; i<${#SUMMARY_LABELS[@]}; i++ )); do
        local sym="${SUMMARY_SYMBOLS[$i]}"
        local label="${SUMMARY_LABELS[$i]}"
        local color="${SUMMARY_COLORS[$i]}"
        local c=""

        case "$color" in
            GREEN)  c="$GREEN" ;;
            YELLOW) c="$YELLOW" ;;
            RED)    c="$RED" ;;
        esac

        # Calculate padding. Emoji symbols have variable display width.
        # We use a fixed approach: print symbol + space + label, pad to box_width
        local content="${sym} ${label}"
        # Visible length approximation: emoji ~2 chars display + space + label
        local visible_len=$(( ${#label} + 4 ))
        local pad=$(( box_width - visible_len ))
        if (( pad < 0 )); then pad=0; fi

        printf "${BOLD}║${RESET} ${c}%s %s${RESET}%-*s${BOLD}║${RESET}\n" "$sym" "$label" "$pad" ""
    done

    printf "${BOLD}╠%s╣${RESET}\n" "$h_single"
    # Result line
    local result_vis_len=$(( ${#result_label} + 10 ))
    local result_pad=$(( box_width - result_vis_len ))
    if (( result_pad < 0 )); then result_pad=0; fi
    printf "${BOLD}║${RESET} ${result_color}Result: %s${RESET}%-*s${BOLD}║${RESET}\n" "$result_label" "$result_pad" ""
    printf "${BOLD}╚%s╝${RESET}\n" "$h_double"
    printf "\n"
}

print_json_summary() {
    local result
    if (( RED_COUNT > 0 )); then
        result="NOT_READY"
    elif (( YELLOW_COUNT > 0 )); then
        result="READY_WITH_WARNINGS"
    else
        result="READY"
    fi

    printf '{\n'
    printf '  "result": "%s",\n' "$result"
    printf '  "counts": {"green": %d, "yellow": %d, "red": %d},\n' \
        "$GREEN_COUNT" "$YELLOW_COUNT" "$RED_COUNT"
    printf '  "fix_mode": %s,\n' "$FIX_MODE"
    printf '  "checks": {\n'

    local first=true
    for (( j=0; j<${#JSON_CHECK_KEYS[@]}; j++ )); do
        if $first; then
            first=false
        else
            printf ',\n'
        fi
        printf '    "%s": %s' "${JSON_CHECK_KEYS[$j]}" "${JSON_CHECK_VALS[$j]}"
    done

    printf '\n  },\n'
    printf '  "summary": [\n'

    for (( i=0; i<${#SUMMARY_LABELS[@]}; i++ )); do
        local comma=""
        if (( i < ${#SUMMARY_LABELS[@]} - 1 )); then comma=","; fi
        printf '    {"status": "%s", "label": %s}%s\n' \
            "${SUMMARY_COLORS[$i]}" \
            "$(json_escape_string "${SUMMARY_LABELS[$i]}")" \
            "$comma"
    done

    printf '  ]\n'
    printf '}\n'
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    if ! $JSON_MODE; then
        printf "\n${BOLD}cf-doctor${RESET} — claude-flow + ruvector installation validator\n"
        if $FIX_MODE; then
            printf "${DIM}Running in --fix mode: will auto-install missing dependencies${RESET}\n"
        fi
    fi

    check_prerequisites
    check_installation
    check_ruvector
    check_directories
    check_database
    check_config
    print_summary

    if (( RED_COUNT > 0 )); then
        exit 1
    fi
    exit 0
}

main
