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

RUN apk --no-cache add ca-cert

WORKDIR /listmonk

# Copy binary from builder
COPY --from=builder /app/listmonk .

# Copy static files needed by listmonk
COPY --from=builder /app/static ./static
COPY --from=builder /app/i18n ./i18n
COPY --from=builder /app/config.toml ./config.toml

# Expose the port
EXPOSE 9000

# Run listmonk
CMD ["./listmonk"]
