#!/bin/bash
# Launch ModelSim (Docker image "modelsim") with its GUI shown through XQuartz.
# Usage: modelsim.sh [project_folder]   (no argument → folder picker)
 
export PATH="/usr/local/bin:/opt/X11/bin:$PATH"
IMAGE=modelsim
 
# Project folder: argument, else ask with a Finder dialog
DIR="$1"
if [ -z "$DIR" ]; then
  DIR=$(osascript -e 'POSIX path of (choose folder with prompt "ModelSim project folder:")' 2>/dev/null) || exit 0
fi
DIR="$(cd "$DIR" && pwd)" || { echo "Bad folder: $1"; exit 1; }
 
# Start Docker Desktop if needed and wait for it
if ! docker info >/dev/null 2>&1; then
  open -a Docker
  echo "Waiting for Docker..."
  for i in {1..60}; do docker info >/dev/null 2>&1 && break; sleep 2; done
  docker info >/dev/null 2>&1 || { osascript -e 'display alert "Docker did not start"'; exit 1; }
fi
 
# Start XQuartz and allow the container to draw windows
open -a XQuartz
export DISPLAY="${DISPLAY:-:0}"
for i in {1..15}; do xhost + 127.0.0.1 >/dev/null 2>&1 && break; sleep 1; done
 
# Interactive flags only when run from a terminal
TTY=""; [ -t 0 ] && TTY="-it"
 
docker run --rm $TTY \
  -e DISPLAY=host.docker.internal:0 \
  -v "$DIR":/work \
  "$IMAGE" "${@:2}"