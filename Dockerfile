# --- Stage 1: Build the React Frontend ---
FROM oven/bun:latest AS frontend-build
RUN git clone https://github.com/pug-sh/app.git /app-ui
WORKDIR /app-ui
RUN bun install
# Pass the backend URL or configure build variables if needed
ENV VITE_API_BASE_URL=https://pug.restart.ng
RUN bun run build

# --- Stage 2: Build the Go Backend ---
FROM golang:1.22-alpine AS backend-build
WORKDIR /app
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/pug ./cmd/server

# --- Stage 3: Final Runtime Image ---
FROM alpine:latest
WORKDIR /app

# Install ca-certificates for secure HTTPS requests
RUN apk --no-cache add ca-certificates

# Copy compiled Go binary
COPY --from=backend-build /bin/pug /app/pug

# Copy built React frontend static files (if your Go server is configured to serve static assets from a specific directory, e.g., /app/dist)
COPY --from=frontend-build /app-ui/dist /app/dist

EXPOSE 3000
CMD ["./pug"]
