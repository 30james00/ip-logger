FROM busybox:latest AS build

WORKDIR /tmp

# Download Alpine Linux
ADD https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-minirootfs-3.14.2-x86_64.tar.gz .
# Extract files from tar.gz and remove it
RUN tar -xzf alpine-minirootfs-3.14.2-x86_64.tar.gz && \
  rm alpine-minirootfs-3.14.2-x86_64.tar.gz

FROM scratch

LABEL author="Michal Stolarz 48206982+30james00@users.noreply.github.com"

# Set environmental varialbes for Deno location and port
ENV DENO_INSTALL="/root/.deno" \
PATH="/root/.deno/bin:${PATH}" \
PORT=8080

# The port that your application listens to set as env (can be changed)
EXPOSE ${PORT}

# Copy Alpine files from previous stage
COPY --from=build /tmp .

# Install build dependencies with optimal cache settings
RUN apk add --no-cache --virtual=.build-dependencies wget ca-certificates curl && \
# Install glibc to run Deno (code is copied from frolvlad/alpine-glibc)
  ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
  ALPINE_GLIBC_PACKAGE_VERSION="2.33-r0" && \
  ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
  echo \
  "-----BEGIN PUBLIC KEY-----\
  MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
  y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
  tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
  m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
  KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
  Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
  1QIDAQAB\
  -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
  wget \
  "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  apk add --no-cache \
  "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
  \
  rm "/etc/apk/keys/sgerrand.rsa.pub" && \
  /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
  echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
  \
  apk del glibc-i18n && \
  \
  rm "/root/.wget-hsts" && \
  rm \
  "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
  "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
# End of copied code
# Install Deno from script https://deno.land/manual/getting_started/installation 
  curl -fsSL https://deno.land/x/install/install.sh | sh && \
# Remove build dependencies
  apk del .build-dependencies

WORKDIR /app

# Cache the dependencies as a layer (the following two steps are re-run only when deps.ts is modified).
# Ideally cache deps.ts will download and compile _all_ external files used in main.ts.
COPY app/deps.ts .
RUN deno cache deps.ts

# Re-run upon each server.ts change:
COPY app/server.ts .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache server.ts

ENTRYPOINT [ "deno" ]
CMD ["run", "--allow-net", "--allow-env", "server.ts"]