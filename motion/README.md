# motion docker container

This container is from the marvelous [motion project](https://github.com/Motion-Project/motion-docker).


## How to run



something like this;

docker run --name=motion \
    -p 8081:8081 \
    -p 8082:8082 \
    -p 8083:8083 \
    -p 8084:8084 \
    -p 8085:8085 \
    -p 8087:8087 \
    -e TZ="Australia/Brisbane" \
    -v /volume1/motion/config:/usr/local/etc/motion \
    -v /volume1/motion/storage:/var/lib/motion \
    --restart=always \
    motionproject/motion:latest

  * Add port 8080 for 

## Things to know

* Port 8080 is used for web control
* Port 8081 is used for stream server
* `/conf` volume holds configuration files (including base motion.conf)
* `/data` volume holds data files (like snapshots or movies)
* Any `MOTION_*` environment variable is lowercased and included in motion configuration. ex. `MOTION_VIDEODEVICE=/dev/video3` ends as `videovideo /dev/video3` in `motion.conf`.
* 

# How to Update
docker stop motion
docker rm motion
docker pull motionproject/motion:latest
- rerun above 'run' command

Things you may need to change
name = a label for the container, should be motion or motion-project (but can be anything)
ports = each -p line denotes 1 camera and its stream port
TZ = the timezone the container will be running
volumes = /dockerserver/path/to/config
    = /dockerserver/path/to/storage

## Release Notes
