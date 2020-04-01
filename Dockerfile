FROM ubuntu:bionic

RUN set -ex ;\
    apt-get update ;\
    apt-get -y dist-upgrade ;\
    apt-get -y install gnupg2 software-properties-common;\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 86B72ED9 ;\
    add-apt-repository 'deb [arch=amd64] https://mirror.mxe.cc/repos/apt bionic main' ;\
    set +x ;\
    pk_list="" ;\
    for pk in cc zlib dbus fontconfig freetds freetype harfbuzz jpeg \
        libmysqlclient libpng libxml2 openssl pcre2 postgresql \
        sqlite qtbase qtimageformats qtsvg qttools ; do \
        #mxe-x86-64-w64-mingw32.shared-
#        pk_list="$pk_list mxe-x86-64-w64-mingw32.static-$pk" ;\
        for pfx in mxe-x86-64-w64-mingw32.static mxe-x86-64-w64-mingw32.shared; do \
            pk_list="$pk_list $pfx-$pk" ;\
        done \
    done ;\
    set -x ;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get install -y \
        $pk_list \
        build-essential \
        automake \
        autoconf \
        tzdata \
        python3 ;\
    ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime ;\
    dpkg-reconfigure --frontend noninteractive tzdata ;\
    apt-get autoremove -y --purge gnupg2 software-properties-common ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* ;\
    mkdir -p /opt/src ;\
    cd /opt/src ; \
    git clone https://github.com/digitalist/pydeployqt.git

ARG NUM_CPUS=1
ARG PG_VERSION=12.2

RUN set -ex ;\
    curl --output /tmp/postgres.tar.gz "https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz" ;\
    mkdir -p /opt/src/postgres ;\
    tar --strip-components=1 -C /opt/src/postgres -xvf /tmp/postgres.tar.gz ;\
    echo "Building Postgres ${PG_VERSION} on ${NUM_CPUS} cpus" >&2 ; \
    cd /opt/src/postgres ;\
    export PATH=/usr/lib/mxe/usr/bin:${PATH} ;\
    ./configure --host=x86_64-w64-mingw32.static --prefix=/opt/postgresql --with-system-tzdata=/usr/share/zoneinfo;\
    make -j $NUM_CPUS ;\
    make install ;\
    cd /opt/src ;\
    rm -rf /opt/src/postgres /tmp/postgres.tar.gz ;\
    git clone https://github.com/pgmodeler/pgmodeler.git /opt/src/pgmodeler

RUN apt-get update && apt-get install -y python3

COPY data /

WORKDIR /opt
ENTRYPOINT ["/bin/bash", "src/script/build.sh"]

