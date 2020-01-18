#!/bin/bash
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
trim_all() {
    # Usage: trim_all "   example   string    "
    set -f
    set -- $*
    printf '%s\n' "$*"
    set +f
}


DNF_HISTORY_CMD="dnf history list -4|grep '^[[:space:]].*[0-9].* | '"
DNF_HISTORY_FILE=$(mktemp)
if [[ "$USER" != "root" ]]; then
    DNF_HISTORY_CMD="sudo -u root $DNF_HISTORY_CMD"
fi

eval $DNF_HISTORY_CMD > $DNF_HISTORY_FILE
DNF_HISTORY_CODE=$?

command -v jo >/dev/null

while read -r line; do
    _id="$(trim_all $(echo $line|cut -d'|' -f1))"
    _cmd="dnf $(trim_all $(echo $line|cut -d'|' -f2))"
    _date="$(trim_all $(echo $line|cut -d'|' -f3))"
    _actions="$(trim_all $(echo $line|cut -d'|' -f4))"
    _altered="$(trim_all $(echo $line|cut -d'|' -f5))"
    jo_cmd="jo id=$_id cmd=\"$_cmd\" date=\"$_date\" actions=\"$_actions\" altered=\"$_altered\" line=\"$line\""
    eval $jo_cmd
done < $DNF_HISTORY_FILE

