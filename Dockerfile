FROM intel/oneapi-basekit:devel-ubuntu18.04 as bootstrap

ARG  DEBIAN_FRONTEND=noninteractive
ARG  DEBCONF_NONINTERACTIVE_SEEN=true

ARG  TZ=Etc/UTC
ENV  TZ $TZ
ARG  LANG=C.UTF-8
ENV  LANG $LANG
ARG  LC_ALL=C.UTF-8
ENV  LC_ALL $LC_ALL

ARG EXT=tgz

COPY       ./stage-0/           /tmp/stage-0
COPY       ./stage-1/           /tmp/stage-1
COPY       ./stage-2            /tmp/stage-2
COPY       ./stage-3            /tmp/stage-3
COPY       ./stage-4            /tmp/stage-4
RUN ( cd                        /tmp/stage-0      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-0      \
 && chmod -v 1777               /tmp              \
 && apt update && apt install apt-transport-https \
 && apt-key add < /tmp/key.asc                    \
 && rm    -v      /tmp/key.asc                    \
 && apt update                                    \
 && apt install tor deb.torproject.org-keyring    \
 \
 && ( cd                        /tmp/stage-1      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-1      \
 && chmod -v 1777               /tmp              \
 \
 && ( cd                        /tmp/stage-2      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-2      \
 && chmod -v 1777               /tmp              \
 && sed -i 's@^ORPort@#&@'      /etc/tor/torrc    \
 && echo 'SOCKSPolicy accept 127.0.0.1' >> /etc/tor/torrc \
 && echo 'SOCKSPolicy reject *'         >> /etc/tor/torrc \
 && tor --verify-config

SHELL ["/bin/bash", "-l", "-c"]
RUN sleep 127           \
 && apt install -y      \
      binutils-dev      \
      clang             \
      libgmp-dev        \
      libisl-dev        \
      libmpc-dev        \
      libmpfr-dev       \
      llvm              \
      pbzip2            \
      pigz              \
      pixz              \
      polygen           \
      wget              \
 && update-alternatives --force --install          \
      $(command -v gzip   || echo /usr/bin/gzip)   \
      gzip   $(command -v pigz)   200              \
 && update-alternatives --force --install          \
      $(command -v gunzip || echo /usr/bin/gunzip) \
      gunzip $(command -v unpigz) 200              \
 && update-alternatives --force --install          \
      $(command -v bzip2  || echo /usr/bin/bzip2)  \
      bzip2  $(command -v pbzip2) 200              \
 && update-alternatives --force --install          \
      $(command -v xz     || echo /usr/bin/xz)     \
      xz     $(command -v pixz)   200              \
 && apt full-upgrade                               \
 && clean.sh

#COPY          ./stage-3.$EXT    /tmp/
RUN ( cd                        /tmp/stage-3       \
 &&   tar pcf - .                                 ) \
  | tar pxf - -C /                                  \
 && rm -rf                      /tmp/stage-3       \
 && chmod -v 1777               /tmp               \
 && apt update                                     \
 && [ -x            /tmp/dpkg.list ]               \
 && apt install   $(/tmp/dpkg.list)                \
 && cd /usr/local/bin                              \
 && shc -rUf     support-wrapper                   \
 && rm    -v     support-wrapper.x.c            \
 && chmod -v 0555 support-wrapper.x                \
 && apt-mark auto $(/tmp/dpkg.list)                \
 && rm -v           /tmp/dpkg.list                 \
 && clean.sh
 #&& rm    -v     support-wrapper{,.x.c}            \

#FROM base as base-1
# TODO
#COPY --from=support /usr/local/bin/support-wrapper.x \
#                    /usr/local/bin/support-wrapper
#COPY --from=support /usr/local/bin/support-wrapper \
#                    /usr/local/bin/support-wrapper
#SHELL ["/bin/bash", "-c"]

#FROM base-1 as lfs-bare
#ARG EXT=tgz
ARG LFS=/mnt/lfs
ARG TEST=
#SHELL ["/bin/bash", "-l", "-c"]
#COPY          ./stage-4.$EXT    /tmp/
RUN ( cd                        /tmp/stage-4       \
 &&   tar pcf - .                                 ) \
  | tar pxf - -C /                                  \
 && rm -rf                      /tmp/stage-4       \
 && chmod -v 1777               /tmp                \
 && apt update                                      \
 && [ -x           /tmp/dpkg.list ]                 \
 && apt install  $(/tmp/dpkg.list)                  \
 && rm    -v       /tmp/dpkg.list                  \
 && clean.sh                                       \
 && mkdir -vp         $LFS/sources                  \
 && chmod -v a+wt     $LFS/sources                  \
 && groupadd lfs                                    \
 && useradd -s /bin/bash -g lfs -G debian-tor -m -k /dev/null lfs \
 && chown -v  lfs:lfs $LFS/sources                  \
 && chown -vR lfs:lfs /home/lfs                     \
 && exec true || exec false
 #&& chown  -R lfs:lfs /var/lib/tor

#FROM lfs-bare as test
#USER lfs
#RUN sleep 31 \
# && tsocks wget -O- https://3g2upl4pq6kufc4m.onion
#
#FROM lfs-bare as final

#FROM lfs-bare as squash-tmp
#USER root
#RUN  squash.sh
#FROM scratch as squash
#ADD --from=squash-tmp /tmp/final.tar /

#FROM scratch as squash
#COPY --from=lfs-bare / /
#
#FROM squash as test
#USER lfs
#RUN tor --verify-config
#USER root
#RUN apt update
#RUN apt full-upgrade
#
#FROM squash as final

FROM bootstrap as builder

ARG CPPFLAGS
ARG   CFLAGS
ARG CXXFLAGS
ARG  LDFLAGS

#ENV CHOST=x86_64-linux-gnu

ENV CPPFLAGS="$CPPFLAGS"
ENV   CFLAGS="$CFLAGS"
ENV CXXFLAGS="$CXXFLAGS"
ENV  LDFLAGS="$LDFLAGS"

#ENV PREFIX=/usr/local
ENV PREFIX=/opt/cpuminer

ARG ARCH=native
ENV ARCH="$ARCH"

#ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"

# PGO
#ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer  $CFLAGS"
#ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer $LDFLAGS"
#ENV   CFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer  $CFLAGS"
#ENV  LDFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer $LDFLAGS"

# Debug
#ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"
ENV   CFLAGS="-Ofast -g0 $CFLAGS"

# Static
#ENV  LDFLAGS="$LDFLAGS -static -static-libgcc -static-libstdc++"

# LTO
ENV   CFLAGS="-fuse-linker-plugin -flto $CFLAGS"
ENV  LDFLAGS="-fuse-linker-plugin -flto $LDFLAGS"
##ENV   CFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $CFLAGS"
##ENV  LDFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $LDFLAGS"

# Dead Code Strip
ENV   CFLAGS="-ffunction-sections -fdata-sections $CFLAGS"
ENV  LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"
##ENV  LDFLAGS="-Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"

# Optimize
#ENV   CLANGFLAGS="-ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS"
#ENV       CFLAGS="-fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CLANGFLAGS"
ENV CFLAGS="-fmerge-all-constants $CFLAGS"

#ENV CLANGXXFLAGS="$CLANGFLAGS $CXXFLAGS"
ENV CXXFLAGS="$CFLAGS $CXXFLAGS"

WORKDIR /tmp

#COPY    ./libevent.sh    ./
#RUN     ./libevent.sh  1

#COPY    ./tor.sh         ./
#RUN     ./tor.sh       1

#COPY    ./libuv.sh       ./
#RUN     ./libuv.sh     1

#COPY    ./hwloc.sh       ./
#RUN     ./hwloc.sh     1

COPY    ./llvm.grm               \
        ./fingerprint.sh         \
        ./xmrig.sh               \
        ./donate.h.sed           \
        ./DonateStrategy.cpp.sed \
        ./Config_default.h       \
                                 ./
RUN     ./fingerprint.sh \
 &&     ./xmrig.sh     1

#FROM scratch as squash
#COPY --from=builder / /
#RUN chown -R tor:tor /var/lib/tor
#SHELL ["/usr/bin/bash", "-l", "-c"]
#ARG TEST
#
#FROM squash as test
#ARG TEST
#RUN tor --verify-config \
# && sleep 127           \
# && xbps-install -S     \
# && exec true || exec false
#
#FROM squash as final
#VOLUME /var/cpuminer
#ENTRYPOINT []

VOLUME /var/cpuminer
ENTRYPOINT ["/bin/bash", "-l", "-c", "set -vx && for k in $(seq 3) ; do sleep 333 ; done"]

#COPY    ./profile.sh ./
##VOLUME /var/cpuminer
##ENTRYPOINT ["/tmp/profile.sh"]
#RUN ./profile.sh
#
#
#COPY    ./profile.sh ./
#SHELL      ["/bin/sh", "-c"]
#ENTRYPOINT ["/tmp/profile.sh"]
#
#

