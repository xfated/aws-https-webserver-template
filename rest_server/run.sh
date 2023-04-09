#! /bin/bash
IMAGE_TAG=https-webserver

# Run. -p maps port 3000 on your machine to port 3000 of your docker image
docker run -p 3000:3000 $IMAGE_TAG