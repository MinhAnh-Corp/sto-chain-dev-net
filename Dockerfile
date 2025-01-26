FROM golang:1.23-alpine AS builder
RUN apk add --no-cache make gcc musl-dev git
WORKDIR /app
COPY . .
RUN make install



FROM alpine:latest
RUN apk add --no-cache jq
COPY --from=builder /go/bin/stochaind /usr/local/bin/stochaind
WORKDIR /root
EXPOSE 26656 26657 1317
