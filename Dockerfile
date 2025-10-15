# Stage 1: Build stage
FROM golang:1.24.1-alpine AS builder

WORKDIR /app

# Copy Go mod files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the entire source code
COPY . .

# Build the listmonk binary
RUN go build -o listmonk ./cmd

# Stage 2: Run stage
FROM alpine:latest

# Install CA certificates
RUN apk --no-cache add ca-certificates

WORKDIR /listmonk

# Copy the listmonk binary
COPY --from=builder /app/listmonk .

# Copy all necessary static and i18n files
COPY --from=builder /app/static ./static
COPY --from=builder /app/i18n ./i18n

# Copy config files (optional: Render will override via environment variables)
COPY --from=builder /app/config.toml ./config.toml
COPY --from=builder /app/config.toml.sample ./config.toml.sample

# Expose Listmonk port
EXPOSE 9000

# Start Listmonk
CMD ["./listmonk"]
