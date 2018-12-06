FROM alpine:3.8

# add user and group for consistent id assigned
RUN addgroup -S redis && adduser -S -G redis redis

## depe base
RUN apk add --no-cache \
    # grab su-exec for easy step-down from root
    'su-exec>=0.2' \
    # add tzdata for https://github.com/docker-library/redis/issues/138
    tzdata

RUN mkdir -p /usr/src/redis
RUN mkdir -p /usr/src/redis/modules


COPY build/redis/modules/* /usr/src/redis/modules/
RUN ls /usr/src/redis/modules/

## depe build
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
    coreutils \
    gcc \
    jemalloc-dev \
    linux-headers \
    make \
    musl-dev


## get source
RUN set -ex; \
    wget -O redis.tar.gz http://download.redis.io/releases/redis-5.0.2.tar.gz; \
    tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
    rm redis.tar.gz

#prepare
RUN set -ex; \
    grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' /usr/src/redis/src/server.h; \
    sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' /usr/src/redis/src/server.h; \
    grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' /usr/src/redis/src/server.h;

# make
RUN set -ex; \
    make -C /usr/src/redis -j 8; \
    make -C /usr/src/redis install;

# install
RUN \
    REDIS_PORT=6379 \
    REDIS_CONFIG_FILE=/etc/redis/6379.conf \
    REDIS_LOG_FILE=/var/log/redis_6379.log \
    REDIS_DATA_DIR=/var/lib/redis/6379 \
    REDIS_EXECUTABLE=`command -v redis-server` \
    /usr/src/redis/utils/install_server.sh

#WORKDIR /build

#COPY build/redis/core /usr/src/redis

# COPY build/redis/core/core.tar.gz ./core/
#RUN mkdir -p /usr/src/redis

#RUN pwd
#RUN ls

# dirs
# RUN mkdir ~/conf && chown redis:redis ~/conf
# RUN mkdir ~/logs && chown redis:redis ~/logs
# RUN mkdir ~/storage && chown redis:redis ~/storage
# RUN mkdir ~/scripts && chown redis:redis ~/scripts

# FROM redis:5.0.2 as redis

# FROM redislabs/redisearch:1.4.2 as redisearch
# FROM redislabs/redisml:latest as redisml
# FROM redislabs/rejson:latest as rejson
# FROM redislabs/redisgraph:1.0.2 as redisgraph
# FROM redislabs/rebloom:latest as rebloom

# ENV LIBDIR /usr/lib/redis/modules


#RUN \
#    wget -O redis.tar.gz http://download.redis.io/releases/redis-5.0.2.tar.gz; \
#    tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
#    cd /usr/src/redis && \
#    pwd && \
#    ls && \
#    pwd && ls && \
#    grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' /usr/src/redis/src/server.h; \
#    sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' /usr/src/redis/src/server.h; \
#    grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' /usr/src/redis/src/server.h; \
#    make -C /usr/src/redis -j 8; \
#    make -C /usr/src/redis install; \
#    REDIS_PORT=6379 REDIS_CONFIG_FILE=/etc/redis/6379.conf REDIS_LOG_FILE=/var/log/redis_6379.log REDIS_DATA_DIR=/var/lib/redis/6379 REDIS_EXECUTABLE=`command -v redis-server` ./utils/install_server.sh \
# WORKDIR /data


# Define mountable directories.
# VOLUME ["/data"]

# Define working directory.
# WORKDIR /data

# Define default command.
CMD ["redis-server", "/etc/redis/redis.conf"]

# Expose ports.
EXPOSE 6379


# RUN set -ex;\
#    mkdir -p ${LIBDIR};
# COPY --from=redisearch ${LIBDIR}/redisearch.so ${LIBDIR}
# COPY --from=redisml ${LIBDIR}/redis-ml.so ${LIBDIR}
# COPY --from=rejson ${LIBDIR}/rejson.so ${LIBDIR}
# COPY --from=redisgraph ${LIBDIR}/redisgraph.so ${LIBDIR}
# COPY --from=rebloom ${LIBDIR}/rebloom.so ${LIBDIR}

# ENTRYPOINT ["redis-server"]
# CMD ["--loadmodule", "/usr/lib/redis/modules/redisearch.so", \
    # "--loadmodule", "/usr/lib/redis/modules/redis-ml.so", \
#     "--loadmodule", "/usr/lib/redis/modules/rejson.so", \
#     "--loadmodule", "/usr/lib/redis/modules/redisgraph.so", \
#     "--loadmodule", "/usr/lib/redis/modules/rebloom.so"]

ENTRYPOINT ["redis-server"]
CMD [ \
    # "--loadmodule", "/usr/src/redis/modules/redisearch.so", \
    "--loadmodule", "/usr/src/redis/modules/redis-ml.so", \
    "--loadmodule", "/usr/src/redis/modules/rejson.so" \
    ]

# EXPOSE 6379
# CMD ["redis-server"]
