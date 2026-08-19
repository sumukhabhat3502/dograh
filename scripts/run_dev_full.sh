#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

UI_HOST="${DOGRAH_UI_HOST:-0.0.0.0}"
DOCKER_UP="${DOGRAH_DOCKER_UP:-1}"

cleanup() {
  # Best-effort shutdown; the UI might be Ctrl-C'ed before backend fully starts.
  bash "$BASE_DIR/scripts/stop_services.sh" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

if [[ -f "$BASE_DIR/venv/bin/activate" ]]; then
  # Ensure we use the repo venv if present.
  # shellcheck disable=SC1091
  source "$BASE_DIR/venv/bin/activate"
fi

if [[ "$DOCKER_UP" == "1" ]]; then
  docker compose -f docker-compose-local.yaml up -d
fi

echo "Starting backend..."
bash "$BASE_DIR/scripts/start_services_dev.sh"

echo "Starting UI (Next.js)..."
cd "$BASE_DIR/ui"
exec npm run dev -- --hostname "$UI_HOST"

