# ==========================================
# Build Stage
# ==========================================
FROM hexpm/elixir:1.15.7-erlang-26.2.1-debian-bookworm-20231009-slim AS builder

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build directory
WORKDIR /app

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build environment to production
ENV MIX_ENV="prod"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy application source code and configuration
COPY priv priv
COPY assets assets
COPY lib lib
COPY config config

# Compile application and build assets
RUN mix compile
RUN mix assets.deploy

# Copy runtime configuration
COPY config/runtime.exs config/

# Assemble Elixir release
RUN mix release

# ==========================================
# Production Runtime Stage
# ==========================================
FROM debian:bookworm-20231009-slim

# Install runtime dependencies and setup locale
RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl ca-certificates locales curl \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8"

# Prepare runtime workspace
WORKDIR /app
RUN chown nobody:root /app

# Copy compiled release
COPY --from=builder --chown=nobody:root /app/_build/prod/rel/sipadu ./

# Copy and setup entrypoint script
COPY --chown=nobody:root entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Run as non-root user for security
USER nobody

# Expose Phoenix default port
EXPOSE 4000

# Set environment variables for production runtime
ENV MIX_ENV="prod" \
    PORT="4000" \
    PHX_SERVER="true"

# Boot via entrypoint script to run migrations automatically
ENTRYPOINT ["/app/entrypoint.sh"]
