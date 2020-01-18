#!/bin/bash
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


nodemon -w . -e py,sh,yaml,json -x sh -c './parse-dnf.sh'
