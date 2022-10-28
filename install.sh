#!/bin/sh
if [ "$(id -un)" != "root" ]; then
  echo "This script must be run as root (sudo)"
  exit 1
fi

if command -v ws > /dev/null; then
  rm "$(which ws)"
fi

install_uri="https://raw.github.com/pmh-only/ws/main/install.sh"
install_path="/usr/local/bin/ws"

curl --fail --location --progress-bar --output "${install_path}" "${install_uri}"
chmod a+rx "${install_path}"

echo "ws has been installed to ${install_path}."
echo "Run 'ws --help' to get started."%    
