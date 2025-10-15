# ==============================
# Stage 1: Frontend build
# ==============================
FROM node:20-alpine AS frontend-builder

# Set working directory
WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package.json frontend/yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy all frontend source code
COPY frontend/ ./

# Make sure target directories exist for static files
RUN mkdir -p ../static/public/static

# Build frontend
RUN yarn build

# ==============================
# Stage 2: Backend build
# ==============================
FROM golang:1.24.1-alpine AS backend-builder

WORKDIR /app

# Copy Go mod files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy entire source code (including frontend dist if needed)
COPY . .

# Copy frontend build output into backend static folder
COPY --from=frontend-builder /app/frontend/dist ./static/public

# Build Go binary
RUN go build -o listmonk ./cmd

# ==============================
# Stage 3: Final runtime image
# ==============================
FROM alpine:latest

# Install CA certificates
RUN apk --no-cache add ca-certificates

WORKDIR /listmonk

# Copy everything from backend-builder stage
COPY --from=backend-builder /app /listmonk

# Expose port
EXPOSE 9000

# Run listmonk
CMD ["./listmonk"]
