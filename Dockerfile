#FROM bootstrap as builder
FROM innovanon/intel-builder as builder

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

ENV CCP=/opt/intel/oneapi/compiler/latest/linux/bin
ENV CC=$CCP/icx
ENV CXX=$CCP/icpx
ENV FC=$CCP/ifort
#ENV PATH=/opt/intel/oneapi/compiler/latest/linux/bin:$PATH

##ENV CPPFLAGS="-DUSE_ASM $CPPFLAGS"
#ENV   CFLAGS="-march=$ARCH -mtune=$ARCH $CFLAGS"
#
## PGO
##ENV   CFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer  $CFLAGS"
##ENV  LDFLAGS="-fipa-profile -fprofile-reorder-functions -fvpt -pg -fprofile-abs-path -fprofile-dir=/var/cpuminer $LDFLAGS"
##ENV   CFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer  $CFLAGS"
##ENV  LDFLAGS="-pg -fprofile-abs-path -fprofile-generate=/var/cpuminer $LDFLAGS"
#
## Debug
##ENV CPPFLAGS="-DNDEBUG $CPPFLAGS"
#ENV   CFLAGS="-Ofast -g0 $CFLAGS"
#
## Static
##ENV  LDFLAGS="$LDFLAGS -static -static-libgcc -static-libstdc++"
#
## LTO
#ENV   CFLAGS="-fuse-linker-plugin -flto $CFLAGS"
#ENV  LDFLAGS="-fuse-linker-plugin -flto $LDFLAGS"
###ENV   CFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $CFLAGS"
###ENV  LDFLAGS="-fuse-linker-plugin -flto -ffat-lto-objects $LDFLAGS"
#
## Dead Code Strip
#ENV   CFLAGS="-ffunction-sections -fdata-sections $CFLAGS"
#ENV  LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"
###ENV  LDFLAGS="-Wl,-Bsymbolic -Wl,--gc-sections $LDFLAGS"
#
## Optimize
##ENV   CLANGFLAGS="-ffast-math -fassociative-math -freciprocal-math -fmerge-all-constants $CFLAGS"
##ENV       CFLAGS="-fipa-pta -floop-nest-optimize -fgraphite-identity -floop-parallelize-all $CLANGFLAGS"
#ENV CFLAGS="-fmerge-all-constants $CFLAGS"
#ENV CFLAGS="$CFLAGS -fPIE -pie"
#ENV CXXFLAGS="$CXXFLAGS -fPIE -pie"
#ENV LDFLAGS="$LDFLAGS -fPIE -pie"

#ENV CLANGXXFLAGS="$CLANGFLAGS $CXXFLAGS"
#ENV CXXFLAGS="$CFLAGS $CXXFLAGS"

WORKDIR /tmp

#COPY    ./libevent.sh    ./
#RUN     ./libevent.sh  1

#COPY    ./tor.sh         ./
#RUN     ./tor.sh       1

#COPY    ./libuv.sh       ./
#RUN     ./libuv.sh     1

#COPY    ./hwloc.sh       ./
#RUN     ./hwloc.sh     1

#RUN command -v $CC
#RUN command -v $CXX
#RUN command -v $FC

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

