#!/bin/bash

# format_code.sh
# Script to format Ada code in different projects of the repository
#
# Uses --no-project mode to avoid issues with External_As_List in
# Alire-generated config files (unsupported by gnatformat).

# Exit immediately if a command exits with a non-zero status
set -e

# Get the absolute path of the repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Format settings (must match package Format in .gpr files)
FORMAT_OPTS="--no-project -w 120 --charset utf-8"

# Use libs/cli as the working directory for alr exec (toolchain access)
cd "$REPO_ROOT/libs/cli"

echo "=== Code Formatter ==="

# Format code in the main CLI library
echo "Formatting libs/cli/src..."
alr exec -- gnatformat $FORMAT_OPTS src/*.ads src/*.adb

# Format code in the common library
echo "Formatting libs/common/src..."
alr exec -- gnatformat $FORMAT_OPTS ../common/src/*.ads ../common/src/*.adb

# Format code in the examples directory (multiple sub-examples with src/ dirs)
echo "Formatting libs/cli/examples..."
EXAMPLE_SOURCES=$(find "$REPO_ROOT/libs/cli/examples" -path "*/src/*.ads" -o -path "*/src/*.adb" | sort)
if [ -n "$EXAMPLE_SOURCES" ]; then
    alr exec -- gnatformat $FORMAT_OPTS $EXAMPLE_SOURCES
fi

# Format code in the tests directory
echo "Formatting libs/cli/tests..."
alr exec -- gnatformat $FORMAT_OPTS tests/src/*.ads tests/src/*.adb

echo "=== Code formatting complete ==="
