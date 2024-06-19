# syntax=docker/dockerfile:1

# Use the following command to build the docker container (make sure to run docker on your system)
# docker build --tag library-upload .

# Use the Golang alpine image as the base image for building the Go binary. 
# This works for this limited app, switch to the default Go image (non-alpine) in case of major changes to the code base.
FROM golang:alpine AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files from src/
COPY src/go.mod src/go.sum ./

# Change working directory to src/ and download dependencies
RUN go mod download

# Copy the source code into the container
COPY src/ ./

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./library-upload

# Set the Gin mode to release
ENV GIN_MODE=release

# Move compiled assets to clean Alpine Linux
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/library-upload .
COPY --from=builder /app/public/ ./public/

EXPOSE 8080

# Command to run the executable
CMD ["./library-upload"]
