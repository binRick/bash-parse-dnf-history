#!/bin/bash
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


nodemon --delay 1 -w . -e py,sh,yaml,json -x sh -c './parse-dnf.sh'
