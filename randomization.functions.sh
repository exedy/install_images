#!/usr/bin/env bash

#
# randomization functions
#
# (c) 2016-2018, Hetzner Online GmbH
#

regenerate_snakeoil_ssl_certificate() {
  debug '# regenerate snakeoil ssl certificate'
  local certificate="$FOLD/hdd/etc/ssl/certs/ssl-cert-snakeoil.pem"
  local key="$FOLD/hdd/etc/ssl/private/ssl-cert-snakeoil.key"
  if [[ -e "$certificate" ]]; then rm "$certificate" || return 1; fi
  if [[ -e "$key" ]]; then rm "$key" || return 1; fi
  if installed_os_uses_systemd && ! systemd_nspawn_booted; then
    boot_systemd_nspawn || return 1
  fi
  execute_command_wo_debug DEBIAN_FRONTEND=noninteractive make-ssl-cert generate-default-snakeoil || return 1
  [[ -e "$certificate" ]] && [[ -e "$key" ]]
}

generate_password() {
  local length="${1:-16}"
  local password=''
  until echo "$password" | grep '[[:lower:]]' | grep '[[:upper:]]' | grep -q '[[:digit:]]'; do
    password="$(tr -cd '[:alnum:][:digit:]' < /dev/urandom | head -c "$length")"
  done
  echo "$password"
}

generate_random_string() {
  local length="${1:-48}"
  tr -cd '[:alnum:][:digit:]' < /dev/urandom | head -c "$length"
}

install_remove_password_txt_hint() {
  debug '# install remove_password_txt_hint'
  {
    echo '#!/usr/bin/env bash'
    echo "rm /etc/profile.d/99-$C_SHORT.sh \$0"
  } > "$FOLD/hdd/usr/local/bin/remove_password_txt_hint"
  chmod 755 "$FOLD/hdd/usr/local/bin/remove_password_txt_hint"
}

# vim: ai:ts=2:sw=2:et
