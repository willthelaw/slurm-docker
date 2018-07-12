FROM nvidia/cuda:9.2-devel-ubuntu18.04

env DEBIAN_FRONTEND noninteractive

LABEL org.label-schema.name="slurm-docker" \
      org.label-schema.description="Slurm Docker cluster on Ubuntu 18.04" \
      maintainer="William Law"

ARG SLURM_VERSION=17.11.2

ARG GOSU_VERSION=1.10

RUN apt-get update

RUN apt-get -y dist-upgrade

RUN apt-get  -y install \
           screen \
           keyutils \
           autofs \
           libnss-extrausers \
           wget \
           bzip2 \
           perl \
           vim \
           git \
           munge \
           libmunge2 \
           slurmdbd \
           slurm-client \
           slurm-wlm-basic-plugins \
           slurm-wlm \
           slurm-wlm-doc \
           libslurm-dev \
           slurm-wlm-basic-plugins-dev \
           libslurmdb32 \
           python-pip \
           python3-pip \
           mysql-common \
           libmysqlclient-dev \
           bash-completion \
#    && yum clean all \
    && rm -rf /var/cache/apt

RUN pip install Cython nose \
    && pip3 install Cython nose

RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
#    && export GNUPGHOME="$(mktemp -d)" \
#    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
#    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
#    && rm -rf $GNUPGHOME /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x \
    && mkdir /var/spool/slurmd \
        /var/run/slurmd \
        /var/run/slurmdbd \
        /var/lib/slurmd \
        /var/log/slurm \
        /var/run/munge \
        /data \
    && touch /var/lib/slurmd/node_state \
        /var/lib/slurmd/front_end_state \
        /var/lib/slurmd/job_state \
        /var/lib/slurmd/resv_state \
        /var/lib/slurmd/trigger_state \
        /var/lib/slurmd/assoc_mgr_state \
        /var/lib/slurmd/assoc_usage \
        /var/lib/slurmd/qos_usage \
        /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* \
    && /usr/sbin/create-munge-key -f 
RUN set -x \
    && ln -s /etc/slurm-llnl /etc/slurm

#COPY slurm.conf /etc/slurm/slurm.conf
#COPY slurmdbd.conf /etc/slurm/slurmdbd.conf

#enable extra users files for /etc/{passwd,shadow,group}
COPY nsswitch.conf /etc/nsswitch.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["slurmdbd"]
