//
//  IPAddress_v4.swift
//
//  Created by Andrew Scott on 11/3/18.

/// All definitions based on IANA Assignments
/// Ref: https://www.iana.org/assignments/iana-ipv4-special-registry/iana-ipv4-special-registry.xhtml
private let MULTICAST_RANGE: ClosedRange<UInt32> = ClosedRange(uncheckedBounds: (lower: 3758096384, upper: 4026531839))
private let PRIVATE_RANGES: [ClosedRange<UInt32>] = [ClosedRange(uncheckedBounds: (lower: 167772160, upper: 184549375)),
                              ClosedRange(uncheckedBounds: (lower: 2886729728, upper: 2887778303)),
                              ClosedRange(uncheckedBounds: (lower: 3232235520, upper: 3232301055))]
private let RESERVED_RANGE: ClosedRange<UInt32> = ClosedRange(uncheckedBounds: (lower: 4026531840, upper: 4294967295))
private let LOOPBACK_RANGE: ClosedRange<UInt32> = ClosedRange(uncheckedBounds: (lower: 2130706432, upper: 2147483647))
private let LOCAL_LINK_RANGE: ClosedRange<UInt32> = ClosedRange(uncheckedBounds: (lower: 2851995648, upper: 2852061183))
private let IP_VERSION = 4
private let MAX_PREFIX_LENGTH = 32

public class IPAddress_v4 {
    /// Represents a single IPv4 Address.
    
    public var address: String?
    public var integer: UInt32?
    public var version: Int = IP_VERSION
    public var reversePointer: String?
    public var isMulticast: Bool?
    public var isPrivate: Bool?
    public var isReserved: Bool?
    public var isLoopback: Bool?
    public var isLinkLocal: Bool?
    
    public init(_ rep: String) throws {
        if IPAddress_v4.isValidIPv4(rep) {
            self.address = rep
            self.integer = IPAddress_v4.IPv4ToInt(rep)
            self.isMulticast = self.isMulticast(self.integer!)
            self.isPrivate = self.isPrivate(self.integer!)
            self.isReserved = self.isReserved(self.integer!)
            self.isLoopback = self.isLoopback(self.integer!)
            self.isLinkLocal = self.isLocalLink(self.integer!)
            self.reversePointer = "\(rep.split(separator: ".").reversed().joined(separator: ".")).in-addr.arpa"
        } else {
            throw IPAddressParsingError(kind: .invalidValue)
        }
    }
    
    public init(_ rep: UInt32) throws {
        self.address = self.IntToIPv4(rep)
        self.integer = rep
        self.isMulticast = self.isMulticast(rep)
        self.isPrivate = self.isPrivate(rep)
        self.isReserved = self.isReserved(rep)
        self.isLoopback = self.isLoopback(rep)
        self.isLinkLocal = self.isLocalLink(rep)
        self.reversePointer = "\(self.address!.split(separator: ".").reversed().joined(separator: ".")).in-addr.arpa"
    }
    
    class func isValidIPv4(_ ip: String) -> Bool {
        let octets = ip.split(separator: ".")
        let nums = octets.compactMap { Int($0) }
        return octets.count == 4 && nums.count == 4 && !nums.contains { $0 < 0 || $0 > 255 }
    }
    
    class func IPv4ToInt(_ ip: String) -> UInt32 {
        let octets: [UInt32] = ip.split(separator: ".").map({UInt32($0)!})
        var total: UInt32 = 0
        for i in stride(from:3, through:0, by:-1) {
            total += octets[3-i] << (i * 8)
        }
        return total
    }
    
    func IntToIPv4(_ int: UInt32) -> String {
        return String((int >> 24) & 0xFF) + "." + String((int >> 16) & 0xFF) + "." + String((int >> 8) & 0xFF) + "." + String(int & 0xFF)
    }
    
    func isMulticast(_ ip: UInt32) -> Bool {
        return MULTICAST_RANGE.contains(ip)
    }
    
    func isPrivate(_ ip: UInt32) -> Bool {
        for range in PRIVATE_RANGES {
            if range.contains(ip) {
                return true
            }
        }
        return false
    }
    
    func isReserved(_ ip: UInt32) -> Bool {
        return RESERVED_RANGE.contains(ip)
    }
    
    func isLoopback(_ ip: UInt32) -> Bool {
        return LOOPBACK_RANGE.contains(ip)
    }
    
    func isLocalLink(_ ip: UInt32) -> Bool {
        return LOCAL_LINK_RANGE.contains(ip)
    }
}

public class IPNetwork_v4 {
    /// Represents a network of IPv4 Addresses.
    
