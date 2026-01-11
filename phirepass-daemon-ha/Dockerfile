FROM dimitrmok/phirepass-daemon:latest AS binary

# Stage 2: runtime image (glibc-based for compatibility)
FROM debian:trixie-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
	 ca-certificates \
	 libstdc++6 \
 && rm -rf /var/lib/apt/lists/*

COPY rootfs /
COPY --from=binary /app/daemon /app/daemon

RUN chmod +x /app/run.sh

WORKDIR /app

ENV RUST_LOG=info

EXPOSE 8080

CMD [ "/app/run.sh" ]
