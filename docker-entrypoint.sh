#!/bin/bash
set -e

#enable extrausers, just in case
sed -i '/^\(passwd\|group\|shadow\):/{ s/$/ extrausers/; }' /etc/nsswitch.conf

if [ "$1" = "munged" ]
then
    echo "---> Starting the MUNGE Authentication service (munged) ..."
#    if [ ! -e /etc/munge/munge.key ]
#    then
#        /usr/sbin/create-munge-key
#    fi
    #copy in munge key
    cp /local/munge-key/munge.key /etc/munge/munge.key
    #this should likely be removed, but had some issues with munge perms
    mkdir -p /var/run/munge
    chown -R munge:munge /etc/munge
    chmod 700 /etc/munge
    chmod 400 /etc/munge/munge.key
    chown -R munge:munge /var/run/munge
    chmod -R 755 /var/run/munge
    exec gosu munge /usr/sbin/munged -F
fi

if [ "$1" = "slurmdbd" ]
then
    echo "---> Starting automount"
    cp /mnt/autofs/auto.* /etc
    chmod 444 /etc/auto.*
    BROWSE_MODE="no" /usr/sbin/automount -t 0 -f /etc/auto.master &
    echo "---> Starting the Slurm Database Daemon (slurmdbd) ..."
    exec gosu slurm /usr/sbin/slurmdbd -Dvvv
fi

if [ "$1" = "slurmctld" ]
then
    echo "---> Waiting for slurmdbd to become active before starting slurmctld ..."

#    until 2>/dev/null >/dev/tcp/slurmdbd/6819
#    do
#        echo "-- slurmdbd is not available.  Sleeping ..."
#        sleep 2
#    done
#    echo "-- slurmdbd is now active ..."

    #wait until munge socket is up
    until [ -S /var/run/munge/munge.socket.2 ]
    do
      sleep 2
      echo "waiting for munge to start"
    done

    echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
    exec gosu slurm /usr/sbin/slurmctld -iDvvv
fi

if [ "$1" = "slurmd" ]
then
#add logic to check for /var/run/munge/munge.socket.2.lock and /var/run/slurmdbd/slurmdbd.pid 
#    echo "---> Waiting for slurmctld to become active before starting slurmd..."
#    until 2>/dev/null >/dev/tcp/slurmctld/6817
#    do
#        echo "-- slurmctld is not available.  Sleeping ..."
#        sleep 2
#    done
#    echo "-- slurmctld is now active ..."

    echo "---> Starting the Slurm Node Daemon (slurmd) ..."
    #slurmd entry point for starting SLURM inside kubernetes
    #note: /root/host-mappings should be somehow mounted into the container
    #/etc/hostname on the host is mounted to /root/hostname
    name=`cat /root/hostname`
    slurmName=`grep $name /root/hosts/host-mappings | cut -f2 -d" "`
    myip=$(awk '/32 host/ { print f } {f=$2}' <<< "$(</proc/net/fib_trie)" | sort | uniq  | grep -v 127.0.0.1)
    #wait until munge socket is up
    until [ -S /var/run/munge/munge.socket.2 ]
    do
      sleep 2
      echo "waiting for munge to start"
    done
    echo "DEBUG SCONTROL COMMAND: scontrol update nodename=$slurmName nodeaddr=$myip nodehostname=`hostname`"
    scontrol update nodename=$slurmName nodeaddr=$myip nodehostname=`hostname`
    exec slurmd -D -N $slurmName
fi

exec "$@"