    public let version: Int = IP_VERSION
    public let maxPrefixLen: Int = MAX_PREFIX_LENGTH
    public var count: Int = 0
    public var hosts: [IPAddress_v4]?
    public var usableHosts: [IPAddress_v4]?
    public var prefix: Int?
    public var netMask: IPAddress_v4?
    public var networkAddress: IPAddress_v4?
    public var broadcastAddress: IPAddress_v4?
    public var withPrefix: String?
    public var withNetMask: String?
    public var isRange: Bool = false
    private var address: String?
    
    
    public init(_ rep: String) throws {
        do {
            if rep.contains("/") {
                if self.isValidCIDR(rep) {
                    self.prefix = Int(rep.split(separator: "/")[1])!
                    self.address = String(rep.split(separator: "/")[0])
                    self.netMask = self.getNetMask(self.prefix!)
                    self.networkAddress = self.getNetworkAddress(self.address!, self.netMask!)
                    self.broadcastAddress = self.getBroadcastAddress(self.networkAddress!, self.prefix!)
                    (self.hosts, self.usableHosts, self.count) =
                        self.explodeNetwork(self.networkAddress!, self.broadcastAddress!)
                    self.withPrefix = rep
                    self.withNetMask = "\(self.address!)/\(self.netMask!.address!)"
                } else {
                    throw IPAddressParsingError(kind: .invalidValue)
                }
            } else if rep.contains("-") {
                let range: [String] = rep.split(separator: "-").map({String($0)})
                if IPAddress_v4.isValidIPv4(range[0]) && IPAddress_v4.isValidIPv4(range[1]) {
                    self.isRange = true
                    self.networkAddress = try! IPAddress_v4(range[0])
                    self.broadcastAddress = try! IPAddress_v4(range[1])
                    (self.hosts, self.usableHosts, self.count) =
                        explodeRange(self.networkAddress!, self.broadcastAddress!)
                } else {
                    throw IPAddressParsingError(kind: .invalidValue)
                }
            } else if IPAddress_v4.isValidIPv4(rep) {
                self.prefix = MAX_PREFIX_LENGTH
                self.netMask = try! IPAddress_v4("255.255.255.255")
                self.networkAddress = try! IPAddress_v4(rep)
                self.broadcastAddress = try! IPAddress_v4(rep)
                self.count = 1
                self.hosts = [self.networkAddress!]
                self.usableHosts = [self.networkAddress!]
                self.withPrefix = "\(rep)/32"
                self.withNetMask = "\(rep)/255.255.255.255"
            } else {
                throw IPAddressParsingError(kind: .invalidValue)
            }
        } catch {
            throw IPAddressParsingError(kind: .invalidValue)
        }
    }
    
    func isValidCIDR(_ cidr: String) -> Bool {
        let ip: String = String(cidr.split(separator: "/")[0])
        let prefix: Int = Int(cidr.split(separator: "/")[1])!
        
        return IPAddress_v4.isValidIPv4(ip) && prefix <= MAX_PREFIX_LENGTH && prefix > 0
    }
    
    func IPtoIntArray(_ ip: IPAddress_v4) -> [Int] {
        return ip.address!.split(separator: ".").map({Int($0)!})
    }
    
    func getNetMask(_ prefix: Int) -> IPAddress_v4 {
        var mask = [0, 0, 0, 0]
        for i in stride(from: 0, to: prefix, by: 1) {
            mask[i/8] = mask[i/8] + (1 << (7 - i % 8))
        }
        return try! IPAddress_v4(mask.map({String($0)}).joined(separator: "."))
    }
    
    func getNetworkAddress(_ addr: String, _ netMask: IPAddress_v4) -> IPAddress_v4 {
        var net: [Int] = []
        let mask: [Int] = self.IPtoIntArray(netMask)
        let addr = addr.split(separator: ".").map({Int($0)!})
        for i in stride(from: 0, to: 4, by: 1) {
            net.append(Int(addr[i]) & mask[i])
        }
        return try! IPAddress_v4(net.map({String($0)}).joined(separator: "."))
    }
    
    func getBroadcastAddress(_ net: IPAddress_v4, _ prefix: Int) -> IPAddress_v4 {
        var broadcast: [Int] = self.IPtoIntArray(net)
        let brange = 32 - prefix
        for i in stride(from: 0, to: brange, by: 1) {
            broadcast[3 - i/8] = broadcast[3 - i/8] + (1 << (i % 8))
        }
        return try! IPAddress_v4(broadcast.map({String($0)}).joined(separator: "."))
    }
    
    func explodeNetwork(_ network: IPAddress_v4, _ broadcast: IPAddress_v4) -> ([IPAddress_v4]?, [IPAddress_v4]?, Int) {
        var totalIPs: [IPAddress_v4] = []
        for i in stride(
            from: IPAddress_v4.IPv4ToInt(network.address!),
            through: IPAddress_v4.IPv4ToInt(broadcast.address!),
            by: 1) {
                totalIPs.append(try! IPAddress_v4(i))
        }
        return (totalIPs, Array(totalIPs.dropFirst().dropLast()), totalIPs.count)
    }
    
    func explodeRange(_ lower: IPAddress_v4, _ upper: IPAddress_v4) -> ([IPAddress_v4]?, [IPAddress_v4]?, Int) {
        var totalIPs: [IPAddress_v4] = []
        for i in stride(
            from: IPAddress_v4.IPv4ToInt(lower.address!),
            through: IPAddress_v4.IPv4ToInt(upper.address!),
            by: 1) {
            totalIPs.append(try! IPAddress_v4(i))
        }
        return (totalIPs, totalIPs, totalIPs.count)
    }
}

struct IPAddressParsingError: Error {
    enum ErrorKind {
        case invalidCharacter
        case invalidValue
        case internalError
    }
    
    let kind: ErrorKind
}

