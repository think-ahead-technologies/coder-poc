#!/bin/bash

# https://github.com/apricote/hcloud-upload-image

export TALOS_IMAGE_VERSION=v1.9.1 # You can change to the current version
export TALOS_IMAGE_ARCH=arm64 # You can change to arm architecture
export HCLOUD_SERVER_ARCH=arm # HCloud server architecture can be x86 or arm
wget https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/${TALOS_IMAGE_VERSION}/hcloud-${TALOS_IMAGE_ARCH}.raw.xz
hcloud-upload-image upload \
      --image-path *.xz \
      --architecture $HCLOUD_SERVER_ARCH \
      --compression xz

