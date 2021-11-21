# Adapted from: https://github.com/humanmade/alpine-v8
ARG v8_version=9.6.180.12
ARG GN_COMMIT=0153d369bbccc908f4da4993b1ba82728055926a

# STEP 1
# Build GN for alpine
FROM alpine:3.12 as gn-builder
RUN \
  apk add --update --virtual .gn-build-dependencies alpine-sdk binutils-gold clang curl git llvm9 ninja python3 tar xz && \
  PATH=$PATH:/usr/lib/llvm9/bin  && \
  cp -f /usr/bin/ld.gold /usr/bin/ld  && \
  git clone https://gn.googlesource.com/gn /tmp/gn && \
  git -C /tmp/gn checkout ${GN_COMMIT} && \
  cd /tmp/gn && \
  python3 build/gen.py && \
  ninja -C out && \
  cp -f /tmp/gn/out/gn /usr/local/bin/gn && \
  apk del .gn-build-dependencies && \
  rm -rf /tmp/* /var/tmp/* /var/cache/apk/*


# STEP 2
# Use depot_tools to fetch the V8 source and dependencies
# This requires glibc so we use debian tools
FROM debian:10 as source

RUN \
  set -x && \
  apt-get update && \
  apt-get install -y git curl python3 && \
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools && \
  PATH=$PATH:/tmp/depot_tools && \
  cd /tmp && \
  fetch v8 && \
  cd /tmp/v8 && \
  git checkout ${v8_version} && \
  gclient sync && \
  apt-get remove --purge -y git curl python3 && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*


# STEP 3
# Build V8 for alpine
FROM alpine:3.12 as v8
COPY --from=source /tmp/v8 /tmp/v8
COPY --from=gn-builder /usr/local/bin/gn /tmp/v8/buildtools/linux64/gn
RUN \
  apk add --update --virtual .v8-build-dependencies curl g++ gcc glib-dev icu-dev libstdc++ linux-headers make ninja python3 tar xz && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  cd /tmp/v8 && \
  ./tools/dev/v8gen.py x64.release -- \
    binutils_path=\"/usr/bin\" \
    target_os=\"linux\" \
    target_cpu=\"x64\" \
    v8_target_cpu=\"x64\" \
    v8_enable_future=true \
    is_official_build=true \
    is_cfi=false \
    is_clang=false \
    use_custom_libcxx=false \
    use_sysroot=false \
    use_gold=false \
    use_allocator_shim=false \
    treat_warnings_as_errors=false \
    symbol_level=0 \
    strip_debug_info=true \
    v8_monolithic=true \
    v8_use_external_startup_data=false \
    v8_enable_i18n_support=false \
    v8_enable_gdbjit=false \
    v8_static_library=true \
    v8_experimental_extra_library_files=[] \
    v8_extra_library_files=[] && \
  ninja -C out.gn/x64.release -j $(getconf _NPROCESSORS_ONLN) && \
  find /tmp/v8/out.gn/x64.release -name '*.a'

# STEP 4
# Create package archive
ARG v8_version
ENV pkgdir /package
RUN cd /tmp/v8 && \
  install -d ${pkgdir}v8 && \
  install -d ${pkgdir}/v8/lib && \
  install -Dm755 out.gn/x64.release/obj/libv8_monolith.a ${pkgdir}/v8/lib/libv8_monolith.a && \
  install -d ${pkgdir}/v8/include && \
  install -Dm644 include/*.h ${pkgdir}/v8/include && \
  install -d ${pkgdir}/v8/include/cppgc && \
  install -Dm644 include/cppgc/*.h ${pkgdir}/v8/include/cppgc && \
  install -d ${pkgdir}/v8/include/libplatform && \
  install -Dm644 include/libplatform/*.h ${pkgdir}/v8/include/libplatform && \
  install -d ${pkgdir}/v8/lic/ && \
  install -m644 LICENSE* ${pkgdir}/v8/lic/ && \
  tar cfJ /v8-${v8_version}-static.tar.xz -C ${pkgdir} v8
