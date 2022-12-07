# Tor-Scratch Container

Run [TOR](https://dist.torproject.org) conveniently from a docker scratch container.
Containers available on [DockerHub](https://hub.docker.com/r/boeboe/tor-scratch).

```console
$ docker run --rm -p 9050:9050 boeboe/tor-scratch
```

Once the docker container has finished starting, you can test it with the following command:

```console
$ curl --socks5 localhost:9050 --socks5-hostname localhost:9050 https://check.torproject.org/api/ip
```

In order to pass a `torrc` configuration file and modify the proxy port:

```console
$ cat torrc 
Log notice stdout
SocksPort 0.0.0.0:9050
MaxCircuitDirtiness 30

$ docker run -p 8080:9050 -v "$(pwd)"/torrc:/torrc boeboe/tor-scratch tor -f torrc

$ curl --socks5 localhost:8080 --socks5-hostname localhost:8080 https://check.torproject.org/api/ip
```

Request configuration change
Please use this link (GitHub account required) to suggest a change in this image configuration.


**Minimal Docker Image with Tor.**

