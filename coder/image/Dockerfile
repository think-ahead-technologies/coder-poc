FROM codercom/enterprise-node:ubuntu

USER root

RUN mkdir /jetbrains \
    && cd /jetbrains \
    && wget https://download.jetbrains.com/idea/code-with-me/backend/jetbrains-clients-downloader-linux-x86_64-1867.tar.gz -O ./client-downloader.tar.gz
RUN cd /jetbrains \
    && tar -xf client-downloader.tar.gz \
    && cd jetbrains-clients-downloader-linux-x86_64-1867/bin \
    && ls \
    && /bin/bash jetbrains-clients-downloader \
        --products-filter IU --build-filter 223.7255.1 \
        --include-eap-builds --platforms-filter linux-x64 \
        --download-backends Desktop/backends

# RUN tar -xvf jetbrains-clients-downloader-linux-x86_64-1867.tar.gz

RUN ls -r /jetbrains && false