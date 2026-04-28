mkcd() { mkdir -p "$1" && cd "$1"; }

extract() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.bz2)      tar xjf "$1" ;;
    *.tar.xz)       tar xJf "$1" ;;
    *.tar)          tar xf  "$1" ;;
    *.zip)          unzip "$1" ;;
    *.gz)           gunzip "$1" ;;
    *.bz2)          bunzip2 "$1" ;;
    *)              echo "Unknown archive: $1" ;;
  esac
}

# --- PAI nonproddev bastion + k9s helpers ---------------------------------
# Fill these in with the actual project IDs / zone for nonproddev once known.
: ${NONPRODDEV_VPC_HOST_PROJECT:=vpc-host-nonprod-ra396-dg836}
: ${NONPRODDEV_BASTION_ZONE:=us-east1-c}
: ${NONPRODDEV_BASTION_PORT:=1082}
: ${NONPRODDEV_CLUSTER_PROJECT:=nonproddev-web-platform-svc-ae}
: ${NONPRODDEV_CLUSTER_NAME:=nonproddev-private-autopilot}
: ${NONPRODDEV_CLUSTER_REGION:=us-east1}

nonproddev-tunnel() {
  if lsof -iTCP:${NONPRODDEV_BASTION_PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Tunnel already listening on :${NONPRODDEV_BASTION_PORT}"
    return 0
  fi
  echo "Opening IAP tunnel to nonproddev-bastion-vm on :${NONPRODDEV_BASTION_PORT}..."
  # Detach stdin from terminal so the ssh -t pty doesn't get SIGTTIN/SIGTTOU
  # when the process is backgrounded (otherwise it's stuck in T state and never binds).
  nohup gcloud compute ssh nonproddev-bastion-vm \
    --zone "${NONPRODDEV_BASTION_ZONE}" \
    --tunnel-through-iap \
    --project "${NONPRODDEV_VPC_HOST_PROJECT}" \
    --ssh-flag="-D ${NONPRODDEV_BASTION_PORT}" \
    --ssh-flag="-q" \
    --ssh-flag="-N" \
    --ssh-flag="-o ExitOnForwardFailure=yes" \
    --ssh-flag="-o ServerAliveInterval=10" \
    </dev/null >/tmp/nonproddev-tunnel.log 2>&1 &
  disown
  echo "Tunnel PID: $! (log: /tmp/nonproddev-tunnel.log)"
  echo "Wait a few seconds, then verify: lsof -iTCP:${NONPRODDEV_BASTION_PORT} -sTCP:LISTEN -n -P"
}

nonproddev-tunnel-kill() {
  # Matches all 3 processes gcloud spawns for an IAP SOCKS tunnel:
  # the gcloud wrapper, its ssh child, and ssh's start-iap-tunnel ProxyCommand.
  local pattern="nonproddev-bastion-vm"
  if ! pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "No nonproddev tunnel found"
    return 0
  fi
  echo "Killing nonproddev tunnel processes..."
  pkill -f "$pattern"
  sleep 1
  if pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "Some processes survived SIGTERM — sending SIGKILL..."
    pkill -9 -f "$pattern"
  fi
}

nonproddev-kubeconfig() {
  gcloud container clusters get-credentials "${NONPRODDEV_CLUSTER_NAME}" \
    --region "${NONPRODDEV_CLUSTER_REGION}" \
    --project "${NONPRODDEV_CLUSTER_PROJECT}"
}

_nonproddev-ensure-tunnel() {
  if ! lsof -iTCP:${NONPRODDEV_BASTION_PORT} -sTCP:LISTEN -n -P >/dev/null 2>&1; then
    echo "No tunnel listening on :${NONPRODDEV_BASTION_PORT} — run 'nonproddev-tunnel' first" >&2
    return 1
  fi
}

nonproddev-k9s() {
  _nonproddev-ensure-tunnel || return 1
  HTTPS_PROXY="socks5://127.0.0.1:${NONPRODDEV_BASTION_PORT}" \
    k9s --context "gke_${NONPRODDEV_CLUSTER_PROJECT}_${NONPRODDEV_CLUSTER_REGION}_${NONPRODDEV_CLUSTER_NAME}"
}

nonproddev-kubectl() {
  _nonproddev-ensure-tunnel || return 1
  HTTPS_PROXY="socks5://127.0.0.1:${NONPRODDEV_BASTION_PORT}" \
    kubectl --context "gke_${NONPRODDEV_CLUSTER_PROJECT}_${NONPRODDEV_CLUSTER_REGION}_${NONPRODDEV_CLUSTER_NAME}" "$@"
}
