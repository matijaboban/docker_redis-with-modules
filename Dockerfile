FROM redislabs/redisearch:latest as redisearch
FROM redislabs/rebloom:latest as rebloom
FROM redis:5.0.2-30 as redis

ENV LIBDIR /usr/lib/redis/modules

WORKDIR /data

RUN set -ex;\
    mkdir -p ${LIBDIR};
COPY --from=redisearch ${LIBDIR}/redisearch.so ${LIBDIR}
COPY --from=rebloom ${LIBDIR}/rebloom.so ${LIBDIR}

ENTRYPOINT ["redis-server"]
CMD ["--loadmodule", "/usr/lib/redis/modules/redisearch.so", \
    "--loadmodule", "/usr/lib/redis/modules/rebloom.so"]
