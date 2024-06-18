# syntax=docker/dockerfile:1

# Use the following command to build the docker container (make sure to run docker on your system)
# docker build --tag library-upload .

# Use the Golang alpine image as the base image for building the Go binary. 
# This works for this limited app, switch to the default Go image (non-alpine) in case of major changes to the code base.
FROM golang:1.22-alpine

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files from src/
COPY src/go.mod src/go.sum ./

# Set environment variable for Go modules proxy, adjust if necessary
ENV GOPROXY=https://proxy.golang.org,direct

# Change working directory to src/ and download dependencies
RUN go mod download

# Copy the source code into the container
COPY src/ ./

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -o ./library-upload

# Optional:
# To bind to a TCP port, runtime parameters must be supplied to the docker command.
# But we can document in the Dockerfile what ports
# the application is going to listen on by default.
# https://docs.docker.com/reference/dockerfile/#expose
EXPOSE 8080

# Command to run the executable
CMD ["./library-upload"]
