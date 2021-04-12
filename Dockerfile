ARG UBUNTU_VERSION=focal
FROM ubuntu:${UBUNTU_VERSION}
ARG UBUNTU_VERSION
ARG NUM_CPUS=2
ENV PG_VERSION=13.2 \
    BITS=64

RUN set -ex ;\
    if [ $BITS -eq 64 ]; then \
        export APT_PREFIX="x86-64"; \
        export BLD_PREFIX="x86_64"; \
    else \
        export APT_PREFIX="i686" ;\
        export BIT_PREFIX="i686" ;\
    fi ;\
    apt-get update ;\
    apt-get -y dist-upgrade ;\
    apt-get -y install gnupg2 software-properties-common ;\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 86B72ED9 ;\
    add-apt-repository "deb [arch=amd64] https://mirror.mxe.cc/repos/apt ${UBUNTU_VERSION} main" ;\
    set +x ;\
    pk_list_static="" ;\
    pk_list_shared="" ;\
    for pk in cc zlib dbus fontconfig freetds freetype harfbuzz jpeg \
        libmysqlclient libpng libxml2 openssl pcre2 postgresql \
        sqlite qtbase qtimageformats qtsvg qttools ; do \
            pk_list_static="$pk_list_static  mxe-${APT_PREFIX}-w64-mingw32.static-${pk}" ;\
            pk_list_shared="$pk_list_shared  mxe-${APT_PREFIX}-w64-mingw32.shared-${pk}" ;\

    done ;\
    set -x ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get install -y \
        $pk_list_static \
        $pk_list_shared \
        build-essential \
        automake \
        autoconf \
        tzdata \
        python3 ;\
    ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime ;\
    dpkg-reconfigure --frontend noninteractive tzdata ;\
    curl --output /tmp/postgres.tar.gz "https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz" ;\
    mkdir -p /opt/src/postgres ;\
    tar --strip-components=1 -C /opt/src/postgres -xvf /tmp/postgres.tar.gz ;\
    echo "Building Postgres ${PG_VERSION} on ${NUM_CPUS} cpus" >&2 ; \
    cd /opt/src/postgres ;\
    export PATH=/usr/lib/mxe/usr/bin:${PATH} ;\
    ./configure --host=${BLD_PREFIX}-w64-mingw32.static --prefix=/opt/postgresql --with-system-tzdata=/usr/share/zoneinfo;\
    make -j $NUM_CPUS ;\
    make install ;\
    cd /opt/src ;\
    rm -rf /opt/src/postgres /tmp/postgres.tar.gz ;\
    git clone https://github.com/digitalist/pydeployqt.git /opt/src/pydeployqt ;\
    git clone https://github.com/pgmodeler/pgmodeler.git /opt/src/pgmodeler ;\
    apt-get autoremove --purge -y \
        ${pk_list_static} \
        gnupg2 \
        software-properties-common ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/*

COPY data /

WORKDIR /opt
VOLUME /opt/pgmodeler
ENTRYPOINT ["/bin/bash", "src/script/build.sh"]

