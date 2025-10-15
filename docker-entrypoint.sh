#!/bin/sh
set -e

export PUID=${PUID:-0}
export PGID=${PGID:-0}
export GROUP_NAME="app"
export USER_NAME="app"

create_group() {
  if ! getent group ${PGID} > /dev/null 2>&1; then
    addgroup -g ${PGID} ${GROUP_NAME}
  else
    existing_group=$(getent group ${PGID} | cut -d: -f1)
    export GROUP_NAME=${existing_group}
  fi
}

create_user() {
  if ! getent passwd ${PUID} > /dev/null 2>&1; then
    adduser -u ${PUID} -G ${GROUP_NAME} -s /bin/sh -D ${USER_NAME}
  else
    existing_user=$(getent passwd ${PUID} | cut -d: -f1)
    export USER_NAME=${existing_user}
  fi
}

create_group
create_user

load_secret_files() {
  old_ifs="$IFS"
  IFS='
'
  for line in $(env | grep '^LISTMONK_.*_FILE='); do
    var="${line%%=*}"
    fpath="${line#*=}"
    if [ -f "$fpath" ]; then
      new_var="${var%_FILE}"
      export "$new_var"="$(cat "$fpath")"
    fi
  done
  IFS="$old_ifs"
}

load_secret_files

# 🔥 Generate config.toml dynamically from Render environment variables
echo "Generating config.toml from environment variables..."
cat <<EOF > /listmonk/config.toml
[app]
address = "0.0.0.0:9000"

[db]
host = "${LISTMONK_db__host}"
port = ${LISTMONK_db__port}
user = "${LISTMONK_db__user}"
password = "${LISTMONK_db__password}"
database = "${LISTMONK_db__database}"
ssl_mode = "${LISTMONK_db__ssl_mode}"
max_open = 25
max_idle = 25
max_lifetime = "300s"

[api]
enable = true
EOF

echo "✅ Config generated successfully:"
cat /listmonk/config.toml

if ! chown -R ${PUID}:${PGID} /listmonk 2>/dev/null; then
  echo "Warning: Failed to change ownership of /listmonk. Readonly volume?"
fi

echo "Launching listmonk with user=[${USER_NAME}] group=[${GROUP_NAME}] PUID=[${PUID}] PGID=[${PGID}]"

if [ "$(id -u)" = "0" ] && [ "${PUID}" != "0" ]; then
  su-exec ${PUID}:${PGID} "$@"
else
  exec "$@"
fi
