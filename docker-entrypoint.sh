#!/bin/bash
set -e

if [ "$1" = "munge" ]
then
    echo "---> Starting the MUNGE Authentication service (munged) ..."
    if [ ! -e /etc/munge/munge.key ]
    then
        /usr/sbin/create-munge-key
        chown -R munge:munge /etc/munge
        chmod 700 /etc/munge
    fi
    #this should likely be removed, but had some issues with munge perms
    chown -R munge:munge /etc/munge
    chmod 700 /etc/munge
    chown -R munge:munge /var/run/munge
    exec gosu munge /usr/sbin/munged
fi

if [ "$1" = "slurmdbd" ]
then
    echo "---> Starting the Slurm Database Daemon (slurmdbd) ..."

    {
        . /etc/slurm/slurmdbd.conf
        until echo "SELECT 1" | mysql -h $StorageHost -u$StorageUser -p$StoragePass 2>&1 > /dev/null
        do
            echo "-- Waiting for database to become active ..."
            sleep 2
        done
    }
    echo "-- Database is now active ..."

    exec gosu slurm /usr/sbin/slurmdbd -Dvvv
fi

if [ "$1" = "slurmctld" ]
then
    echo "---> Waiting for slurmdbd to become active before starting slurmctld ..."

    until 2>/dev/null >/dev/tcp/slurmdbd/6819
    do
        echo "-- slurmdbd is not available.  Sleeping ..."
        sleep 2
    done
    echo "-- slurmdbd is now active ..."

    echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
    exec gosu slurm /usr/sbin/slurmctld -iDvvv
fi

if [ "$1" = "slurmd" ]
then
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
    slurmName=`grep $name /root/host-mappings | cut -f2 -d" "`
    myip=$(awk '/32 host/ { print f } {f=$2}' <<< "$(</proc/net/fib_trie)" | sort | uniq  | grep -v 127.0.0.1)
    scontrol update nodename=$slurmName nodeaddr=$myip nodehostname=`hostname`
    exec slurmd -D -N $slurmName
fi

exec "$@"
