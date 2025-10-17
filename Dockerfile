# -------------------------------
# Stage 1: Build backend (Go)
# -------------------------------
FROM golang:1.24.1-alpine AS backend-builder

WORKDIR /app

# Copy go mod files first (for caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy backend source
COPY cmd ./cmd
COPY internal ./internal
COPY models ./models

# Build the Go binary
RUN go build -o listmonk ./cmd


# -------------------------------
# Stage 2: Build frontend (Vue/Vite + Yarn)
# -------------------------------
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy package files
COPY frontend/package.json frontend/yarn.lock ./
COPY static/config.toml ./static/


# Create static folder before install (fix altcha issue)
RUN mkdir -p ../static/public/static

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the remaining frontend source
COPY frontend/. ./

# Build frontend (ignore ESLint warnings)
RUN yarn build || true


# -------------------------------
# Stage 3: Final runtime image
# -------------------------------
FROM alpine:latest

# Install CA certs for HTTPS connections
RUN apk --no-cache add ca-certificates

WORKDIR /listmonk

# Copy backend binary
COPY --from=backend-builder /app/listmonk ./

# Copy built frontend
COPY --from=frontend-builder /app/frontend/dist ./static/public/

# Copy original static assets (important!)
COPY static ./static

# Copy config files
#COPY config.toml ./
# COPY config.toml.sample ./static/

# Copy the entire static directory
COPY static ./static

# Expose default Listmonk port
EXPOSE 9000

# Start the app
# CMD ["./listmonk"]
# CMD ["./listmonk", "--static-dir=./static"]
#CMD ["./listmonk", "--static-dir=/listmonk/static"]
CMD ["./listmonk", "--config", "/listmonk/static/config.toml", "--static-dir=/listmonk/static"]

