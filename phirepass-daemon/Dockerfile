FROM dimitrmok/phirepass-daemon:latest AS binary

# Stage 2: runtime image (glibc-based for compatibility)
FROM debian:trixie-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
	 ca-certificates \
	 libstdc++6 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY rootfs /app
COPY --from=binary /app/daemon /app/daemon
COPY run.sh /app/run.sh

RUN chmod +x /app/run.sh

ENV RUST_LOG=info

EXPOSE 8080

CMD [ "/app/run.sh" ]
