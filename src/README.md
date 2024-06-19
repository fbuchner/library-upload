# Developer considerations

This README is only relevant for developers and maintainers of this repository.

## Deployment workflow

```shell
# Build the software
go mod tidy
go build main.go  

# Build the container
docker build --tag library-upload .

# Sign in to the github container registry. Create an access token first: https://github.com/settings/tokens/new?scopes=write:packages
echo YOUR-ACCESS-TOKEN | docker login ghcr.io -u YOUR-USERNAME --password-stdin

# Create a new tag
docker tag library-upload:latest ghcr.io/fbuchner/library-upload:latest

# push image to the github container registry
docker push ghcr.io/fbuchner/library-upload:latest
```