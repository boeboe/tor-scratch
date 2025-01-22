# Tor-Scratch Container

Run [TOR](https://dist.torproject.org) conveniently from a docker scratch container.
 - Containers available on [DockerHub](https://hub.docker.com/r/boeboe/tor-scratch)
 - Sources available on [GitHub](https://github.com/boeboe/tor-scratch)

[![Docker Build](https://github.com/boeboe/tor-scratch/actions/workflows/docker-image.yml/badge.svg)](https://github.com/boeboe/tor-scratch/actions/workflows/docker-image.yml)
[![Docker Stars](https://img.shields.io/docker/stars/boeboe/tor-scratch)](https://hub.docker.com/r/boeboe/tor-scratch)
[![Docker Pulls](https://img.shields.io/docker/pulls/boeboe/tor-scratch)](https://hub.docker.com/r/boeboe/tor-scratch)
[![Docker Automated](https://img.shields.io/docker/cloud/automated/boeboe/tor-scratch)](https://hub.docker.com/r/boeboe/tor-scratch)
[![Docker Build](https://img.shields.io/docker/cloud/build/boeboe/tor-scratch)](https://hub.docker.com/r/boeboe/tor-scratch)
[![Docker Version](https://img.shields.io/docker/v/boeboe/tor-scratch?sort=semver)](https://hub.docker.com/r/boeboe/tor-scratch)

## Usage

```console
$ docker run --rm --network host boeboe/tor-scratch
```

Once the docker container has finished starting, you can test it with the following command:

```console
$ curl --socks5 localhost:9050 --socks5-hostname localhost:9050 https://check.torproject.org/api/ip
```

> **NOTE:** If you use do not use host network, you need to force tor to listen on `0.0.0.0` instead of the default `127.0.0.1`

In order to pass a `torrc` configuration file and modify the exposed proxy port:

```console
$ cat torrc 
Log notice stdout
HTTPTunnelPort 0.0.0.0:9080
SocksPort 0.0.0.0:9050
MaxCircuitDirtiness 30

$ docker run -p 8050:9050 -p 8080:9080 -v "$(pwd)"/torrc:/torrc boeboe/tor-scratch tor -f torrc

$ curl --socks5 localhost:8050 --socks5-hostname localhost:8050 https://check.torproject.org/api/ip
$ curl --proxy localhost:8080 https://check.torproject.org/api/ip
```

## Request configuration change

Please use this [link](https://github.com/boeboe/tor-scratch/issues/new/choose) (GitHub account required) to suggest a change in this image configuration.

