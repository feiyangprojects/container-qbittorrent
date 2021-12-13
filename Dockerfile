FROM alpine:latest AS builder

ARG VERSION
ARG LIBTORRENT_VERSION

RUN set -ex && apk add boost-dev cmake gcc g++ ninja qt5-qtbase-dev qt5-qtsvg-dev qt5-qttools-dev \
    &&  wget -O - "https://github.com/arvidn/libtorrent/releases/download/v$LIBTORRENT_VERSION/libtorrent-rasterbar-$LIBTORRENT_VERSION.tar.gz" | tar zxf - \
    &&  wget -O - "https://github.com/c0re100/qBittorrent-Enhanced-Edition/archive/$VERSION.tar.gz" | tar zxf -
RUN set -ex && cd /libtorrent-*/ \
    && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib \
    && cmake --build build --parallel $(nproc) && cmake --install build && cd /qBittorrent-Enhanced-Edition-*/ \
    && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DGUI=OFF -DSTACKTRACE=OFF \
    && cmake --build build --parallel $(nproc) && cmake --install build
RUN set -ex && strip /usr/bin/qbittorrent-nox /usr/lib/libtorrent-rasterbar.* \
    && find /usr/lib -regex '/usr/lib/libtorrent-rasterbar.*[[:digit:]]' > /usr/lib/libtorrent-rasterbar.txt


FROM python:alpine

ENV PORT_BT 6881
ENV PORT_UI 8080
ENV TRACKERS https://cdn.jsdelivr.net/gh/ngosang/trackerslist/trackers_all.txt
ENV UPLOAD_RATIO 5
ENV UPLOAD_SPEED 0

LABEL org.opencontainers.image.authors "Fei Yang <projects@feiyang.moe>"
LABEL org.opencontainers.image.url https://dev.azure.com/fei1yang/containers
LABEL org.opencontainers.image.documentation https://dev.azure.com/fei1yang/containers/_git/qbittorrent?path=/README.md
LABEL org.opencontainers.image.source https://dev.azure.com/fei1yang/containers/_git/qbittorrent
LABEL org.opencontainers.image.vendor "FeiYang Labs"
LABEL org.opencontainers.image.licenses GPL-3.0-only
LABEL org.opencontainers.image.title qBittorrent-EE
LABEL org.opencontainers.image.description "Minimalistic qBittorrent Enhanced Edition container image based on Apline linux."

RUN set -ex && apk add --no-cache qt5-qtbase qt5-qtbase-sqlite
RUN set -ex && mkdir -p /config /data

COPY init.py /init.py
COPY --from=builder /usr/bin/qbittorrent-nox /usr/bin/qbittorrent-nox
COPY --from=builder /usr/lib/libtorrent-rasterbar.so /usr/lib/libtorrent-rasterbar.so
COPY --from=builder /usr/lib/libtorrent-rasterbar.txt /usr/lib/libtorrent-rasterbar.txt

RUN set -ex && for i in $(cat /usr/lib/libtorrent-rasterbar.txt); do ln -s /usr/lib/libtorrent-rasterbar.so "$i"; done 

VOLUME ["/config", "/data"]

CMD ["/usr/local/bin/python3", "/init.py"]
