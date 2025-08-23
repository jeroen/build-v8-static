# Building V8

Some dockerfiles for building libv8 on various platforms.

The releases section in this repository has binaries as built by the GitHub actions CI.

## How to use

Run `docker build . -t myv8` in any of the source dirs. If all goes well, the final image has `/v8-{version}.tar.xz` in the root. Use `docker run myv8` and then `docker cp` to copy it to your system. Also see the [CI workflow](https://github.com/jeroen/build-v8-static/blob/HEAD/.github/workflows/build.yml) how to do this.

## Some notes

Nowadays we use the V8 source code bundled with nodejs, which is more portable and already includes dependencies. However if you want to build from the upstream V8 git repository instead, have a look at the [11.9-final](https://github.com/jeroen/build-v8-static/tree/11.9-final) tag for examples how to do this.

This is a minimal build without internationalization which results in a single "monolith" static library. Tweak the `gn gen` command to enable other features.

Building V8 requires a lot of memory, if you get random failures, docker may be running out of memory or disk space. In this case try chaning the build command to `ninja -j1`.
