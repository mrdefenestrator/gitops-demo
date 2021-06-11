FROM fluxcd/flux-cli:v0.14.2

WORKDIR /app

RUN apk add --no-cache \
    bash

COPY scripts ./

RUN export PATH="${PATH}:/app/scripts"

ENTRYPOINT [ "/bin/bash" ]
