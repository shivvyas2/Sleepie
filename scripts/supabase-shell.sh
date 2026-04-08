#!/bin/bash
# Loads .env and gives you a shell with Supabase env vars active.
# Use this to run supabase CLI commands with your project credentials.
#
# Usage:
#   source ./scripts/supabase-shell.sh
#
# After sourcing, you can run:
#   supabase login
#   supabase link --project-ref $SUPABASE_PROJECT_REF
#   supabase db push          # push schema.sql migrations
#   supabase db reset         # reset local db
#   supabase status           # check local stack status

ENV_FILE="$(dirname "$0")/../.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env not found"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

echo "Supabase environment loaded."
echo "  URL:         $SUPABASE_URL"
echo "  Project ref: $SUPABASE_PROJECT_REF"
echo ""
echo "You can now run: supabase link --project-ref \$SUPABASE_PROJECT_REF"
