FROM python:alpine

RUN apk add --no-cache \
    build-base \
    git \
    git-fast-import \
    openssh \
    gcc \
    musl-dev \
    jpeg-dev \
    zlib-dev \
    libffi-dev \
    cairo-dev \
    pango-dev \
    gdk-pixbuf-dev \
    ttf-ubuntu-font-family \
    msttcorefonts-installer \
    fontconfig && \
    update-ms-fonts && \
    fc-cache -f

RUN pip install --no-cache-dir mkdocs mkdocs-with-pdf mkdocs-material

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]