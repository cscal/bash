#!/usr/bin/env bash
#
# Enables or disables a client connection to an L2TP/IPsec VPN. Usage: save
# this file as `vpn`, `chmod +x` it, and run `./vpn [up/down/toggle]` as root.
# Requires openswan and xl2tpd packages. Tested on Arch Linux.
#
# Based on:
#   https://bbs.archlinux.org/viewtopic.php?pid=1773313#p1773313
#   https://bbs.archlinux.org/viewtopic.php?pid=1781882#p1781882
#
# Example `ip route` output before connecting to VPN:
#   default via 192.168.1.1 dev wlp4s0 proto dhcp src 192.168.1.7 metric 303
#   10.1.14.252 dev ppp0 proto kernel scope link src 10.1.16.107
#   192.168.1.0/24 dev wlp4s0 proto dhcp scope link src 192.168.1.7 metric 303
#
# Example `ip route` output after connecting to VPN:
#   default via 10.1.14.252 dev ppp0
#   10.0.0.0/8 via 10.1.14.252 dev ppp0
#   10.1.14.252 dev ppp0 proto kernel scope link src 10.1.16.107
#   71.245.184.58 via 192.168.1.1 dev wlp4s0
#   192.168.1.0/24 dev wlp4s0 proto dhcp scope link src 192.168.1.7 metric 303

set -eu

# VPN settings (edit these!)
vpn_server_public_ip='vpn.ziyotek.com'
vpn_subnet='192.168.0.0/16'
vpn_pingee_local_ip='192.168.1.1'
vpn_shared_secret='Server!@#123'
vpn_username='CCalhoun'
vpn_password='Ziyo10@$4'

# Ensure that we're running as root
if [[ "$(id -u)" != 0 ]]; then
  echo 'Must run as root!'
  exit 1
fi

# Ensure that required packages are installed
if ! command -v ipsec > /dev/null; then
  echo '`ipsec` command not found! Please install Openswan.'
  exit 1
fi
if ! command -v xl2tpd > /dev/null; then
  echo '`xl2tpd` command not found! Please install xl2tpd.'
  exit 1
fi

# Handle subcommands
subcommand="${1-}"
if [[ "${subcommand}" = 'toggle' ]]; then
  if ip address | grep -q ': ppp'; then
    subcommand='down'
  else
    subcommand='up'
  fi
fi
case "${subcommand}" in
  # Connect to VPN
  up)
    # Ensure that we're not already connected
    if ip address | grep -q ': ppp'; then
      echo 'Already connected to VPN!'
      exit 1
    fi

    # Write config files
    default_network_device="$(ip route show default | cut -d' ' -f5)"
    cat > /etc/ipsec.conf << EOF
version 2.0

config setup
  virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
  nat_traversal=yes
  protostack=netkey
  plutoopts="--interface=${default_network_device}"

conn L2TP-PSK
  authby=secret
  pfs=no
  auto=add
  keyingtries=3
  dpddelay=30
  dpdtimeout=120
  dpdaction=clear
  rekey=yes
  ikelifetime=8h
  keylife=1h
  type=transport
  left=%defaultroute
  leftnexthop=%defaultroute
  leftprotoport=17/1701
  right=${vpn_server_public_ip}
EOF
    cat > /etc/ipsec.secrets << EOF
0.0.0.0 ${vpn_server_public_ip}: PSK "${vpn_shared_secret}"
EOF
    cat > /etc/xl2tpd/xl2tpd.conf << EOF
[lac vpn-connection]
lns = ${vpn_server_public_ip}
refuse chap = yes
refuse pap = yes
require authentication = yes
name = vpn-server
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF
    cat > /etc/ppp/options.l2tpd.client << EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-mschap-v2
noccp
noauth
idle 1800
mtu 1410
mru 1410
defaultroute
usepeerdns
debug
connect-delay 5000
name ${vpn_username}
password ${vpn_password}
EOF

    # Start Openswan
    ipsec setup --start
    ipsec setup --status | grep -q 'IPsec running'

    # Start xl2tpd
    xl2tpd -D &
    sleep 1
    ipsec auto --up L2TP-PSK
    ipsec setup --status | grep -q '1 tunnels up'

    # Connect to VPN
    echo 'c vpn-connection' > /var/run/xl2tpd/l2tp-control
    while true; do
      sleep 1
      ppp_device="$(ip address | grep -oE '^[0-9]+: ppp\w+' | cut -d' ' -f2)"
      if [[ -n "${ppp_device}" ]]; then
        break
      fi
      echo 'Waiting for ppp device...'
    done
    peer_ip="$(ip address show "${ppp_device}" | grep -oE 'peer [0-9.]+' | cut -d' ' -f2)"
    ip route add "${vpn_subnet}" via "${peer_ip}" dev "${ppp_device}"
    [[ -z "${vpn_pingee_local_ip}" ]] || ping -c 1 "${vpn_pingee_local_ip}"

    # Route all internet traffic through VPN
    local_ip="$(ip route show default | cut -d' ' -f3)"
    ip route add "${vpn_server_public_ip}" via "${local_ip}" dev "${default_network_device}"
    ip route delete default via "${local_ip}" dev "${default_network_device}"
    ip route add default via "${peer_ip}" dev "${ppp_device}"
    ;;

  # Disconnect from VPN
  down)
    # Ensure that we're already connected
    if ! ip address | grep -q ': ppp'; then
      echo 'Not connected to VPN!'
      exit 1
    fi

    # Undo routing rules
    default_network_device="$(ip route show "${vpn_server_public_ip}" | cut -d' ' -f5)"
    ppp_device="$(ip address | grep -oE '^[0-9]+: ppp\w+' | cut -d' ' -f2)"
    peer_ip="$(ip address show "${ppp_device}" | grep -oE 'peer [0-9.]+' | cut -d' ' -f2)"
    local_ip="$(ip route show "${vpn_server_public_ip}" | cut -d' ' -f3)"
    ip route delete default via "${peer_ip}" dev "${ppp_device}"
    ip route add default via "${local_ip}" dev "${default_network_device}"
    ip route delete "${vpn_server_public_ip}" via "${local_ip}" dev "${default_network_device}"

    # Kill VPN connection
    echo 'd vpn-connection' > /var/run/xl2tpd/l2tp-control
    sleep 1

    # Kill xl2tpd
    ipsec auto --down L2TP-PSK
    killall xl2tpd
    sleep 1

    # Kill Openswan
    ipsec setup --stop
    ;;

  *)
    echo 'Invalid subcommand!'
    exit 1
    ;;
esac

echo 'Success!'
