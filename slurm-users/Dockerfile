from willthelaw/slurm-base

maintainer William Law <wlaw@stanford.edu>

env DEBIAN_FRONTEND noninteractive

COPY slurm-add-user /usr/local/bin/slurm-add-user 

COPY adduser.conf /etc/adduser.conf

entrypoint ["/usr/local/bin/slurm-add-user"]
