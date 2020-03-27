ARG BASE_TAG
FROM $BASE_TAG-dep-pgsql:latest

COPY data /

WORKDIR /opt
ENTRYPOINT ["/bin/bash", "src/script/build.sh"]

