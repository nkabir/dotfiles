# Library System

The CWIQ Seed library system provides reusable bash/shell components for consistent functionality across scripts and configurations.

## Overview

Libraries are stored in `~/.local/lib/` with each library in its own directory. The main entry point for each library is `core.bash`.

## Core Libraries

### Logger Library

**Location:** `~/.local/lib/logger/core.bash`

The logger library provides structured logging with color support and multiple output targets.

**Usage:**
```bash
#!/bin/bash
# Source the library
. ~/.local/lib/logger/core.bash

# Initialize logger
logger:init

# Log messages at different levels
logger:info "Starting installation"
logger:success "Package installed successfully"
logger:warning "Configuration file missing, using defaults"
logger:error "Failed to download file"
logger:debug "Variable value: $VAR"
```

**Features:**
- Color-coded output for different log levels
- Timestamp support
- File logging capability
- Configurable log levels
- Structured formatting

**Configuration:**
```bash
# Set log level (default: INFO)
export LOG_LEVEL="DEBUG"

# Enable file logging
export LOG_FILE="/var/log/myapp.log"

# Disable colors
export NO_COLOR=1
```

### Bitwarden Library

**Location:** `~/.local/lib/bitwarden/core.bash`

Integrates with Bitwarden CLI for secure secret management.

**Usage:**
```bash
#!/bin/bash
. ~/.local/lib/bitwarden/core.bash

# Initialize Bitwarden
bitwarden:init

# Check if logged in
if bitwarden:is_logged_in; then
    # Get a secret
    API_KEY=$(bitwarden:get "MyApp API" "api_key")
    
    # Get a password
    DB_PASS=$(bitwarden:get "Database" "password")
else
    logger:error "Please login to Bitwarden first"
    exit 1
fi
```

**Features:**
- Session management
- Secure credential retrieval
- Error handling
- Integration with logger library

### Common Library

**Location:** `~/.local/lib/common/core.bash`

Provides common utilities and helper functions.

**Usage:**
```bash
#!/bin/bash
. ~/.local/lib/common/core.bash

# Check if command exists
if common:command_exists "docker"; then
    logger:info "Docker is installed"
fi

# Check OS type
if common:is_ubuntu; then
    logger:info "Running on Ubuntu"
elif common:is_almalinux; then
    logger:info "Running on AlmaLinux"
fi

# Retry a command
common:retry 3 wget https://example.com/file.tar.gz
```

**Features:**
- OS detection functions
- Command availability checks
- Retry mechanisms
- String manipulation utilities

## Creating Custom Libraries

### Library Structure

```
~/.local/lib/mylib/
├── core.bash           # Main entry point
├── config.bash         # Configuration handling
├── utils.bash          # Utility functions
└── README.md          # Documentation
```

### Basic Template

```bash
#!/usr/bin/env bash
# ~/.local/lib/mylib/core.bash

# Library metadata
readonly MYLIB_VERSION="1.0.0"
readonly MYLIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source dependencies
. ~/.local/lib/logger/core.bash

# Source library components
. "${MYLIB_DIR}/config.bash"
. "${MYLIB_DIR}/utils.bash"

# Initialize function
mylib:init() {
    logger:debug "Initializing mylib v${MYLIB_VERSION}"
    # Initialization logic here
    return 0
}

# Public API functions
mylib:do_something() {
    local arg="${1:?Usage: mylib:do_something <arg>}"
    logger:info "Doing something with: $arg"
    # Implementation here
}

# Auto-initialize if sourced directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    mylib:init
fi
```

### Best Practices

1. **Namespace Functions**
   ```bash
   # Good: namespaced
   mylib:function_name() { ... }
   
   # Avoid: global namespace
   function_name() { ... }
   ```

2. **Document Functions**
   ```bash
   # Retrieve a value from cache
   # Arguments:
   #   $1 - Cache key
   # Returns:
   #   0 - Success, value on stdout
   #   1 - Key not found
   mylib:cache_get() {
       local key="${1:?Usage: mylib:cache_get <key>}"
       # Implementation
   }
   ```

