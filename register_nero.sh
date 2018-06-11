#!/bin/bash
set -e

docker exec slurmdbd bash -c "/usr/bin/sacctmgr --immediate add cluster name=nero" && \
docker-compose restart slurmdbd slurmctld
