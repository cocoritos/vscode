ARG DEBIAN_FRONTEND=noninteractive
ARG CODE_VERSION

FROM debian:12-slim

ENV CODE_VERSION=${CODE_VERSION}

# Install code-server
RUN set -ex; \
    # set ARCH dynamically
    case "$(uname -m)" in \
        aarch64) ARCH=arm64 ;; \
        x86_64) ARCH=amd64 ;; \
        *) echo "Unsupported architecture"; exit 1 ;; \
    esac; \
    echo "Building for architecture: $ARCH"; \
    # base packages
    apt-get update && apt-get install -y curl sudo; \
    # code-server
    curl -fsSL https://github.com/coder/code-server/releases/download/v${CODE_VERSION}/code-server_${CODE_VERSION}_${ARCH}.deb -o /tmp/code-server.deb; \
    apt-get install -y /tmp/code-server.deb; \
    # cleaning
    rm -rf /tmp/*; \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*;

# Create debian user
RUN set -ex; \
    adduser --disabled-password --gecos '' debian; \
    echo "debian ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/debian;

USER debian
WORKDIR /home/debian

ENTRYPOINT ["/usr/bin/code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080"]
