# docker-systemd-unit-generator

systemd process managers unit file generator for docker container auto starting.

## install

```sh
git clone https://github.com/lesstif/docker-systemd-unit-generator
```

## Usage

1. pull docker image

1. create redis_server system unit file.

  ```sh
  ./systemd-docker-unit-gen.sh redis_server
  ```

if you need to pass options to the docker container (such as --env foo=bar), running script with extra options.

  ```sh
  ./systemd-docker-unit-gen.sh redis_server --env foo=bar -v redis_volume
  ```

1. confirm systemd unit file was generate corretly.

  ```sh
  $ systemctl list-unit-files|grep docker

  docker-container@redis_server.service       enabled 
  docker.service                              enabled 
  ```

1. show unit dependencies 
  ```sh
  $ systemctl list-dependencies docker-container@redis_server.service

  docker-container@redis_server.service
  ● ├─docker.service
  ● ├─system-docker\x2dcontainer.slice
  ● └─basic.target
  ●   ├─firewalld.service
  ●   ├─microcode.service
  ```
  
  
