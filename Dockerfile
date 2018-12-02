FROM alpine:3.8

# add user and group for consistent id assigned
RUN addgroup -S redis && adduser -S -G redis redis

WORKDIR /redis

COPY ./build/redis/

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

RUN \
    cd build/redis/core && \
    tar xzf core.tar.gz && \
    cd r*/ && \
    REDIS_PORT=6379 REDIS_CONFIG_FILE=/etc/redis/6379.conf REDIS_LOG_FILE=/var/log/redis_6379.log REDIS_DATA_DIR=/var/lib/redis/6379 REDIS_EXECUTABLE=`command -v redis-server` ./utils/install_server.sh \
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
#     "--loadmodule", "/usr/lib/redis/modules/redis-ml.so", \
#     "--loadmodule", "/usr/lib/redis/modules/rejson.so", \
#     "--loadmodule", "/usr/lib/redis/modules/redisgraph.so", \
#     "--loadmodule", "/usr/lib/redis/modules/rebloom.so"]

EXPOSE 6379
CMD ["redis-server"]
