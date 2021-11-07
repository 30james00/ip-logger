FROM denoland/deno:alpine AS build

LABEL author="Michal Stolarz 48206982+30james00@users.noreply.github.com"

WORKDIR /app

# Prefer not to run as root.
USER deno

# Cache the dependencies as a layer (the following two steps are re-run only when deps.ts is modified).
# Ideally cache deps.ts will download and compile _all_ external files used in main.ts.
COPY app/deps.ts .
RUN deno cache deps.ts

# Re-run upon each server.ts change:
COPY app/server.ts .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache server.ts

# The port that your application listens to set as env (can be changed)
ENV PORT=8080
EXPOSE ${PORT}

CMD ["run", "--allow-net", "--allow-env", "server.ts"]