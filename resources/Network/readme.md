# Network Resources

[Company Specification](../../company-spec.md) · [How-to Guide](../../HowTo.md) · [October 31 Record](../../progress-2026-10-31.md)

The [Network Infrastructure Lab](https://github.com/junuiui/network-infrastructure-lab) remains the fixed Packet Tracer design authority. Its files and IP plan are unchanged.

- [Original network configuration guide](https://github.com/junuiui/network-infrastructure-lab/blob/main/HowTo.md)
- [Historical architecture/headcount plan](https://github.com/junuiui/network-infrastructure-lab/blob/69d8c1a8993dfd07d1f167922214b5a84aa0ceb9/docs/architecture.md)

## Implemented VMware mapping

| Purpose | VMnet | NIC | Router address |
|---|---|---|---|
| Upstream NAT | 8 | ens33 | 10.0.0.10/24, gateway 10.0.0.2 |
| Server | 3 | ens34 | 192.168.1.1/28 |
| HR Data | 4 | ens38 | 192.168.0.193/27 |
| ENG Data | 5 | ens39 | 192.168.0.1/26 |
| SM Data | 6 | ens40 | 192.168.1.65/26 |
| IT Data | 7 | ens41 | 192.168.1.17/28 |

All internal networks have VMware DHCP/host adapters disabled. Windows DHCP and AD DNS are on 192.168.1.2. Ubuntu DHCP Relay listens on ens34 and the four department NICs, excluding ens33. NAT sends Internet-bound traffic through ens33.

Ava Collins, Luke Fisher, Nora Green, and Nolan Allen tested the corresponding department roles. One representative client was moved between VMnets and OUs; it is back on HR/VMnet4 with DHCP.

## Boundaries

- VMware routing works between separate virtual subnets; no 802.1Q trunk is claimed.
- Packet Tracer and VMware are not directly connected.
- SMB/logon authorization denials do not prove packet-filter isolation. Department ACLs are not implemented.
- Voice, guest, Wi-Fi, printers and web/CME services remain design/simulation only.
- The Packet Tracer 10.0.0.0/30 transit is distinct from VMnet8's 10.0.0.0/24 NAT network.
- Expanded-router restart verification passed: six addressed NICs, one default route, forwarding 1, five source-subnet NAT rules and active/enabled DHCP Relay.
- Post-restart HR client lease captured as 192.168.0.194/27, gateway 192.168.0.193, DHCP/DNS 192.168.1.2; SRV discovery and SMB/HTTPS connectivity passed.

See the main guide for exact Netplan, Relay, DHCP GUI and test procedures. No network source files are changed in the original project.

## Restart evidence

- [Interfaces and routing](../photos/11-network1.png)
- [Forwarding, retained NAT and automatic Relay startup](../photos/12-network2.png)
- [Four active DHCP scopes](../photos/14-AD-DHCP-scope.png)
- [HR DHCP lease and AD DNS discovery](../photos/15-jh_test-HRPC01-ipconfig.png)

Only the HR exact post-restart client lease was captured. The earlier ENG/SM/IT sequential tests remain owner-reported; these images do not establish a fresh client lease on each subnet after restart.
