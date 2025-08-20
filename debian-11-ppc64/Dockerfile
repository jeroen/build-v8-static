# This container only works under linux/ppc64le emulation
# docker build --platform linux/ppc64le . --progress=plain
# This is too slow for CI, have to build locally.

ARG v8_version=11.9.169.7
ARG GN_COMMIT=cc28efe62ef0c2fb32455f414a29c4a55bb7fbc4

FROM ppc64le/debian:11
ENV GYP_GENERATORS ninja
ENV pkgdir /package
ARG GN_COMMIT
ARG v8_version

RUN \
  sed -i.bak 's@http://deb.debian.org@http://archive.debian.org@g' /etc/apt/sources.list && \
  apt-get update || true && \
  apt-get install -y ninja-build clang curl python3 xz-utils git g++ pkg-config libglib2.0-dev && \
  git clone https://gn.googlesource.com/gn && \
  cd gn && \
  git checkout ${GN_COMMIT} && \
  python3 build/gen.py && \
  ninja -C out && \
  cp out/gn /usr/local/bin/gn


RUN \
  curl -sSL https://github.com/v8/v8/archive/${v8_version}/v8-${v8_version}.tar.gz -o v8.tar.gz && \
  mkdir -p /v8 &&\
  tar xf v8.tar.gz -C /v8 --strip-components=1

RUN \
  git clone https://chromium.googlesource.com/chromium/src/build.git /build &&\
  git -C /build checkout e14e0cc3b60c6ba8901741da3f9c18b7fa983880 &&\
  rm -Rf /v8/build &&\
  ln -sf /build /v8/build

RUN \
  git clone https://chromium.googlesource.com/chromium/src/third_party/abseil-cpp.git /abseil-cpp &&\
  git -C /abseil-cpp checkout 7affa303ea4ebf4d4de65b3f20f230c7bb16a2ed &&\
  ln -sf /abseil-cpp /v8/third_party/abseil-cpp

RUN \
  git clone https://chromium.googlesource.com/chromium/src/third_party/zlib.git /zlib &&\
  git -C /zlib checkout f5fd0ad2663e239a31184ad4c9919991dda16f46 &&\
  ln -sf /zlib /v8/third_party/zlib

RUN \
  git clone https://chromium.googlesource.com/chromium/src/base/trace_event/common.git /common &&\
  git -C /common checkout 147f65333c38ddd1ebf554e89965c243c8ce50b &&\
  mkdir -p /v8/base/trace_event &&\
  ln -sf /common /v8/base/trace_event

RUN \
  git clone https://chromium.googlesource.com/external/github.com/google/googletest.git /googletest &&\
  git -C /googletest checkout af29db7ec28d6df1c7f0f745186884091e602e07 &&\
  mkdir -p /v8/third_party/googletest/src &&\
  cp -Rf /googletest/* /v8/third_party/googletest/src/

RUN \
  git clone https://chromium.googlesource.com/chromium/src/third_party/jinja2.git /jinja2 &&\
  git -C /jinja2 checkout 515dd10de9bf63040045902a4a310d2ba25213a0 &&\
  ln -sf /jinja2 /v8/third_party/jinja2

RUN \
  git clone https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git /markupsafe &&\
  git -C /markupsafe checkout 006709ba3ed87660a17bd4548c45663628f5ed85 &&\
  ln -sf /markupsafe /v8/third_party/markupsafe

RUN \
  echo "declare_args() {\n  checkout_google_benchmark = false\n}" > /v8/build/config/gclient_args.gni

RUN cd /v8 &&\
  sed -i.bak 's|tuple()|tuple{}|g' src/compiler/turboshaft/operations.h &&\
  gn gen ppc64.static -vv --fail-on-unused-args \
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
            target_cpu="ppc64" \
            v8_target_cpu="ppc64"'

RUN cd /v8 && ninja -C ppc64.static -j2 "v8_monolith" "d8"

RUN	cd /v8 &&\
  install -d ${pkgdir}v8 && \
  install -d ${pkgdir}/v8/lib && \
  install -Dm755 ppc64.static/obj/libv8_monolith.a ${pkgdir}/v8/lib/libv8_monolith.a && \
  install -d ${pkgdir}/v8/include && \
  install -Dm644 include/*.h ${pkgdir}/v8/include && \
  install -d ${pkgdir}/v8/include/cppgc && \
  install -Dm644 include/cppgc/*.h ${pkgdir}/v8/include/cppgc && \
  install -d ${pkgdir}/v8/include/libplatform && \
  install -Dm644 include/libplatform/*.h ${pkgdir}/v8/include/libplatform && \
  install -d ${pkgdir}/v8/lic/ && \
  install -m644 LICENSE* ${pkgdir}/v8/lic/ && \
  tar cfJ /v8-${v8_version}-static.tar.xz -C ${pkgdir} v8
