#!/bin/bash
# Reads .env and generates Slipie/Configuration/Secrets.swift
# Run this once after cloning or updating .env:
#   ./scripts/generate-secrets.sh

set -e

ENV_FILE="$(dirname "$0")/../.env"
OUTPUT="$(dirname "$0")/../Slipie/Configuration/Secrets.swift"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env file not found at $ENV_FILE"
  echo "Copy .env.example to .env and fill in your values."
  exit 1
fi

# Load .env
export $(grep -v '^#' "$ENV_FILE" | xargs)

cat > "$OUTPUT" << SWIFT
// Auto-generated from .env — do not commit this file
// Regenerate by running: ./scripts/generate-secrets.sh

enum Secrets {
    static let supabaseURL = "${SUPABASE_URL}"
    static let supabaseAnonKey = "${SUPABASE_ANON_KEY}"
}
SWIFT

echo "Generated $OUTPUT"
