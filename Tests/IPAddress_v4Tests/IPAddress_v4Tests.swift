import XCTest
@testable import IPAddress_v4

final class IPAddress_v4Tests: XCTestCase {
    
    // IPAddress_v4 Tests
    func testPrivateIP() {
        let ip: IPAddress_v4 = try! IPAddress_v4("192.168.0.1")
        XCTAssertEqual(ip.version, 4)
        XCTAssertEqual(ip.integer, 3232235521)
        XCTAssertEqual(ip.address, "192.168.0.1")
        XCTAssertEqual(ip.reversePointer, "1.0.168.192.in-addr.arpa")
        XCTAssertEqual(ip.isPrivate, true)
        XCTAssertEqual(ip.isMulticast, false)
        XCTAssertEqual(ip.isReserved, false)
        XCTAssertEqual(ip.isLoopback, false)
        XCTAssertEqual(ip.isLinkLocal, false)
    }
    
    func testMultiCastIP() {
        let ip: IPAddress_v4 = try! IPAddress_v4("224.0.0.1")
        XCTAssertEqual(ip.version, 4)
        XCTAssertEqual(ip.integer, 3758096385)
        XCTAssertEqual(ip.address, "224.0.0.1")
        XCTAssertEqual(ip.reversePointer, "1.0.0.224.in-addr.arpa")
        XCTAssertEqual(ip.isPrivate, false)
        XCTAssertEqual(ip.isMulticast, true)
        XCTAssertEqual(ip.isReserved, false)
        XCTAssertEqual(ip.isLoopback, false)
        XCTAssertEqual(ip.isLinkLocal, false)
    }
    
    func testReservedIP() {
        let ip: IPAddress_v4 = try! IPAddress_v4("240.0.0.1")
        XCTAssertEqual(ip.version, 4)
        XCTAssertEqual(ip.integer, 4026531841)
        XCTAssertEqual(ip.address, "240.0.0.1")
        XCTAssertEqual(ip.reversePointer, "1.0.0.240.in-addr.arpa")
        XCTAssertEqual(ip.isPrivate, false)
        XCTAssertEqual(ip.isMulticast, false)
        XCTAssertEqual(ip.isReserved, true)
        XCTAssertEqual(ip.isLoopback, false)
        XCTAssertEqual(ip.isLinkLocal, false)
    }
    
    func testLoopbackIP() {
        let ip: IPAddress_v4 = try! IPAddress_v4("127.0.0.1")
        XCTAssertEqual(ip.version, 4)
        XCTAssertEqual(ip.integer, 2130706433)
        XCTAssertEqual(ip.address, "127.0.0.1")
        XCTAssertEqual(ip.reversePointer, "1.0.0.127.in-addr.arpa")
        XCTAssertEqual(ip.isPrivate, false)
        XCTAssertEqual(ip.isMulticast, false)
        XCTAssertEqual(ip.isReserved, false)
        XCTAssertEqual(ip.isLoopback, true)
        XCTAssertEqual(ip.isLinkLocal, false)
    }
    
    func testLinkLocalIP() {
        let ip: IPAddress_v4 = try! IPAddress_v4("169.254.0.1")
        XCTAssertEqual(ip.version, 4)
        XCTAssertEqual(ip.integer, 2851995649)
        XCTAssertEqual(ip.address, "169.254.0.1")
        XCTAssertEqual(ip.reversePointer, "1.0.254.169.in-addr.arpa")
        XCTAssertEqual(ip.isPrivate, false)
        XCTAssertEqual(ip.isMulticast, false)
        XCTAssertEqual(ip.isReserved, false)
        XCTAssertEqual(ip.isLoopback, false)
        XCTAssertEqual(ip.isLinkLocal, true)
    }
    
    func testInvalidIPTooManyOctets() {
        do {
            let _: IPAddress_v4 = try IPAddress_v4("1.1.1.1.1")
            XCTFail("Error should have been thrown")
        }
        catch let e as IPAddressParsingError {
            XCTAssertEqual(e.kind, IPAddressParsingError.ErrorKind.invalidValue)
        }
        catch {
            XCTFail("Wrong error")
        }
    }
    
    func testInvalidIPOctetTooLarge() {
        do {
            let _: IPAddress_v4 = try IPAddress_v4("1.1.1.256")
            XCTFail("Error should have been thrown")
        }
        catch let e as IPAddressParsingError {
            XCTAssertEqual(e.kind, IPAddressParsingError.ErrorKind.invalidValue)
        }
        catch {
            XCTFail("Wrong error")
        }
    }
    
    func testFromInt() {
        XCTAssertEqual(try IPAddress_v4(3232235521).address, "192.168.0.1")
    }
    
    func testInvalidIntTooLarge() {
        do {
            let _: IPAddress_v4 = try IPAddress_v4(4294967297)
            XCTFail("Error should have been thrown")
        }
        catch let e as IPAddressParsingError {
            XCTAssertEqual(e.kind, IPAddressParsingError.ErrorKind.invalidValue)
        }
        catch {
            XCTFail("Wrong error")
        }
    }
    
    func testInvalidIntNegative() {
        do {
            let _: IPAddress_v4 = try IPAddress_v4(-100)
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
        // IPAddress_v4 Tests
        ("testPrivateIP", testPrivateIP),
        ("testMultiCastIP", testMultiCastIP),
        ("testReservedIP", testReservedIP),
        ("testLoopbackIP", testLoopbackIP),
        ("testLinkLocalIP", testLinkLocalIP),
        ("testInvalidIPTooManyOctets", testInvalidIPTooManyOctets),
        ("testInvalidIPOctetTooLarge", testInvalidIPOctetTooLarge),
        ("testFromInt", testFromInt),
        ("testInvalidIntTooLarge", testInvalidIntTooLarge),
        ("testInvalidIntNegative", testInvalidIntNegative)
    ]
}
