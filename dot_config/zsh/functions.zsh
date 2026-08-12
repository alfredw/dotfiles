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

# --- PAI nonprodqa bastion + k9s helpers -----------------------------------
# Port 1081 matches the socks5 proxy_url hardcoded in
# infrastructure/environments/nonprodqa/providers.tf.
: ${NONPRODQA_VPC_HOST_PROJECT:=vpc-host-nonprod-ra396-dg836}
: ${NONPRODQA_BASTION_ZONE:=us-east1-b}
: ${NONPRODQA_BASTION_PORT:=1081}
: ${NONPRODQA_CLUSTER_PROJECT:=nonprodqa-web-platform-svc-873}
: ${NONPRODQA_CLUSTER_NAME:=nonprodqa-private-autopilot}
: ${NONPRODQA_CLUSTER_REGION:=us-east1}

nonprodqa-tunnel() {
  if lsof -iTCP:${NONPRODQA_BASTION_PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Tunnel already listening on :${NONPRODQA_BASTION_PORT}"
    return 0
  fi
  echo "Opening IAP tunnel to nonprodqa-bastion-vm on :${NONPRODQA_BASTION_PORT}..."
  # Detach stdin from terminal so the ssh -t pty doesn't get SIGTTIN/SIGTTOU
  # when the process is backgrounded (otherwise it's stuck in T state and never binds).
  nohup gcloud compute ssh nonprodqa-bastion-vm \
    --zone "${NONPRODQA_BASTION_ZONE}" \
    --tunnel-through-iap \
    --project "${NONPRODQA_VPC_HOST_PROJECT}" \
    --ssh-flag="-D ${NONPRODQA_BASTION_PORT}" \
    --ssh-flag="-q" \
    --ssh-flag="-N" \
    --ssh-flag="-o ExitOnForwardFailure=yes" \
    --ssh-flag="-o ServerAliveInterval=10" \
    </dev/null >/tmp/nonprodqa-tunnel.log 2>&1 &
  disown
  echo "Tunnel PID: $! (log: /tmp/nonprodqa-tunnel.log)"
  echo "Wait a few seconds, then verify: lsof -iTCP:${NONPRODQA_BASTION_PORT} -sTCP:LISTEN -n -P"
}

nonprodqa-tunnel-kill() {
  local pattern="nonprodqa-bastion-vm"
  if ! pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "No nonprodqa tunnel found"
    return 0
  fi
  echo "Killing nonprodqa tunnel processes..."
  pkill -f "$pattern"
  sleep 1
  if pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "Some processes survived SIGTERM — sending SIGKILL..."
    pkill -9 -f "$pattern"
  fi
}

nonprodqa-kubeconfig() {
  gcloud container clusters get-credentials "${NONPRODQA_CLUSTER_NAME}" \
    --region "${NONPRODQA_CLUSTER_REGION}" \
    --project "${NONPRODQA_CLUSTER_PROJECT}"
}

_nonprodqa-ensure-tunnel() {
  if ! lsof -iTCP:${NONPRODQA_BASTION_PORT} -sTCP:LISTEN -n -P >/dev/null 2>&1; then
    echo "No tunnel listening on :${NONPRODQA_BASTION_PORT} — run 'nonprodqa-tunnel' first" >&2
    return 1
  fi
}

nonprodqa-k9s() {
  _nonprodqa-ensure-tunnel || return 1
  HTTPS_PROXY="socks5://127.0.0.1:${NONPRODQA_BASTION_PORT}" \
    k9s --context "gke_${NONPRODQA_CLUSTER_PROJECT}_${NONPRODQA_CLUSTER_REGION}_${NONPRODQA_CLUSTER_NAME}"
}

nonprodqa-kubectl() {
  _nonprodqa-ensure-tunnel || return 1
  HTTPS_PROXY="socks5://127.0.0.1:${NONPRODQA_BASTION_PORT}" \
    kubectl --context "gke_${NONPRODQA_CLUSTER_PROJECT}_${NONPRODQA_CLUSTER_REGION}_${NONPRODQA_CLUSTER_NAME}" "$@"
}

# --- PAI euprod bastion + k9s helpers --------------------------------------
# Port 10800 matches the socks5 proxy_url hardcoded in
# infrastructure/environments/euprod/providers.tf.
# Values confirmed 2026-07-24 via gcloud against the live euprod env.
# NB: euprod-web-platform-svc-899ep is the disabled legacy gcp_base placeholder;
# the real cluster lives in ...-992b03.
: ${EUPROD_VPC_HOST_PROJECT:=vpc-host-prod-hg867-gf641}
: ${EUPROD_BASTION_ZONE:=europe-west2-a}
: ${EUPROD_BASTION_PORT:=10800}
: ${EUPROD_CLUSTER_PROJECT:=euprod-web-platform-svc-992b03}
: ${EUPROD_CLUSTER_NAME:=euprod-private-autopilot}
: ${EUPROD_CLUSTER_REGION:=europe-west2}

euprod-tunnel() {
  if lsof -iTCP:${EUPROD_BASTION_PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Tunnel already listening on :${EUPROD_BASTION_PORT}"
    return 0
  fi
  echo "Opening IAP tunnel to euprod-bastion-vm on :${EUPROD_BASTION_PORT}..."
  # Detach stdin from terminal so the ssh -t pty doesn't get SIGTTIN/SIGTTOU
  # when the process is backgrounded (otherwise it's stuck in T state and never binds).
  nohup gcloud compute ssh euprod-bastion-vm \
    --zone "${EUPROD_BASTION_ZONE}" \
    --tunnel-through-iap \
    --project "${EUPROD_VPC_HOST_PROJECT}" \
    --ssh-flag="-D ${EUPROD_BASTION_PORT}" \
    --ssh-flag="-q" \
    --ssh-flag="-N" \
    --ssh-flag="-o ExitOnForwardFailure=yes" \
    --ssh-flag="-o ServerAliveInterval=10" \
    </dev/null >/tmp/euprod-tunnel.log 2>&1 &
  disown
  echo "Tunnel PID: $! (log: /tmp/euprod-tunnel.log)"
  echo "Wait a few seconds, then verify: lsof -iTCP:${EUPROD_BASTION_PORT} -sTCP:LISTEN -n -P"
}

euprod-tunnel-kill() {
  local pattern="euprod-bastion-vm"
  if ! pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "No euprod tunnel found"
    return 0
  fi
  echo "Killing euprod tunnel processes..."
  pkill -f "$pattern"
  sleep 1
  if pgrep -f "$pattern" >/dev/null 2>&1; then
    echo "Some processes survived SIGTERM — sending SIGKILL..."
    pkill -9 -f "$pattern"
  fi
}

euprod-kubeconfig() {
  gcloud container clusters get-credentials "${EUPROD_CLUSTER_NAME}" \
    --region "${EUPROD_CLUSTER_REGION}" \
    --project "${EUPROD_CLUSTER_PROJECT}"
}

_euprod-ensure-tunnel() {
  if ! lsof -iTCP:${EUPROD_BASTION_PORT} -sTCP:LISTEN -n -P >/dev/null 2>&1; then
    echo "No tunnel listening on :${EUPROD_BASTION_PORT} — run 'euprod-tunnel' first" >&2
    return 1
  fi
}

euprod-k9s() {
  _euprod-ensure-tunnel || return 1
  HTTPS_PROXY="socks5://127.0.0.1:${EUPROD_BASTION_PORT}" \
    k9s --context "gke_${EUPROD_CLUSTER_PROJECT}_${EUPROD_CLUSTER_REGION}_${EUPROD_CLUSTER_NAME}"
}

euprod-kubectl() {
  _euprod-ensure-tunnel || return 1
  HTTPS_PROXY="socks5://127.0.0.1:${EUPROD_BASTION_PORT}" \
    kubectl --context "gke_${EUPROD_CLUSTER_PROJECT}_${EUPROD_CLUSTER_REGION}_${EUPROD_CLUSTER_NAME}" "$@"
}
