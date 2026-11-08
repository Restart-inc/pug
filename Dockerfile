# syntax=docker/dockerfile:1
FROM golang:1.27.3-alpine AS build

WORKDIR /src

# Download dependencies in a cached layer
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build
COPY . .
RUN CGO_ENABLED=0 go build -o /bin/pug ./cmd/server

# Runtime image
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=build /bin/pug /bin/pug

EXPOSE 3000
CMD ["/bin/pug", "start"]
