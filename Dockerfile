# Stage 1: Build stage
FROM golang:1.24.1-alpine AS builder

WORKDIR /app

# Copy Go mod files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy entire source code
COPY . .

# Build listmonk binary
RUN go build -o listmonk ./cmd

# Stage 2: Run stage
FROM alpine:latest

# Install CA certificates
RUN apk --no-cache add ca-certificates

WORKDIR /listmonk

# Copy everything from builder stage
COPY --from=builder /app /listmonk

# Expose port
EXPOSE 9000

# Run listmonk
CMD ["./listmonk"]
