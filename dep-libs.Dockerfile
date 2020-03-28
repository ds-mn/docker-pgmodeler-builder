ARG BASE_TAG=mumblepins/pgmodeler-builder
FROM $BASE_TAG-dep-mxe:latest

ARG VERSION_POSTGRESQL=REL_12_0
ARG NUM_CPUS=1

RUN set -ex ; \
    echo "Building libraries on ${NUM_CPUS} cpus" > &2 ; \
    cd /opt/mxe ; \
    make -j$NUM_CPUS MXE_TARGETS='x86_64-w64-mingw32.shared x86_64-w64-mingw32.static' \
        zlib dbus fontconfig freetds freetype harfbuzz jpeg libmysqlclient \
        libpng libxml2 openssl pcre2 postgresql sqlite qtbase qtimageformats qtsvg; \
    rm -rf pkg .ccache
