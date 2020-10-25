# Building V8

Some dockerfiles for building libv8 on various platforms. Based on Jan Marvin's [v8-static](https://github.com/JanMarvin/v8-static) script for building V8 on Arch.

Run `docker build . -t myv8` in the source dir. If all goes well, the final image has `/v8-{version}.tar.xz` in the root. Use `docker run myv8` and then `docker cp` to copy it to your system.

## Important notes

Because depot_tools changes all the time, this will probably only work for recent versions of V8. To build an older V8 version, you may have to add a step to checkout an older version of depot_tools. Suitable dependency versions are storted in the [DEPS](https://github.com/v8/v8/blob/master/DEPS) file in the V8 source tree for the version you are building.

V8 pulls in a custom clang++ compiler at build time, so I think the version of g++ on your system doesn't matter. But it should still be using your system libcxx, which is what is important to use the library in your applications.

This is a minimal build without internationalization which results in a single "monolith" static library. Tweak the `gn gen` command to enable other features.

Building V8 requires a lot of memory, if you get random failures, docker may be running out of memory or disk space.
