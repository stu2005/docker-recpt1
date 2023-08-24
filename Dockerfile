# libaribb25
FROM stu2005/libaribb25:latest AS libaribb25

# build recpt1
FROM alpine:latest AS build
COPY --from=libaribb25 /usr/local/ /usr/local/
WORKDIR /src/
RUN set -x \
&&  apk add --no-cache --update-cache git make autoconf automake pcsc-lite-dev libstdc++ libgcc \
&&  git clone https://github.com/stz2012/recpt1 . \
&&  cd recpt1 \
&&  sed -i 's/arib25/aribb25/g' configure.ac \
&&  sed -i 's/ARIB25/ARIBB25/g' decoder.c \
&&  sed -i 's/ARIB25/ARIBB25/g' decoder.h \
&&  sed -i 's/arib25/aribb25/g' decoder.h \
&&  sed -i 's/ARIB25/ARIBB25/g' recpt1.c \
&&  ./autogen.sh \
&&  ./configure --enable-b25 \
&&  make -j$(nproc)

# final image
FROM alpine:latest
COPY --from=build /src/recpt1/recpt1* /src/recpt1/checksignal /build/usr/local/bin/
COPY --from=libaribb25 /usr/local/ /usr/local/
WORKDIR /build/
RUN apk add --no-cache --update-cache pcsc-lite pcsc-lite-libs ccid libstdc++ libgcc
CMD ["/build/usr/local/bin/recpt1"]
