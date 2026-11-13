#!/bin/sh
# The `lint` check: installs the locked dependencies and runs the site's `lint` script: eslint over src/ with Create
# React App's full `react-app` rules (ci/eslintrc.json; the build itself only applies their `react-app/base` subset),
# then the TypeScript compiler's type check (tsc --noEmit, tsconfig.json). Static checks only, nothing is built.
# Warnings are reported and do not fail the check: the code has a few (missing hook dependencies, target="_blank"
# links), and fixing them would change what the app does. Errors fail it.
#
# The configuration is under ci/ rather than at the root or in package.json so that react-scripts' build, which reads
# those, keeps linting as it did. yggdrasil.yml runs this in the Node image of the Dockerfile's build stage (Alpine: no
# bash, so this is POSIX sh), from the repository's root. By hand, from anywhere in the checkout:
#   docker run --rm -v "$PWD:/src" -w /src <image> sh ci/lint.sh
set -eu

# The repository's root, wherever this is run from.
cd "$(dirname "$0")/.."

npm ci --no-audit --no-fund
npm run lint
