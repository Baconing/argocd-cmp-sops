FROM quay.io/argoproj/argocd:v3.4.0

USER root

ARG SOPS_VERSION=v3.13.2

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        age \
        findutils \
        curl \
        ca-certificates && \
    curl -Lo /usr/local/bin/sops \
        https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64 && \
    chmod +x /usr/local/bin/sops && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install CMP plugin configuration
RUN mkdir -p /home/argocd/cmp-server/config

COPY plugin.yaml /home/argocd/cmp-server/config/plugin.yaml

RUN chown -R 999:999 /home/argocd/cmp-server/config

ENV SOPS_AGE_KEY_FILE=/keys/keys.txt

USER 999

ENTRYPOINT ["/var/run/argocd/argocd-cmp-server"]