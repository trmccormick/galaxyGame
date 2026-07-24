#!/bin/bash
set -e

# Fix permissions on mounted volumes for rails user
[ -d /home/galaxy_game/tmp ] && chown -R 1000:1000 /home/galaxy_game/tmp 2>/dev/null || true
[ -d /home/galaxy_game/log ] && chown -R 1000:1000 /home/galaxy_game/log 2>/dev/null || true

# If running as root, switch to rails user
if [ "$(id -u)" = '0' ]; then
  cd /home/galaxy_game
  exec su -s /bin/bash -c "cd /home/galaxy_game && exec \"\$@\"" rails -- "$@"
else
  cd /home/galaxy_game
  exec "$@"
fi
