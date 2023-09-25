#!/bin/sh

ip link del dev wg0 2>/dev/null ||:
if ip link add dev wg0 type wireguard; then
  ip link del dev wg0
else
  echo "**** The wireguard module is not found ****"
  sleep infinity
fi

/usr/bin/wg-quick up /etc/wireguard/wg0.conf
