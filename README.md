## qBittorrent-EE

### Overview

Minimalistic qBittorrent Enhanced Edition container image based on Apline linux.

### Build

```
ARGS=()
for i in $(find ./VERSIONS/ -type f); do
  ARGS+=('--build-arg' "${i##*/}=$(< $i)")
done
docker build "${ARGS[@]}" --tag ${PWD##*/} \
       --label org.opencontainers.image.created="$(date --rfc-3339 seconds --utc)" \
       --label org.opencontainers.image.version=$(< DISPLAY_VERSION) \
       --label org.opencontainers.image.revision=$(git rev-parse HEAD) .
```

Push image to registry:

```
docker tag ${PWD##*/} $CONTAINER_REGISTRY_USERNAME/${PWD##*/}:$(< DISPLAY_VERSION)
docker tag ${PWD##*/} $CONTAINER_REGISTRY_USERNAME/${PWD##*/}:latest
docker push --all-tags $CONTAINER_REGISTRY_USERNAME/${PWD##*/}
```

### Environment variables

| Name | Default value | Description |
| --- | --- | --- |
| PORT_BT | 6881 | Bittorrent port |
| PORT_UI | 8080 | WebUI port |
| TRACKERS | [URL](https://cdn.jsdelivr.net/gh/ngosang/trackerslist/trackers_all.txt) | Trackers list for auto update |
| UPLOAD_RATIO | 5 | Upload ratio until pause seeding |
| UPLOAD_SPEED | 0 | Upload speed (0=Unlimited) |

### Run

```
docker run --detach \
       --restart always \
       --env KEY=VALUE \
       --publish $EXTERNAL_PORT_BT:$PORT_BT/tcp \
       --publish $EXTERNAL_PORT_BT:$PORT_BT/udp \
       --volume $PATH_TO_CONFIG:/config \
       --volume $PATH_TO_DATA:/data \
       ghcr.io/fei1yang/qbittorrent:latest
```

After container is up

Note: [Podman](https://podman.io/) is recommended for use this container image due to its amazing automatic update feature, please refer to the [official document](https://docs.podman.io/en/latest/markdown/podman-auto-update.1.html) for further details.
