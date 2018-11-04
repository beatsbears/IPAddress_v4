import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IPAddress_v4Tests.allTests),
        testCase(IpNetwork_v4Tests.allTests)
    ]
}
#endif
