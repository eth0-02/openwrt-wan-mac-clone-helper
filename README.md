# OpenWrt WAN MAC Clone Helper

Safely apply a WAN MAC address clone through OpenWrt UCI, create a timestamped backup of `/etc/config/network`, and renew the DHCP lease. The UCI change is visible in LuCI under **Network → Interfaces → WAN → Advanced Settings → Override MAC address**.

## Use

Copy the script to OpenWrt and run it as `root`:

```sh
chmod 755 wan-mac-clone.sh
./wan-mac-clone.sh A0:8C:FD:A4:3F:18
```

The optional second parameter selects a different logical WAN interface.

## What it does

1. Validates the requested MAC address.
2. Backs up `/etc/config/network` on the router.
3. Sets `network.wan.macaddr` with UCI.
4. Restarts only the chosen WAN interface.
5. Prints the resulting DHCP lease state.

## Limits

This script cannot bypass ISP authentication, captive portals, account restrictions, carrier MAC registration, PPPoE credentials, or VLAN requirements. If a lease is granted but traffic is blocked, authorize the MAC through the ISP portal or ask the provider to whitelist it.

Run it from a LAN connection, not through the WAN being changed. Keep the generated `/etc/config/network.before-mac-clone-*` file until connectivity is verified.

## License

MIT
