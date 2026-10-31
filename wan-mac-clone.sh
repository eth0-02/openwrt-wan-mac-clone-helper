#!/bin/sh
# Apply a WAN MAC clone through UCI, back up network config, and renew DHCP.
set -eu

usage() {
    echo "Usage: $0 AA:BB:CC:DD:EE:FF [wan-interface]"
    exit 2
}

valid_mac() {
    echo "$1" | grep -Eiq '^[0-9a-f]{2}(:[0-9a-f]{2}){5}$'
}

MAC="${1:-}"
WAN="${2:-wan}"
[ -n "$MAC" ] && valid_mac "$MAC" || usage
DEVICE="$(uci -q get network.$WAN.device || true)"
[ -n "$DEVICE" ] || { echo "No device configured for network.$WAN" >&2; exit 1; }

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/etc/config/network.before-mac-clone-$STAMP"
cp /etc/config/network "$BACKUP"
echo "Backup: $BACKUP"
echo "Applying $MAC to $WAN ($DEVICE)"
uci set "network.$WAN.macaddr=$MAC"
uci commit network
ifdown "$WAN" || true
sleep 2
ifup "$WAN"
sleep 12
echo '--- WAN status ---'
ubus call "network.interface.$WAN" status
if ubus call "network.interface.$WAN" status | grep -q '"up": true'; then
    echo 'WAN lease acquired.'
else
    echo 'No DHCP lease yet. Check cable, VLAN/PPPoE requirements, and ISP authorization.' >&2
fi
echo 'MAC cloning cannot bypass captive portals, account authentication, or carrier MAC registration.'
