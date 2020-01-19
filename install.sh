#!/bin/bash
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [[ ! -d /etc/ansible/facts.d ]]; then
    mkdir -p /etc/ansible/facts.d
fi

cp -f parse-dnf.py /etc/ansible/facts.d/dnfHistory.fact
chown root:root /etc/ansible/facts.d/dnfHistory.fact
chmod 700 /etc/ansible/facts.d/dnfHistory.fact

