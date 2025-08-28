
### Building images

Create a multiarch builder

```
docker buildx create --name devel --platform linux/386,linux/amd64,linux/arm/v7,linux/arm64
docker buildx use devel
```

Build and push images for multiple archs

```
docker \
  buildx build \
  --builder devel \
  --platform "linux/386,linux/amd64,linux/arm/v7,linux/arm64" \
  --tag "${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:1.2.3" \
  --tag "${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest" \
  --push \
  "$IMAGE_PATH"
```

Links:

  * https://docs.docker.com/desktop/multi-arch/
  * https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/
