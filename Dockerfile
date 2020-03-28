ARG BASE_TAG=mumblepins/pgmodeler-builder
FROM $BASE_TAG-dep-pgsql:latest

COPY data /

WORKDIR /opt
ENTRYPOINT ["/bin/bash", "src/script/build.sh"]

