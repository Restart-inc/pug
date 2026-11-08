# --- Build Stage ---
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Install git and build essentials
RUN apk add --no-cache git make

# Copy go.mod and go.sum files first for caching dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the server binary
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/pug ./cmd/server

# --- Runtime Stage ---
FROM alpine:latest

WORKDIR /app

RUN apk --no-cache add ca-certificates

# Copy binary from builder
COPY --from=builder /bin/pug /app/pug

EXPOSE 3000

CMD ["./pug"]
