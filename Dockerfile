ARG DEBIAN_FRONTEND=noninteractive \
    VSCODE_VERSION \
    TOFU_VERSION

FROM debian:12-slim

ARG VSCODE_VERSION \
    TOFU_VERSION

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
    apt-get update && apt-get install -y curl sudo git gnupg; \
    # tofu
    curl -fsSL https://get.opentofu.org/opentofu.gpg | tee /etc/apt/keyrings/opentofu.gpg >/dev/null; \
    curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null; \
    echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | tee /etc/apt/sources.list.d/opentofu.list > /dev/null; \
    apt-get update; \
    apt-get install -y tofu=${TOFU_VERSION}; \
    # code-server
    curl -fsSL https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_${ARCH}.deb -o /tmp/code-server.deb; \
    apt-get install -y /tmp/code-server.deb; \
    # cleaning
    apt-get remove -y gnupg; \
    rm -rf /tmp/* /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg /etc/apt/sources.list.d/opentofu.list /var/lib/apt/lists/*; \
    apt-get autoremove -y && apt-get clean;

# Create debian user
RUN set -ex; \
    adduser --disabled-password --gecos '' debian; \
    echo "debian ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/debian;

USER debian
WORKDIR /home/debian

ENTRYPOINT ["/usr/bin/code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080"]
