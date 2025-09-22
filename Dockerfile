ARG BASE_IMAGE=alpine:3.22

##### Custom base images with Go 1.24.6 #####

FROM golang:1.24.6-alpine3.22 AS builder

ARG DOCKERIZE_VERSION=v0.9.5
RUN go install github.com/jwilder/dockerize@${DOCKERIZE_VERSION}
RUN cp $(which dockerize) /usr/local/bin/dockerize

##### base-server target #####
FROM ${BASE_IMAGE} AS base-server

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl

COPY --from=builder /usr/local/bin/dockerize /usr/local/bin

SHELL ["/bin/bash", "-c"]

##### base-builder target #####
FROM golang:1.24.6-alpine3.22 AS base-builder

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    make \
    git \
    curl

##### Server builder stage #####

FROM base-builder AS server-builder

WORKDIR /home/server-builder

COPY go.mod go.sum ./
RUN go mod download

COPY . ./

RUN make build-server

##### UI server #####

FROM base-server AS ui-server

ARG TEMPORAL_CLOUD_UI="false"

WORKDIR /home/ui-server

RUN addgroup -g 1000 temporal
RUN adduser -u 1000 -G temporal -D temporal
RUN mkdir ./config

COPY --from=server-builder /home/server-builder/ui-server ./
COPY config/docker.yaml ./config/docker.yaml
COPY docker/start-ui-server.sh ./start-ui-server.sh

RUN chown temporal:temporal /home/ui-server -R

EXPOSE 8080
ENTRYPOINT ["./start-ui-server.sh"]
ENV TEMPORAL_CLOUD_UI=$TEMPORAL_CLOUD_UI
