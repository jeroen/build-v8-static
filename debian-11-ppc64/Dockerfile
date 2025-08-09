FROM debian:11

ARG v8_version=11.9.169.7
ENV version=$v8_version

ENV target arm64.static
ENV GYP_GENERATORS ninja
ENV PATH="/depot_tools:${PATH}"
ENV pkgdir /package

RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y curl python3 xz-utils git g++ g++-powerpc64le-linux-gnu pkg-config libglib2.0-dev

RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools

RUN yes | fetch v8

WORKDIR /v8

RUN gclient sync -D --force --reset && \
	gclient sync --revision ${version}

# Bug in zlib for simd, was fixed somewhere in version 8.6 I think
RUN sed -i.bak 's/use_arm_neon_optimizations = true/use_arm_neon_optimizations = false/g' third_party/zlib/BUILD.gn

RUN gn gen ${target} -vv --fail-on-unused-args \
    --args='v8_monolithic=true \
            v8_static_library=true \
            v8_enable_sandbox=false \
            is_clang=false \
            is_asan=false \
            use_gold=false \
            is_debug=false \
            is_official_build=false \
            treat_warnings_as_errors=false \
            clang_use_chrome_plugins=false \
            v8_enable_i18n_support=false \
            v8_use_external_startup_data=false \
            use_custom_libcxx=false \
            use_sysroot=false \
            target_cpu="ppc64" v8_target_cpu="ppc64"'

# NB: do not build tests on ARM
RUN ninja -C ${target} "v8_monolith" "d8"

RUN	install -d ${pkgdir}v8 && \
	install -d ${pkgdir}/v8/lib && \
	install -Dm755 ${target}/obj/libv8_monolith.a ${pkgdir}/v8/lib/libv8_monolith.a && \
	install -d ${pkgdir}/v8/include && \
	install -Dm644 include/*.h ${pkgdir}/v8/include && \
	install -d ${pkgdir}/v8/include/cppgc && \
	install -Dm644 include/cppgc/*.h ${pkgdir}/v8/include/cppgc && \
	install -d ${pkgdir}/v8/include/libplatform && \
	install -Dm644 include/libplatform/*.h ${pkgdir}/v8/include/libplatform && \
	install -d ${pkgdir}/v8/lic/ && \
	install -m644 LICENSE* ${pkgdir}/v8/lic/ && \
	tar cfJ /v8-${version}-static.tar.xz -C ${pkgdir} v8
