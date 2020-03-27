FROM ubuntu:latest

ARG NUM_CPUS=1

RUN set -ex ; \
    apt-get update ; \
    apt-get install -y autoconf automake autopoint bash bison bzip2 flex g++ g++-multilib gettext git gperf intltool \
    libc6-dev-i386 libgdk-pixbuf2.0-dev libltdl-dev libssl-dev libtool-bin libxml-parser-perl lzip make openssl \
    p7zip-full patch perl pkg-config python ruby sed unzip wget xz-utils ; \
    mkdir -p /opt/src ; \
    cd /opt/src ; \
    git clone https://github.com/digitalist/pydeployqt.git ; \
    cd /opt ; \
    git clone https://github.com/mxe/mxe.git ; \
    cd /opt/mxe ; \
    make -j$NUM_CPUS MXE_TARGETS='x86_64-w64-mingw32.shared x86_64-w64-mingw32.static' cc


