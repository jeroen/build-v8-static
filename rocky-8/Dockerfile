FROM rockylinux/rockylinux:8

ARG NODE_VERSION=22.18.0
ARG BUILD_VERSION=bca39698b291b392f0b4336857caf929c603ada3
ARG GN_VERSION=59c4bb920542ee903ee1df39097ae024e2e8226f

ENV GYP_GENERATORS=ninja
ENV pkgdir=/package

RUN \
	dnf upgrade -y && \
	dnf install -y dnf-plugins-core epel-release && \
	dnf config-manager --set-enabled powertools &&\
	dnf install -y python38 xz git clang gcc-c++ bzip2 libatomic glib2-devel ninja-build && \
	ln -s /usr/bin/python3 /usr/bin/python

RUN \
  git clone https://gn.googlesource.com/gn && \
  cd gn && \
  git checkout ${GN_VERSION} && \
  python3 build/gen.py && \
  ninja -C out && \
  cp out/gn /usr/local/bin/gn

RUN \
  curl -sSL https://github.com/nodejs/node/archive/refs/tags/v${NODE_VERSION}.tar.gz -o node.tar.gz && \
  mkdir -p /v8 &&\
  tar xf node.tar.gz -C /v8 --strip-components=3 node-22.18.0/deps/v8

RUN \
  git clone https://chromium.googlesource.com/chromium/src/build.git /build &&\
  git -C /build checkout ${BUILD_VERSION} &&\
  rm -Rf /v8/build &&\
  ln -sf /build /v8/build

RUN \
  echo "checkout_google_benchmark = false" > /v8/build/config/gclient_args.gni

RUN cd /v8 &&\
  gn gen v8.static -vv --fail-on-unused-args \
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
            use_sysroot=false'

RUN cd /v8 && ninja -C v8.static -j2 "v8_monolith" "d8"

RUN	cd /v8 &&\
  install -d ${pkgdir}v8 && \
  install -d ${pkgdir}/v8/lib && \
  install -Dm755 v8.static/obj/libv8_monolith.a ${pkgdir}/v8/lib/libv8_monolith.a && \
  install -d ${pkgdir}/v8/include && \
  install -Dm644 include/*.h ${pkgdir}/v8/include && \
  install -d ${pkgdir}/v8/include/cppgc && \
  install -Dm644 include/cppgc/*.h ${pkgdir}/v8/include/cppgc && \
  install -d ${pkgdir}/v8/include/libplatform && \
  install -Dm644 include/libplatform/*.h ${pkgdir}/v8/include/libplatform && \
  install -d ${pkgdir}/v8/lic/ && \
  install -m644 LICENSE* ${pkgdir}/v8/lic/ && \
  tar cfJ /v8-${v8_version}-static.tar.xz -C ${pkgdir} v8
