# Start with the base Ubuntu image
FROM ubuntu:22.04

# Set the timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary dependencies
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    software-properties-common sudo curl wget make pkg-config locales git \
    gcc-11 g++-11 openssl libssl-dev libjsoncpp-dev uuid-dev \
    zlib1g-dev libc-ares-dev postgresql-server-dev-all \
    libmariadb-dev libsqlite3-dev libhiredis-dev cmake \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# Set environment variables for localization and compilers
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CC=gcc-11 \
    CXX=g++-11 \
    AR=gcc-ar-11 \
    RANLIB=gcc-ranlib-11 \
    IROOT=/install

# Clone and build Drogon
ENV DROGON_ROOT="$IROOT/drogon"
RUN git clone https://github.com/drogonframework/drogon $DROGON_ROOT && \
    cd $DROGON_ROOT && git submodule update --init && \
    mkdir build && cd build && cmake .. && make -j$(nproc) && make install

# Copy source code for your application
WORKDIR /app
COPY . .

# Pull submodules for your application
RUN git submodule update --init --recursive

# Create build directory and build the project
RUN mkdir -p build && cd build && cmake .. && make -j$(nproc)

# Expose application port
EXPOSE 3000

# Set CMD to the actual binary
CMD ["./build/org_chart"]
