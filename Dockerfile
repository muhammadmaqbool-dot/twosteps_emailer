# Stage 1: Build stage
FROM golang:1.24.1-alpine AS builder

WORKDIR /app

# Copy Go mod files and download deps
COPY go.mod go.sum ./
RUN go mod download

# Copy the entire source
COPY . .

# Build the binary
RUN go build -o listmonk ./cmd

# Stage 2: Run stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata shadow su-exec

WORKDIR /listmonk

# Copy compiled binary and required files from builder
COPY --from=builder /app/listmonk .
COPY --from=builder /app/static ./static
COPY --from=builder /app/i18n ./i18n
COPY --from=builder /app/config.toml.sample ./config.toml.sample

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/listmonk/listmonk", "--config", "/listmonk/config.toml"]
