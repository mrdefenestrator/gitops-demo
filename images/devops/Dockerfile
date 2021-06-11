FROM fluxcd/flux-cli:v0.14.2

WORKDIR /app

RUN apk add --no-cache \
    bash

RUN \
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64 && \
  chmod +x ./kind && \
  export PATH="${PATH}:$(pwd)"

COPY scripts ./

RUN export PATH="${PATH}:/app/scripts"

ENTRYPOINT [ "/bin/bash" ]
