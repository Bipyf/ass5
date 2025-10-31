
#!/usr/bin/env bash
set -euo pipefail

IMAGE="${DOCKER_IMAGE:-expetra/budget-analyzer:local}"

# Stop/remove previous container if exists
if [ "$(docker ps -aq -f name=budget-analyzer)" ]; then
  docker rm -f budget-analyzer >/dev/null 2>&1 || true
fi

# Run a new container
docker run -d --name budget-analyzer --restart unless-stopped \
  -e EXPENSES="120,89.9,15.6,125.0" \
  "$IMAGE"

echo "Deployed container 'budget-analyzer' from image: $IMAGE"