3. **Handle Errors Gracefully**
   ```bash
   mylib:risky_operation() {
       if ! command_that_might_fail; then
           logger:error "Operation failed"
           return 1
       fi
       return 0
   }
   ```

4. **Use Local Variables**
   ```bash
   mylib:process() {
       local input="${1}"
       local -r max_retries=3
       local attempt=0
       # ...
   }
   ```

## Loading Libraries

### In Scripts

```bash
#!/bin/bash
# Load multiple libraries
. ~/.local/lib/logger/core.bash
. ~/.local/lib/common/core.bash
. ~/.local/lib/bitwarden/core.bash

# Initialize what's needed
logger:init
bitwarden:init
```

### In Bash Modules

```bash
# ~/.bashrc.d/500-mymodule.bash
# Conditionally load libraries
[[ -f ~/.local/lib/logger/core.bash ]] && . ~/.local/lib/logger/core.bash
[[ -f ~/.local/lib/common/core.bash ]] && . ~/.local/lib/common/core.bash
```

### Lazy Loading

```bash
# Load library only when needed
my_function() {
    # Load library on first use
    if ! declare -f logger:info &>/dev/null; then
        . ~/.local/lib/logger/core.bash
        logger:init
    fi
    
    logger:info "Function called"
}
```

## Testing Libraries

### Unit Test Template

```bash
#!/bin/bash
# ~/.local/lib/mylib/test.bash

# Source the library
. ~/.local/lib/mylib/core.bash

# Test counter
declare -i tests_passed=0
declare -i tests_failed=0

# Test helper
assert() {
    local description="$1"
    shift
    if "$@"; then
        ((tests_passed++))
        echo "✓ $description"
    else
        ((tests_failed++))
        echo "✗ $description"
        return 1
    fi
}

# Run tests
test_mylib_init() {
    assert "mylib:init succeeds" mylib:init
}

test_mylib_function() {
    local result
    result=$(mylib:do_something "test")
    assert "mylib:do_something returns expected value" \
        [[ "$result" == "expected" ]]
}

# Execute tests
main() {
    test_mylib_init
    test_mylib_function
    
    echo
    echo "Tests passed: $tests_passed"
    echo "Tests failed: $tests_failed"
    
    [[ $tests_failed -eq 0 ]]
}

main "$@"
```

## Library Dependencies

### Declaring Dependencies

```bash
# Check for required libraries
mylib:check_deps() {
    local -a required_libs=(
        "~/.local/lib/logger/core.bash"
        "~/.local/lib/common/core.bash"
    )
    
    for lib in "${required_libs[@]}"; do
        if [[ ! -f "$lib" ]]; then
            echo "ERROR: Required library not found: $lib" >&2
            return 1
        fi
    done
    return 0
}

# Check before initialization
mylib:init() {
    mylib:check_deps || return 1
    # Continue with initialization
}
```

### Version Checking

```bash
# Require minimum versions
mylib:init() {
    # Check logger version
    if [[ "${LOGGER_VERSION:-0}" < "2.0.0" ]]; then
        echo "ERROR: Logger library v2.0.0+ required" >&2
        return 1
    fi
    # Initialize
}
```

## Advanced Patterns

### Configuration Management

```bash
# ~/.local/lib/mylib/config.bash
declare -A MYLIB_CONFIG=(
    [debug]="false"
    [timeout]="30"
    [retry_count]="3"
)

mylib:config_set() {
    local key="${1:?Key required}"
    local value="${2:?Value required}"
    MYLIB_CONFIG[$key]="$value"
}

mylib:config_get() {
    local key="${1:?Key required}"
    echo "${MYLIB_CONFIG[$key]:-}"
}
```

### Event System

```bash
# Simple event system
declare -A MYLIB_HANDLERS=()

mylib:on() {
    local event="${1:?Event required}"
    local handler="${2:?Handler required}"
    MYLIB_HANDLERS[$event]+="$handler "
}

mylib:emit() {
    local event="${1:?Event required}"
    shift
    local handlers="${MYLIB_HANDLERS[$event]:-}"
    
    for handler in $handlers; do
        $handler "$@"
    done
}

# Usage
mylib:on "error" "logger:error"
mylib:emit "error" "Something went wrong"
```