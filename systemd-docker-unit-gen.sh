#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

##@see https://docs.docker.com/engine/admin/host_integration/

SYSTEMD_DIR=/etc/systemd/system/
PREFIX=docker-container@

if [ "$#" -lt 1 ]; then
    echo "$# is Illegal number of parameters." 1>&2
    echo "Usage: $0 docker-container " 1>&2
    exit 1;
fi

args=("$@")

NAME=${args[0]}

OTHER_OPT=""

## three-parameter loop control for extract to extra options
for (( c = 1; c < $#; c++ )) do
    OTHER_OPT="${OTHER_OPT} ${args[$c]}";
done

##echo "Container=${NAME} OTHER_OPT='${OTHER_OPT}'"

EXIST=`docker ps --filter "name=${NAME}" | wc -l`

if [ $EXIST -lt 2 ];then
    echo "docker container name '${NAME}' not found. exiting..."
    exit 2;
fi

## systemd name pattern is /etc/systemd/system/docker-container@CONTAINER_NAME.service
## e.g: /etc/systemd/system/docker-container@redis_server.service                                     
SYSTEMD_CONF="${SYSTEMD_DIR}${PREFIX}${NAME}.service"                                                          

if [ "$#" -eq 1 ]; then
BLOCK="
[Unit]
Description=Docker Container %I
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a %i
ExecStop=/usr/bin/docker stop -t 2 %i

[Install]
WantedBy=default.target
"
else  ##  need to pass options to the docker container
BLOCK="
[Unit]
Description=Docker Container %I
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run ${OTHER_OPT} --name %i ${NAME}
ExecStop=/usr/bin/docker rm -f %i

[Install]
WantedBy=default.target
"
fi

echo "created ${SYSTEMD_CONF}"
echo "${BLOCK}" > "${SYSTEMD_CONF}"

systemctl daemon-reload

echo "enable  ${PREFIX}${NAME}.service"
systemctl enable "${PREFIX}${NAME}.service"

echo "start ${PREFIX}${NAME}.service"
systemctl start "${PREFIX}${NAME}.service"
