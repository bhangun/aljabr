#!/bin/bash
set -euo pipefail

HOST="${ALJABR_HOST:-https://api.aljabr.id}"
REALM="${TENANT_REALM:-aljabr}"

exec ./scripts/run_macos.sh default --host "$HOST" --realm "$REALM" "$@"
