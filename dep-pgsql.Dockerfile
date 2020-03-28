ARG BASE_TAG=mumblepins/pgmodeler-builder
FROM $BASE_TAG-dep-libs:latest

ARG VERSION_POSTGRESQL=REL_12_0
ARG NUM_CPUS=1

RUN set -ex ; \
    git clone https://github.com/postgres/postgres.git /opt/src/postgres ; \
    cd /opt/src/postgres ; \
    git checkout -b ${VERSION_POSTGRESQL} ${VERSION_POSTGRESQL} ; \
    echo "Building Postgres ${VERSION_POSTGRESQL} on ${NUM_CPUS} cpus" > &2 ; \
    export PATH=/opt/mxe/usr/bin:${PATH} ;\
    ./configure --host=x86_64-w64-mingw32.static --prefix=/opt/postgresql ; \
    make -j $NUM_CPUS; \
    make install ; \
    cd /opt/src ; \
    rm -rf /opt/src/postgres

