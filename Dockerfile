FROM denoland/deno as build

# The port that your application listens to.
EXPOSE 8080

WORKDIR /app

# Prefer not to run as root.
USER deno

# These steps will be re-run upon each file change in your working directory:
COPY app/server.ts main.ts

# Compile the main app so that it doesn't need to be compiled each startup/entry.

CMD ["run", "--allow-net", "main.ts"]