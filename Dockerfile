# ---------------------------
# Stage 1: Frontend build
# ---------------------------
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy only frontend package files first (faster caching)
COPY frontend/package.json frontend/yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy frontend source code
COPY frontend/ .

# Build frontend
RUN yarn build

# ---------------------------
# Stage 2: Backend build
# ---------------------------
FROM golang:1.24.1-alpine AS backend-builder

WORKDIR /app

# Copy Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy full source
COPY . .

# Build the Listmonk binary
RUN go build -o listmonk ./cmd

# ---------------------------
# Stage 3: Final runtime image
# ---------------------------
FROM alpine:latest

# Install CA certificates
RUN apk --no-cache add ca-certificates bash

WORKDIR /listmonk

# Copy backend binary
COPY --from=backend-builder /app/listmonk ./

# Copy frontend build into backend static folder
COPY --from=frontend-builder /app/frontend/dist ./static/public

# Expose port
EXPOSE 9000

# Set environment variables (can also use Render's env vars)
ENV LISTMONK_app__address=0.0.0.0:9000
ENV LISTMONK_api__enable=true

# Run the app
CMD ["./listmonk"]
