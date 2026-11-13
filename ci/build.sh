#!/bin/sh
# The `build` check: builds the Dockerfile's image as a deploy builds it (npm ci and react-scripts build in its build
# stage, then the static-web-server stage), with the build arguments' defaults. Build only, no push and no run: the
# point is that the image can still be produced. The site has no tests.
#
# yggdrasil.yml runs it in the pinned Docker CLI image (Alpine: no bash, so this is POSIX sh) with the CI engine's
# socket, from the repository's root. By hand, from anywhere in the checkout, with a Docker engine:
#   sh ci/build.sh
set -eu

# The repository's root, wherever this is run from.
cd "$(dirname "$0")/.."

# The container's hostname (its id, when this runs in one) keeps the tag unique to this run.
tag="file-tree-generator-check:$(hostname)"
# The image is only built to prove the Dockerfile works: remove it afterwards, whatever the outcome.
trap 'docker image rm --force "$tag" >/dev/null 2>&1 || true' EXIT

DOCKER_BUILDKIT=1 docker build --tag "$tag" .
