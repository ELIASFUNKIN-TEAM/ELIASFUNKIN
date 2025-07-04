FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget curl git unzip build-essential \
    libgtk-3-dev libglu1-mesa-dev \
    libgl1-mesa-dev libasound2-dev libxrandr-dev \
    libxinerama-dev libxcursor-dev libxi-dev \
    libssl-dev software-properties-common \
    python3 python3-pip

RUN add-apt-repository ppa:haxe/releases -y && \
    apt-get update && \
    apt-get install -y haxe neko

ENV HAXELIB_PATH=/root/haxelib
ENV PATH=\"$HAXELIB_PATH:$PATH\"

RUN mkdir -p $HAXELIB_PATH && haxelib setup $HAXELIB_PATH

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs
