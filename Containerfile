FROM scratch AS ctx
COPY build_files /build

FROM ghcr.io/zirconium-dev/zirconium:latest

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/00-mobilise.sh

RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint
