#! /bin/bash
IMAGE_TAG=https-webserver 

# build image
docker build --tag $IMAGE_TAG .