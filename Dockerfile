FROM ubuntu:18.04
ARG CCACHE_VER=v4.5.1
ARG MACHINE_NAME=vat-aosp-docker

# Install required packages
RUN apt-get update \
 && apt-get -y install git-core gnupg flex bison build-essential zip curl \
                 zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 \
                 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev \
                 libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig

# Install jdk-8
RUN curl -o jdk8.tgz https://android.googlesource.com/platform/prebuilts/jdk/jdk8/+archive/master.tar.gz \
 && tar -zxf jdk8.tgz linux-x86 \
 && mkdir -p /usr/lib/jvm/java-8-openjdk-amd64 \
 && mv linux-x86 /usr/lib/jvm/java-8-openjdk-amd64 \
 && rm -rf jdk8.tgz

ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

# Build and install newer version of ccache
RUN apt-get -y install cmake libzstd-dev
RUN cd /tmp && git clone --depth 1 --branch $CCACHE_VER https://github.com/ccache/ccache.git
RUN cd /tmp/ccache \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DHIREDIS_FROM_INTERNET=ON .. \
 && make \
 && make install

# Clean up
RUN apt-get -y remove cmake \
 && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set host name
RUN echo "$MACHINE_NAME" > /etc/hostname

# Copy entrypoint file
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod o+x /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]