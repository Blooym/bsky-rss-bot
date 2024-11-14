FROM denoland/deno
USER deno
WORKDIR /opt/bsky-rss-bot

# Precache deps.
COPY ["deno.json", "deno.lock", "."]
COPY ./src ./src
RUN mkdir ./data
RUN deno cache src/main.ts

# Install build dependencies
RUN apk add --update build-base cmake libressl-dev

# Pre-cache dependencies
COPY ["Cargo.toml", "Cargo.lock", "./"]
RUN mkdir src \
    && echo "// Placeholder" > src/lib.rs \
    && cargo build --release \
    && rm src/lib.rs

# Build
ARG SQLX_OFFLINE true
COPY ./migrations ./migrations
COPY ./.sqlx ./.sqlx
COPY ["./src", "./src"]
RUN cargo build --release

###########
# Runtime #
###########
FROM scratch
ENV RUST_BACKTRACE=1

# Import and switch to non-root user.
COPY --from=user /etc/passwd /etc/passwd
COPY --from=user /bin/false /bin/false
USER bskybot

# Copy binary and run
COPY --from=builder /build/target/release/bsky-rss-bot /usr/local/bin/bsky-rss-bot
ENTRYPOINT ["/usr/local/bin/bsky-rss-bot", "start"]
