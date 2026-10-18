FROM debian:trixie-slim
ENV DEBIAN_FRONTEND=noninteractive

COPY fix_source.sh /tmp/fix_source.sh
RUN chmod +x /tmp/fix_source.sh && /tmp/fix_source.sh