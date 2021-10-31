FROM scratch

# https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-netboot-3.14.2-x86_64.tar.gz
ADD alpine-minirootfs-3.14.2-x86_64.tar.gz .
COPY app/server.ts /home/server.ts

# Install Deno
RUN apk add curl && \
  curl -fsSL https://deno.land/x/install/install.sh | sh && \
  DENO_INSTALL="/root/.deno" && \
  PATH="$DENO_INSTALL/bin:$PATH" && \
  deno --version 

EXPOSE 8080

ENTRYPOINT [ "deno" ] 
CMD [ "run", "--allow-net", "/home/server.ts" ]