#!/bin/sh
# Test runner for fin-markdown. Fails loudly; prints the counted summary.
# Usage: sh tests/run_tests.sh   (FINC env var overrides the finc binary)
set -eu
cd "$(dirname "$0")/.."
FINC="${FINC:-finc}"

echo "== frontend check =="
"$FINC" -I src src/markdown.fin

echo "== codegen + link tests =="
"$FINC" -I src tests/test_markdown.fin -o test_markdown

echo "== run tests =="
./test_markdown
echo "TESTS OK"
