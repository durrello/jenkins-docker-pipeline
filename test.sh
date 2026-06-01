#!/usr/bin/env bash
# Smoke test: start the built image, hit it, confirm a 200.
set -euo pipefail

IMAGE="${IMAGE:-durrello/portfolio-app}:${TAG:-latest}"
NAME="smoke-$$"

cleanup() { docker rm -f "$NAME" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker run -d --name "$NAME" -p 8081:80 "$IMAGE"
sleep 3

code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/)
echo "HTTP status: $code"
[ "$code" = "200" ] || { echo "Smoke test failed"; exit 1; }
echo "Smoke test passed"
