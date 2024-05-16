FROM debian:stable-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -yq openvpn rsync ssh-client && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Set execute permissions for the entrypoint script
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
