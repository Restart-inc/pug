# --- Stage 1: Build the React Frontend ---
FROM oven/bun:latest AS frontend-build

# Install git so the clone command succeeds
RUN apt-get update && apt-get install -y git || (apt-get install -y apk-tools && apk add --no-cache git)

RUN git clone https://github.com/pug-sh/app.git /app-ui
WORKDIR /app-ui
RUN bun install
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
RUN apk --no-cache add ca-certificates
COPY --from=backend-build /bin/pug /app/pug
COPY --from=frontend-build /app-ui/dist /app/dist

EXPOSE 3000
CMD ["./pug"]
