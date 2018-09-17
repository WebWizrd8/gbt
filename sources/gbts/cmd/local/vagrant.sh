function gbt_vagrant() {
    local WHICH=$(which $GBT__WHICH_OPTS which 2>/dev/null)
    [ -z $WHICH ] && gbt__err "'which' not found" && return 1
    local VAGRANT_BIN=$(which $GBT__WHICH_OPTS vagrant 2>/dev/null)
    [ $? -ne 0 ] && gbt__err "'vagrant' not found" && return 1

    if [ "$1" != 'ssh' ]; then
        $VAGRANT_BIN "$@"
    else
        shift

        local RDN=$RANDOM
        local GBT__CONF="/tmp/.gbt.$RDN"

        $VAGRANT_BIN ssh --command "cat /etc/motd 2>/dev/null;
export GBT__CONF='$GBT__CONF' &&
function gbt__$RDN() { echo '$((gbt__get_sources; echo 'gbt__ssh_theme') | eval "$GBT__SOURCE_COMPRESS" | $GBT__SOURCE_BASE64_LOCAL | tr -d '\r\n')' | $GBT__SOURCE_BASE64 $GBT__SOURCE_BASE64_DEC | $GBT__SOURCE_DECOMPRESS; };
if [ -z "$GBT__SOURCE_SEC_DISABLE" ]; then
  export GBT__CONF_MD5=\$(gbt__$RDN | tee $GBT__CONF | $GBT__SOURCE_MD5_REMOTE 2>/dev/null | cut -d' ' -f$GBT__SOURCE_MD5_CUT_REMOTE 2>/dev/null);
  echo '[ -z \"\$GBT__CONF_MD5\" ] && export GBT__CONF_MD5='\$GBT__CONF_MD5' || true' >> $GBT__CONF;
else
  gbt__$RANDOM > $GBT__CONF;
fi;
exec -a gbt.bash bash --rcfile \$GBT__CONF;
rm -f \$GBT__CONF \$GBT__CONF.bash" "$@"
    fi
}
