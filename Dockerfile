# -------------------------------
# Stage 1: Build backend (Go)
# -------------------------------
FROM golang:1.24.1-alpine AS backend-builder

WORKDIR /app

# Copy go mod files first (for caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy entire backend source
COPY . .

# Build the listmonk binary
RUN go build -o listmonk ./cmd


# -------------------------------
# Stage 2: Build frontend (Vue/Vite + Yarn)
# -------------------------------
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy package files
COPY frontend/package.json frontend/yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Fix altcha copy issue (ensure directory exists)
RUN mkdir -p ../static/public/static && \
    cp node_modules/altcha/dist/altcha.umd.cjs ../static/public/static/altcha.umd.js

# Copy the remaining frontend source and build
COPY frontend/ ./
RUN yarn build


# -------------------------------
# Stage 3: Final runtime image
# -------------------------------
FROM alpine:latest

# Install CA certs for HTTPS connections
RUN apk --no-cache add ca-certificates

WORKDIR /listmonk

# Copy backend binary
COPY --from=backend-builder /app/listmonk ./

# Copy static files (built frontend)
COPY --from=frontend-builder /app/frontend/dist ./static/public/

# Expose default Listmonk port
EXPOSE 9000

# Start the app
CMD ["./listmonk"]
