GBT__PLUGINS_LOCAL__HASH=" $(echo ${GBT__PLUGINS_LOCAL:-docker,mysql,screen,ssh,su,sudo,vagrant} | sed -E 's/,\ */ /g' | tr '[:upper:]' '[:lower:]') "
GBT__PLUGINS_REMOTE__HASH=" $(echo ${GBT__PLUGINS_REMOTE:-docker,mysql,screen,ssh,su,sudo,vagrant} | sed -E 's/,\ */ /g' | tr '[:upper:]' '[:lower:]') "
GBT__CARS_REMOTE__HASH=" $(echo ${GBT__CARS_REMOTE:-dir,git,hostname,os,sign,status,time} | sed -E 's/,\ */ /g' | tr '[:upper:]' '[:lower:]') "

[ -z "$GBT__SOURCE_BASE64_LOCAL" ] && GBT__SOURCE_BASE64_LOCAL='base64'


function gbt__local_rcfile() {
    local GBT__CONF="/tmp/.gbt.$RANDOM"
    echo -n '' > $GBT__CONF

    gbt__get_sources >> $GBT__CONF

    if [ -z "$GBT__SOURCE_SEC_DISABLE" ]; then
        echo "[ -z \"\$GBT__CONF_MD5\" ] && export GBT__CONF_MD5=$($GBT__SOURCE_SEC_SUM_LOCAL $GBT__CONF 2>/dev/null| cut -d' ' -f$GBT__SOURCE_SEC_CUT_LOCAL 2>/dev/null)" >> $GBT__CONF
    else
        echo 'export GBT__SOURCE_SEC_DISABLE=1' >> $GBT__CONF
    fi

    echo -e "#!/bin/bash\nexec -a gbt.bash bash --rcfile $GBT__CONF \"\$@\"" > $GBT__CONF.bash
    chmod +x $GBT__CONF.bash

    echo $GBT__CONF
}


function gbt__get_sources_cars() {
    local C=$1

    [ "$C" = 'exectime' ] && cat $GBT__HOME/sources/exectime/bash.sh
    [ "${C:0:6}" = 'custom' ] && C=${C:0:6}

    cat $GBT__HOME/sources/gbts/car/$C.sh
}


function gbt__get_sources() {
    [ -z "$GBT__HOME" ] && gbt__err "'GBT__HOME' not defined" && return 1

    [ -z "$GBT__SOURCE_MINIMIZE" ] && GBT__SOURCE_MINIMIZE="sed -E -e '/^\\ *#.*/d' -e '/^\\ *$/d' -e 's/^\\ +//g' -e 's/default([A-Z])/d\\1/g' -e 's/model-/m-/g' -e 's/\\ {2,}/ /g'"

    # Conditional for remote only (GBT__PLUGINS_REMOTE)
    [[ ${GBT__PLUGINS_REMOTE__HASH[@]} == *' ssh '* ]] && [ -z "$GBT__THEME_SSH" ] && local GBT__THEME_SSH="$GBT__HOME/sources/gbts/theme/ssh/${GBT__THEME_SSH_NAME:-default}.sh"
    [[ ${GBT__PLUGINS_REMOTE__HASH[@]} == *' mysql '* ]] && [ -z "$GBT__THEME_MYSQL" ] && local GBT__THEME_MYSQL="$GBT__HOME/sources/gbts/theme/mysql/${GBT__THEME_MYSQL_NAME:-default}.sh"

    (
        echo "export GBT__CONF='$GBT__CONF'"
        cat $GBT__HOME/sources/gbts/{cmd{,/remote},car}/_common.sh

        # Allow to override default list of cars defined in the theme
        [ -n "$GBT__THEME_REMOTE_CARS" ] && echo "export GBT__THEME_REMOTE_CARS='$GBT__THEME_REMOTE_CARS'"
        [ -n "$GBT__THEME_MYSQL_CARS" ] && echo "export GBT__THEME_MYSQL_CARS='$GBT__THEME_MYSQL_CARS'"

        # Security on the remote site
        if [ -z "$GBT__SOURCE_SEC_DISABLE" ]; then
            [ -n "$GBT__SOURCE_SEC_CUT_REMOTE" ] && echo "export GBT__SOURCE_SEC_CUT_REMOTE=\"\${GBT__SOURCE_SEC_CUT_LOCAL:-$GBT__SOURCE_SEC_CUT_REMOTE}\""
            [ -n "$GBT__SOURCE_SEC_SUM_REMOTE" ] && echo "export GBT__SOURCE_SEC_SUM_REMOTE=\"\${GBT__SOURCE_SEC_SUM_LOCAL:-$GBT__SOURCE_SEC_SUM_REMOTE}\""
        else
            echo 'export GBT__SOURCE_SEC_DISABLE=1'
        fi

        for P in $(echo $GBT__PLUGINS_REMOTE__HASH); do
            cat $GBT__HOME/sources/gbts/cmd/remote/$P.sh
        done

        for C in $(echo $GBT__CARS_REMOTE__HASH); do
            gbt__get_sources_cars $C
        done

        if [[ ${GBT__PLUGINS_REMOTE__HASH[@]} == *' ssh '* ]]; then
            echo 'function gbt__ssh_theme() {'
            cat $GBT__THEME_SSH
            echo '}'
        fi

        if [[ ${GBT__PLUGINS_REMOTE__HASH[@]} == *' mysql '* ]]; then
            echo 'function gbt__mysql_theme() {'
            cat $GBT__THEME_MYSQL
            echo '}'
        fi

        [[ ${GBT__CARS_REMOTE__HASH[@]} == *' ssh '* ]] && [ -n "$GBT__THEME_SSH_CARS" ] && echo "export GBT__THEME_SSH_CARS='$GBT__THEME_SSH_CARS'"
        alias | awk '/gbt_/ {sub(/^(alias )?(gbt___)?/, "", $0); print "alias "$0}'
        echo "PS1='\$(GbtMain \$?)'"
    ) | eval "$GBT__SOURCE_MINIMIZE"
}
