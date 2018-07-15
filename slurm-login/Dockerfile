FROM nero-maas.stanford.edu:5000/slurm-gpu

env DEBIAN_FRONTEND noninteractive

LABEL org.label-schema.name="slurm-docker" \
      org.label-schema.description="Slurm Docker cluster on Ubuntu 18.04" \
      maintainer="William Law"

ARG SLURM_VERSION=17.11.2

ARG GOSU_VERSION=1.10

RUN apt-get update

RUN apt-get -y dist-upgrade

RUN apt-get  -y install \
           openssh-server \
#    && yum clean all \
    && rm -rf /var/cache/apt

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

#CMD ["slurmdbd"]
