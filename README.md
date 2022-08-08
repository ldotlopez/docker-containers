
### Building images

Create a multiarch builder

```
docker buildx create --name mybuilder --platform linux/386,linux/amd64,linux/arm/v7
```

Build and push images for multiple archs

```
docker \
  buildx build \
  --builder mybuilder \
  --platform "linux/386,linux/amd64,linux/arm/v7" \
  --label "$IMAGE_NAME" \
  --tag "${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest" \
  --push \
  "$IMAGE_PATH"
```

Links:

  * https://docs.docker.com/desktop/multi-arch/
  * https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/
