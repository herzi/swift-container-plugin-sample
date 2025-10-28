# `swift-container-plugin` Example

This example serves to showcase a bug I'm chasing:  Packaging works on macOS but not on Linux.

This is sufficient for development and deploying hot-fixes, but not for regular CI builds via GitHub Actions.

## macOS

Assuming the Swift 6.2 open source toolchain AND the static linux swift SDK are installed, running the following command will fail like this (due to missing credentials for `registry.digitalocean.com`, expected):

```
# sh Scripts/build-container.sh
TOOLCHAINS=org.swift.6200202509111a
Compiler:  swift-6.2-RELEASE
SDK:       swift-6.2-RELEASE_static-linux-0.0.1
…
Build of product 'hello-world' complete! (56.85s)
[ContainerImageBuilder] Found base image manifest: sha256:e02fd41584b2a98ee93d9e2264bfd493f613eac63b5214c43610080e9311b0d7
[ContainerImageBuilder] Found base image configuration: sha256:ea4488fd894dbd2bacf2ba5ea0398df21a7a3bc29799ac6e494a50cd85d029ac
error: Registry returned an unexpected HTTP error code: 401 
# 
```

## Linux

Running the following using docker will fail like this (due to an error accessing Docker Hub for the base images, unexpected):

```
# docker build -f Dockerfile .
…
31.46 Build of product 'hello-world' complete! (27.94s)
33.11 [ContainerImageBuilder] Found base image manifest: sha256:e02fd41584b2a98ee93d9e2264bfd493f613eac63b5214c43610080e9311b0d7
33.46 error: Registry returned an unexpected HTTP error code: 400 
…
```

**Note:**  This `Dockerfile` uses caching for `.build` in order to fail faster on subsequent attempts

