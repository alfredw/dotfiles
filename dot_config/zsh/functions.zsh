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
