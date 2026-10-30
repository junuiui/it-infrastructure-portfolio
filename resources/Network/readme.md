# Network References

[Company Specification](../../company-spec.md) · [How-to Guide](../../HowTo.md)

The original [Network Infrastructure Lab](https://github.com/junuiui/network-infrastructure-lab) is the fixed design authority. Its Packet Tracer files are unchanged.

- [Network configuration guide](https://github.com/junuiui/network-infrastructure-lab/blob/main/HowTo.md)
- [Historical architecture/headcount reference](https://github.com/junuiui/network-infrastructure-lab/blob/69d8c1a8993dfd07d1f167922214b5a84aa0ceb9/docs/architecture.md)
- [Integrated addressing and implementation status](../../company-spec.md)

Currently implemented in VMware: isolated server subnet, Ubuntu outbound router, DC static address, and AD DNS. Departmental client subnets, Windows DHCP scopes, and relay still require implementation/verification.

Packet Tracer and VMware use the same company design but are not physically connected. The Packet Tracer 10.0.0.0/30 transit is separate from VMnet8's 10.0.0.0/24 NAT network.
