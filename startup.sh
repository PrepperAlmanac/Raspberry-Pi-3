#! /bin/bash

tightvncserver -geometry 1024x520 :1
calibre-server --port=8001 --with-library=/home/pi/Library/ --daemonize
