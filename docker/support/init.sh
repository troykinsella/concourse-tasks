LOG_FILE=${LOG_FILE:-/tmp/docker.log}
SKIP_PRIVILEGED=${SKIP_PRIVILEGED:-false}
STARTUP_TIMEOUT=${STARTUP_TIMEOUT:-120}
MAX_CONCURRENT_DOWNLOADS=${MAX_CONCURRENT_DOWNLOADS:-3}
MAX_CONCURRENT_UPLOADS=${MAX_CONCURRENT_UPLOADS:-3}
PID_FILE=/tmp/docker.pid

sanitize_cgroups() {
  mkdir -p /sys/fs/cgroup
  mountpoint -q /sys/fs/cgroup || \
    mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup

  mount -o remount,rw /sys/fs/cgroup

  sed -e 1d /proc/cgroups | while read sys hierarchy num enabled; do
    if [ "$enabled" != "1" ]; then
      # subsystem disabled; skip
      continue
    fi

    grouping="$(cat /proc/self/cgroup | cut -d: -f2 | grep "\\<$sys\\>")" || true
    if [ -z "$grouping" ]; then
      # subsystem not mounted anywhere; mount it on its own
      grouping="$sys"
    fi

    mountpoint="/sys/fs/cgroup/$grouping"

    mkdir -p "$mountpoint"

    # clear out existing mount to make sure new one is read-write
    if mountpoint -q "$mountpoint"; then
      umount "$mountpoint"
    fi

    mount -n -t cgroup -o "$grouping" cgroup "$mountpoint"

    if [ "$grouping" != "$sys" ]; then
      if [ -L "/sys/fs/cgroup/$sys" ]; then
        rm "/sys/fs/cgroup/$sys"
      fi

      ln -s "$mountpoint" "/sys/fs/cgroup/$sys"
    fi
  done

  if ! test -e /sys/fs/cgroup/systemd ; then
    mkdir /sys/fs/cgroup/systemd
    mount -t cgroup -o none,name=systemd none /sys/fs/cgroup/systemd
  fi
}

start_docker() {
  mkdir -p /var/log
  mkdir -p /var/run

  if [ "$SKIP_PRIVILEGED" = "false" ]; then
    sanitize_cgroups

    # check for /proc/sys being mounted readonly, as systemd does
    if grep '/proc/sys\s\+\w\+\s\+ro,' /proc/mounts >/dev/null; then
      mount -o remount,rw /proc/sys
    fi
  fi

  local mtu=$(cat /sys/class/net/$(ip route get 8.8.8.8|awk '{ print $5 }')/mtu)
  local server_args="--mtu ${mtu}"
  local registry=""

  server_args="${server_args} --max-concurrent-downloads=$MAX_CONCURRENT_DOWNLOADS --max-concurrent-uploads=$MAX_CONCURRENT_UPLOADS"

  try_start() {
    dockerd ${server_args} >$LOG_FILE 2>&1 &
    echo $! > "$PID_FILE"

    sleep 1

    echo waiting for docker to come up...
    until docker info >/dev/null 2>&1; do
      sleep 1
      if ! kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
        return 1
      fi
    done
  }

  export server_args LOG_FILE
  declare -fx try_start
  trap stop_docker EXIT

  if ! timeout ${STARTUP_TIMEOUT} /bin/bash -ce 'while true; do try_start && break; done'; then
    echo Docker failed to start within ${STARTUP_TIMEOUT} seconds.
    cat $LOG_FILE
    return 1
  fi
}

stop_docker() {
  if [ ! -f $PID_FILE ]; then
    return 0
  fi

  local pid=$(cat $PID_FILE)
  if [ -z "$pid" ]; then
    return 0
  fi

  kill -TERM $pid
}

docker_log_in() {
  local username="$1"
  local password="$2"
  local registry="$3"

  docker login -u "${username}" -p "${password}" ${registry}
}

# Arg:
# "- domain: <domain>
#    cert: <cert>"
add_docker_ca_cert() {
  local raw_ca_certs="${1}"
  local cert_count="$(echo $raw_ca_certs | jq -r '. | length')"

  for i in $(seq 0 $(expr "$cert_count" - 1));
  do
    local cert_dir="/etc/docker/certs.d/$(echo $raw_ca_certs | jq -r .[$i].domain)"
    mkdir -p "$cert_dir"
    echo $raw_ca_certs | jq -r .[$i].cert >> "${cert_dir}/ca.crt"
  done
}
