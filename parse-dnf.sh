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
    SUDO_PREFIX="sudo  -u root"
fi
DNF_HISTORY_CMD="$SUDO_PREFIX $DNF_HISTORY_CMD"
DNF_HISTORY_INFO_CMD="$SUDO_PREFIX dnf history info"

eval $DNF_HISTORY_CMD > $DNF_HISTORY_FILE
DNF_HISTORY_CODE=$?

command -v jo >/dev/null

while read -r line; do
    _id="$(trim_all $(echo $line|cut -d'|' -f1))"
    _cmd="dnf $(trim_all $(echo $line|cut -d'|' -f2))"
    _date="$(trim_all $(echo $line|cut -d'|' -f3))"
    _actions="$(trim_all $(echo $line|cut -d'|' -f4))"
    _altered="$(trim_all $(echo $line|cut -d'|' -f5))"
    _info_b64="$(eval $DNF_HISTORY_INFO_CMD|base64 -w0)"
    _user="$(echo $_info_b64|base64 -d|grep '^User '|cut -d':' -f2|cut -d' ' -f2)"
    echo $_info_b64|base64 -d

    echo;
    echo $_info_b64|base64 -d|grep '^Packages Altered' -A 9999|grep '^[[:space:]].* [A-Z]'
    echo;

    _LINE_B64="line_b64=\"$_line_b64\""
    _INFO_B64="info_b64=\"$_info_b64\""
    LINE="$_LINE_B64"
    INFO="$_INFO_B64"
    JO_SUFFIX="${LINE} ${INFO}"
    JO_SUFFIX="${LINE}"
    JO_SUFFIX="${INFO}"
    JO_SUFFIX=""
    jo_cmd="jo id=$_id user=$_user cmd=\"$_cmd\" date=\"$_date\" actions=\"$_actions\" altered=\"$_altered\"${JO_SUFFIX}"
    eval $jo_cmd
done < $DNF_HISTORY_FILE

