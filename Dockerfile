# Stage 1: Frontend build
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend

# Copy frontend package files and install dependencies
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy all frontend source code and build
COPY frontend/ ./
RUN yarn build

# Stage 2: Backend build
FROM golang:1.24.1-alpine AS backend-builder
WORKDIR /app

# Copy Go modules and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy all source code
COPY . .

# Copy built frontend static files
COPY --from=frontend-builder /app/frontend/dist ./static/public

# Build Go binary
RUN go build -o listmonk ./cmd

# Stage 3: Final runtime
FROM alpine:latest
WORKDIR /listmonk

# Install CA certificates
RUN apk --no-cache add ca-certificates

# Copy Go binary and static files from backend-builder
COPY --from=backend-builder /app/listmonk .
COPY --from=backend-builder /app/static ./static

# Expose port
EXPOSE 9000

# Run listmonk
CMD ["./listmonk"]
