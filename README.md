# pgModeler Builder
[![Docker Pulls](https://img.shields.io/docker/pulls/mumblepins/pgmodeler-builder?style=flat-square) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/mumblepins/pgmodeler-builder?style=flat-square) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/mumblepins/pgmodeler-builder/latest?style=flat-square)](https://hub.docker.com/repository/docker/mumblepins/pgmodeler-builder)

A [Docker](https://www.docker.com) container that allows you to build [pgModeler](https://pgmodeler.io/) with one
simple command.

# Features

This container currently produces binaries for Windows  only.  Other platforms are forthcoming.

# Usage

Simply run the `pgmodeler-builder` image, specifying an output volume, mapped to the container
directory `/opt/pgmodeler` (where binaries will be saved) and the version to build (corresponding to a valid tag or branch in the
[pgModeler Git repository](https://github.com/pgmodeler/pgmodeler) repository). OPtionally, add the # of cpus to build on. For example, to build pgModeler
version `0.9.3` and store the result in `/mnt/windows/pgmodeler` using 2 cpus:

```bash
docker run -v /mnt/windows/pgmodeler:/opt/pgmodeler handcraftedbits/pgmodeler-builder v0.9.3 2
```

If you run the command without specifying a version the container script will list all valid pgModeler versions.

Simply run the `pgmodeler.exe` executable stored in your output directory.  That's it!

