# network host is required for UDP?
# https://github.com/aler9/rtsp-simple-server#docker
docker run --rm -it --network=host aler9/rtsp-simple-server

docker run --rm -it -p 8554:8554/tcp -p 8000-8001:8000-8001/udp -p 1935:1935/tcp -p 8888:8888/tcp  aler9/rtsp-simple-server


## Send raw jpeg

gst-launch-1.0 -e libcamerasrc ! 'video/x-raw,width=640,heigth=360' ! decodebin ! videoconvert ! jpegenc ! rtpjpegpay ! udpsink host=150.128.184.160 port=5000

gst-launch-1.0 udpsrc  port=5000 ! application/x-rtp,encoding-name=JPEG,payload=26 ! rtpjpegdepay ! decodebin ! autovideosink


## Send h264 (has speed issues)

gst-launch-1.0 -e libcamerasrc ! 'video/x-raw,width=640,heigth=360' ! decodebin ! videoconvert ! x264enc tune=zerolatency ! 'video/x-h264,profile=main' ! rtph264pay ! udpsink host=150.128.184.160 port=5000


gst-launch-1.0 udpsrc  port=5000 ! application/x-rtp,encoding-name=H264,payload=96 ! rtph264depay  ! decodebin ! autovideosink


## h264 with HW encoding support (color issues)


gst-launch-1.0 -e libcamerasrc !  'video/x-raw,framerate=30/1,format=UYVY' ! videoconvert ! queue ! v4l2h264enc ! 'video/x-h264,level=(string)4' ! rtph264pay ! udpsink host=150.128.184.160 port=5000

gst-launch-1.0 -e libcamerasrc !  'video/x-raw,framerate=30/1,format=UYVY' ! videoconvert ! queue ! v4l2h264enc ! 'video/x-h264,level=(string)4'  ! queue ! rtspclientsink location=rtsp://inspiron13.:8554/mystream protocols=udp-mcast+udp

# Publicar en RTSP
# protocols=udp-mcast+udp → Reducción significativa de latencia

gst-launch-1.0 -e libcamerasrc ! 'video/x-raw,width=640,heigth=360' ! decodebin ! videoconvert ! x264enc tune=zerolatency ! queue ! rtspclientsink location=rtsp://inspiron13.:8554/mystream protocols=udp-mcast+udp


## Publicar en RTSP y H.264

- https://en.wikipedia.org/wiki/Advanced_Video_Coding#Levels

### extra-controls

Ver `v4l2-ctl -d /dev/video11 --all`.

h264 profile=main level=4.0 (Handbrake defaults)

```
    gst-launch-1.0 -e \
        libcamerasrc ! 'video/x-raw,width=1920,height=1080,framerate=30/1,format=UYVY' \
        ! videoconvert \
        ! queue ! v4l2h264enc extra-controls="i,video_bitrate_mode=0:i,video_bitrate=25000000:i,h264_profile=2:i,h264_level=11" ! 'video/x-h264,level=(string)4' \
        ! h264parse config-interval=1 \
        ! queue ! rtspclientsink location=rtsp://inspiron13.:8554/mystream protocols=udp-mcast+udp
```

```
Codec Controls

             video_bitrate_mode 0x009909ce (menu)   : min=0 max=1 default=0 value=0 flags=update
                                0: Variable Bitrate
                                1: Constant Bitrate
                  video_bitrate 0x009909cf (int)    : min=25000 max=25000000 step=25000 default=10000000 value=10000000
           sequence_header_mode 0x009909d8 (menu)   : min=0 max=1 default=1 value=1
                                0: Separate Buffer
                                1: Joined With 1st Frame
         repeat_sequence_header 0x009909e2 (bool)   : default=0 value=0
                force_key_frame 0x009909e5 (button) : flags=write-only, execute-on-write
          h264_minimum_qp_value 0x00990a61 (int)    : min=0 max=51 step=1 default=20 value=20
          h264_maximum_qp_value 0x00990a62 (int)    : min=0 max=51 step=1 default=51 value=51
            h264_i_frame_period 0x00990a66 (int)    : min=0 max=2147483647 step=1 default=60 value=60
                     h264_level 0x00990a67 (menu)   : min=0 max=15 default=11 value=11
                                0: 1
                                1: 1b
                                2: 1.1
                                3: 1.2
                                4: 1.3
                                5: 2
                                6: 2.1
                                7: 2.2
                                8: 3
                                9: 3.1
                                10: 3.2
                                11: 4
                                12: 4.1
                                13: 4.2
                                14: 5
                                15: 5.1
                   h264_profile 0x00990a6b (menu)   : min=0 max=4 default=4 value=4
                                0: Baseline
                                1: Constrained Baseline
                                2: Main
                                4: High
```


docker run --rm -it --network=host aler9/rtsp-simple-server




https://www.codeinsideout.com/blog/pi/set-up-camera/#ffmpeg
https://www.waveshare.com/wiki/RPi_Camera