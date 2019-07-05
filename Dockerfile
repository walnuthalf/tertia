# ============
#
# Build stage
#
# ============
FROM bitwalker/alpine-elixir:1.8.2 as builder

WORKDIR /opt/app

RUN apk update && \
    apk --no-cache --update upgrade busybox musl && \
    apk --no-cache --update add git make g++ curl && \
    rm -rf /var/cache/apk/* && \
    unset http_proxy

COPY config/* config/
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .

RUN mix release --env=prod --no-tar

# ============
#
# Deploy stage
#
# ============
FROM bitwalker/alpine-elixir:1.8.2

EXPOSE 4000

ENV PORT=4000 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/sh

COPY --from=builder /opt/app/_build/prod/rel/tertia /opt/app

ENTRYPOINT ["/opt/app/bin/tertia"]
CMD ["foreground"]

