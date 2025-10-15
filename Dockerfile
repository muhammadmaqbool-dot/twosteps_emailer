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

# Create empty .eslintignore to avoid ESLint error
RUN touch .eslintignore

# Create static folder before install (fix altcha issue)
RUN mkdir -p ../static/public/static

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the remaining frontend source
COPY frontend/ ./
