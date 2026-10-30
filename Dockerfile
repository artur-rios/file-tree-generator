# The site's image: the Create React App build, in a pinned Node image, served by static-web-server. yggdrasil
# deploys it from main as the application file-tree-generator (file-tree.artur-rios.tech); this file follows its
# templates/site-vite/Dockerfile, with Create React App's names.
#
# The build arguments are the stack file's (yggdrasil's stacks/file-tree-generator.yml), which its deploy feeds:
#   PUBLIC_PATH      where under the host the app lives (/name), empty for the host's root: Create React App reads
#                    it as PUBLIC_URL, and the files are put under it, since the proxy does not strip it.
#   GIT_COMMIT, YGG_ENVIRONMENT   the commit and the environment this image is built for, compiled into the app as
#                    process.env.REACT_APP_GIT_COMMIT and REACT_APP_YGG_ENVIRONMENT. Public values: never pass a secret
#                    as a build argument.
# PUBLIC_HOST (the stack passes it too) is not used here, and an unused build argument is not an error.
FROM node:24.22.1-alpine3.24@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53 AS build

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
ARG PUBLIC_PATH=
ARG GIT_COMMIT=
ARG YGG_ENVIRONMENT=
# No source maps in the image: they would publish the source a second time.
ENV PUBLIC_URL=${PUBLIC_PATH} \
    REACT_APP_GIT_COMMIT=${GIT_COMMIT} \
    REACT_APP_YGG_ENVIRONMENT=${YGG_ENVIRONMENT} \
    GENERATE_SOURCEMAP=false
RUN npm run build

FROM joseluisq/static-web-server:2.44.1@sha256:94618e3d17802265a21926217e6f9e7832b311b6fbf5933684001739fafed06a

# Declared again: an argument lives in the stage that declares it.
ARG PUBLIC_PATH=
ARG GIT_COMMIT=
ARG YGG_ENVIRONMENT=

# The server has no shell, so nothing is run here: the build is copied under its path, and /healthz is a file of
# its own at the root. Port 8080, a numeric non-root user.
COPY --from=build /app/build/ /public${PUBLIC_PATH}/
COPY <<EOF /public/healthz
ok
EOF

# A single-page app: any address under its path that is not a file is the app's page.
ENV SERVER_PORT=8080 \
    SERVER_ROOT=/public \
    SERVER_FALLBACK_PAGE=/public${PUBLIC_PATH}/index.html

LABEL org.opencontainers.image.revision="${GIT_COMMIT}" \
      yggdrasil.built-for="${YGG_ENVIRONMENT}"

USER 65532:65532
EXPOSE 8080
