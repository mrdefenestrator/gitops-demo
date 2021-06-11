FROM fluxcd/flux-cli:v0.14.2

WORKDIR /app

RUN apk add --no-cache \
  bash

RUN \
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
  sudo mv /tmp/eksctl /usr/local/bin && \
  eksctl version

COPY scripts ./

RUN export PATH="${PATH}:/app/scripts"

ENTRYPOINT [ "/bin/bash" ]
