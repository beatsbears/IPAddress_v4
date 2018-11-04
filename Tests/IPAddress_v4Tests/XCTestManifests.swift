import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IPAddress_v4Tests.allTests),
        testCase(IPNetwork_v4Tests.allTests)
    ]
}
#endif
