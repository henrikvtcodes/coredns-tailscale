FROM golang:1.23.2-alpine3.19 AS build

WORKDIR /go/src/coredns

RUN apk add git make && \
    git clone --depth 1 --branch=v1.11.3 https://github.com/coredns/coredns /go/src/coredns && cd plugin

COPY . /go/src/coredns/plugin/tailscale

RUN cd plugin && \
    rm tailscale/go.mod tailscale/go.sum &&  \
    sed -i s/forward:forward/tailscale:tailscale\\nforward:forward/ /go/src/coredns/plugin.cfg && \
    cat /go/src/coredns/plugin.cfg && \
    cd .. && \
    make check && \
    go build

FROM alpine:3.19.1
RUN apk add --no-cache ca-certificates

COPY --from=build /go/src/coredns/coredns /
COPY Corefile run.sh /

ENTRYPOINT ["/run.sh"]
