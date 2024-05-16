FROM debian:stable-slim

# Install necessary packages
RUN apt update && apt -yq install rsync openssh-client openvpn iproute2

# Label
LABEL "com.github.actions.name"="Deploy with rsync"
LABEL "maintainer"="sparkout <saranraj.st0078@sparkouttech.com>"

# Copy entrypoint script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
