import XCTest
@testable import IPAddress_v4

final class IPNetwork_v4Tests: XCTestCase {
    // IPNetwork_v4 Tests
    func testCidrNetwork() {
        let net: IPNetwork_v4 = try! IPNetwork_v4("10.10.10.10/27")
        let expectedNetworkAddress = try! IPAddress_v4("10.10.10.0")
        let expectedBroadcastAddress = try! IPAddress_v4("10.10.10.31")
        
        XCTAssertEqual(net.isRange, false)
        XCTAssertEqual(net.version, 4)
        XCTAssertEqual(net.count, 32)
        XCTAssertEqual(net.networkAddress!.address, expectedNetworkAddress.address)
        XCTAssertEqual(net.broadcastAddress!.address, expectedBroadcastAddress.address)
        XCTAssertEqual(net.netMask!.address, "255.255.255.224")
        XCTAssertEqual(net.hosts!.count, 32)
        XCTAssertEqual(net.usableHosts!.count, 30)
        XCTAssertFalse(net.usableHosts!.map({$0.address!}).contains(expectedNetworkAddress.address))
        XCTAssertFalse(net.usableHosts!.map({$0.address!}).contains(expectedBroadcastAddress.address))
        XCTAssertTrue(net.hosts!.map({$0.address!}).contains(expectedNetworkAddress.address))
        XCTAssertTrue(net.hosts!.map({$0.address!}).contains(expectedBroadcastAddress.address))
        XCTAssertEqual(net.withPrefix, "10.10.10.10/27")
        XCTAssertEqual(net.withNetMask, "10.10.10.10/255.255.255.224")
    }
    
    func testSingleIPNetwork() {
        let net: IPNetwork_v4 = try! IPNetwork_v4("10.10.10.10")
        
        XCTAssertEqual(net.isRange, false)
        XCTAssertEqual(net.version, 4)
        XCTAssertEqual(net.count, 1)
        XCTAssertEqual(net.networkAddress!.address, "10.10.10.10")
        XCTAssertEqual(net.broadcastAddress!.address, "10.10.10.10")
        XCTAssertEqual(net.netMask!.address, "255.255.255.255")
        XCTAssertEqual(net.hosts!.count, 1)
        XCTAssertEqual(net.usableHosts!.count, 1)
        XCTAssertEqual(net.withPrefix, "10.10.10.10/32")
        XCTAssertEqual(net.withNetMask, "10.10.10.10/255.255.255.255")
    }
    
    func testIPRangeNetwork() {
        let net: IPNetwork_v4 = try! IPNetwork_v4("10.10.10.10-10.10.10.21")
        
        XCTAssertEqual(net.isRange, true)
        XCTAssertEqual(net.version, 4)
        XCTAssertEqual(net.count, 12)
        XCTAssertEqual(net.networkAddress!.address, "10.10.10.10")
        XCTAssertEqual(net.broadcastAddress!.address, "10.10.10.21")
        XCTAssertEqual(net.hosts!.count, 12)
        XCTAssertEqual(net.usableHosts!.count, 12)
        XCTAssertEqual(net.hosts![0].address, "10.10.10.10")
        XCTAssertEqual(net.hosts![11].address, "10.10.10.21")
        XCTAssertEqual(net.usableHosts![0].address, "10.10.10.10")
        XCTAssertEqual(net.usableHosts![11].address, "10.10.10.21")
        if net.netMask != nil {
            XCTFail("Should be nil")
        }
        if net.withNetMask != nil {
            XCTFail("Should be nil")
        }
        if net.prefix != nil {
            XCTFail("Should be nil")
        }
        if net.withPrefix != nil {
            XCTFail("Should be nil")
        }
    }
    
    func testInvalidCidrNetwork() {
        do {
            let _: IPNetwork_v4 = try IPNetwork_v4("10.10.10.10/33")
            XCTFail("Error should have been thrown")
        }
        catch let e as IPAddressParsingError {
            XCTAssertEqual(e.kind, IPAddressParsingError.ErrorKind.invalidValue)
        }
        catch {
            XCTFail("Wrong error")
        }
    }
    
    static var allTests = [
        // IPNetwork_v4 Tests
        ("testCidrNetwork", testCidrNetwork),
        ("testSingleIPNetwork", testSingleIPNetwork),
        ("testIPRangeNetwork", testIPRangeNetwork),
        ("testInvalidCidrNetwork", testInvalidCidrNetwork)
    ]
}
