# IPAddress_v4

IPAddress_v4 is a Swift library for doing basic handling of IPv4 Addresses expressed as single addresses, ranges, or CIDRs.

This package is very loosely based on the IPv4 handling from the [ipaddress](https://docs.python.org/3/library/ipaddress.html#module-ipaddress) module for python3.

## IPAddress_v4
`IPAddress_v4` is used to express single IP addresses.

To create a new `IPAddress_v4` instance:
```
// From a String
let ip = IPAddress_v4("127.0.0.1")
// From an Int
let ip = IPAddress_v4(2130706433)
```
##### Available Properties
|Name|Description|Type|
|---|---|---|
|address| A `String` representation of the address.|String|
|integer| An `Int` representation of the address.|Int|
|version| IP version.|Int|
|reversePointer|The name of the reverse DNS PTR record for the address.|String|
|isMulticast|If the address is reserved for multicast use.|Bool|
|isPrivate|If the address is allocated for private networks.|Bool|
|isReserved|If the address is otherwise IETF reserved.|Bool|
|isLoopback|If the address is a loopback address.|Bool|
|isLinkLocal|If the address is reserved for link-local usage.|Bool|

## IPNetwork_v4
`IPNetwork_v4` is used to express a network of IP Addresses.

To create a new `IPNetwork_v4` instance:
```
// From a CIDR String
let net = IPNetwork_v4("10.10.10.10/27")
// From an IP Range
let net = IPNetwork_v4("10.10.10.10-10.10.10.21")
// From a single IP Address
let net = IPNetwork_v4("10.10.10.10")
```

##### Available Properties
|Name|Description|Type|
|---|---|---|
|version| IP version.|Int|
|maxPrefixLen|Maximum IP prefix length.|Int|
|prefix|The prefix for the network.|Int|
|withPrefix|A `String` representation of the CIDR. e.g. `<Address>/<Prefix>`.|String|
|netMask|The net mask as an `IPAddress_v4` Object.|IPAddress_v4|
|withNetMask|A `String` representation of the address with its net mask. e.g. `<Address>/<Net Mask>`|String|
|networkAddress|The network address for the network.|IPAddress_v4|
|broadcastAddress|The broadcast address for the network.|IPAddress_v4|
|isRange|If the network was defined as a range. If so, some properties may not be available.|Bool|
|hosts|An `Array` of `IPAddress_v4` addresses that belong to the network. This includes the network address and broadcast address.|Array|
|usableHosts|This is the same as `hosts` but it excludes the network and broadcast addresses.|Array|
|count|The total number of addresses included in the network.|Int|
