# Stage 1: Build stage
FROM golang:1.24.1-alpine AS builder

# Install Node.js & npm for frontend build
RUN apk add --no-cache nodejs npm git

WORKDIR /app

# Copy Go mod files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the entire source code
COPY . .

# Build the frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Move the built frontend to static folder
RUN mkdir -p /app/static/frontend
RUN cp -r dist /app/static/frontend/dist

# Build the Go binary
WORKDIR /app
RUN go build -o listmonk ./cmd

# Stage 2: Run stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /listmonk

# Copy everything from builder
COPY --from=builder /app /listmonk

EXPOSE 9000

CMD ["./listmonk"]
